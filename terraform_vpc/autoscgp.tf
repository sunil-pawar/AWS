data "aws_ami" "myami" {
    owners = [ "amazon" ]
  filter {
    name   = "image-id"
    values = ["ami-0e472933a1395e172"]
  }
}


#variable "key_name" {}
/*
resource "tls_private_key" "test_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.test_private_key.public_key_openssh
}
*/
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("./templates/priv.pem.pub")
}

/*output "public_key" {
    value = aws_key_pair.generated_key.public_key
}*/

resource "aws_launch_template" "test_launch_template" {
  name_prefix   = "test"
  image_id      = data.aws_ami.myami.id
  instance_type = "t2.micro"
  iam_instance_profile {
    name=aws_iam_instance_profile.ecs-instance-profile.name   
  }
  key_name = aws_key_pair.deployer.key_name
  #key_name = aws_key_pair.generated_key.key_name
  user_data = filebase64("${path.module}/templates/user_data.sh")
}


resource "aws_autoscaling_group" "test_autoscaling_group" {
  vpc_zone_identifier = [
    aws_subnet.test_private_sn_01.id,
    aws_subnet.test_private_sn_02.id
     ]

  name = "test_autoscaling_group"
  max_size = var.maximsize
  min_size = var.minimsize
  desired_capacity = var.desire
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  target_group_arns  = [aws_alb_target_group.ecs-target-group.arn]
 # this block is for free tier
  launch_template {
    id      = aws_launch_template.test_launch_template.id
    version = "$Latest"
  }
# this block is used for premium aws services
/***  for_each = var.instance_map
  mixed_instances_policy {
    instances_distribution  {
      on_demand_base_capacity = 1
      on_demand_percentage_above_base_capacity = 75
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.test_launch_template.id
      }
      override {
        instance_type = each.key 
        weighted_capacity = each.value
      }
    }
  }*/
} 
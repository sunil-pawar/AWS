resource "aws_ecs_cluster" "default" {
  name = var.ecs_cluster_name
  tags = {
        stage = var.stage
        billing_tag = var.billing_tag
  }
  
}
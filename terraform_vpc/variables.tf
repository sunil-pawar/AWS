# main creds for AWS connection
/* variable "aws_access_key_id" {
  description = "AWS access key"
} */

/*variable "aws_secret_access_key" {
  description = "AWS secret access key"
} */


/* variable "ecs_key_pair_name" {
  description = "ECS key pair name"
} */

/* variable "region" {
  description = "AWS region"
} */

variable "availability_zone" {
  description = "availability zone used for the demo, based on region"
  default = {
    us-east-1 = "us-east-1"
  }
}

########################### Test VPC Config ################################

variable "test_vpc" {
  description = "VPC for Test environment"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "test_public_01_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  default = "10.0.1.0/24"
}

variable "test_private_02_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  default = "10.0.2.0/24" 
  }


####################################### general tags ########################

variable "billing_tag" { default = "001" }
variable "stage" { default = "production" } 
variable "cluster_name" { default = "techtest" } 
 




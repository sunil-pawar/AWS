#========================== TEST VPC =============================

# Declare the data source
data "aws_availability_zones" "available" {}


# Define a vpc
resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.test_vpc
    stage = var.stage
    billing_tag = var.billing_tag
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "test_ig" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
     Name = var.test_vpc
    stage = var.stage
    billing_tag = var.billing_tag
  }
}

# Elastic IP for NAT

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.test_ig]
}
# NAT 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.test_private_sn_01.id
  depends_on    = [aws_internet_gateway.test_ig]
  tags = {
    Name        = "nat"
    stage = var.stage
    billing_tag = var.billing_tag
  }
}
# Public subnet 1
resource "aws_subnet" "test_public_sn_01" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = var.test_public_01_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
   map_public_ip_on_launch = true
  tags = {
    Name = "test_public_sn_01"
    stage = var.stage
    billing_tag = var.billing_tag
  }
}

#  Private subnet 
resource "aws_subnet" "test_private_sn_01" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.test_private_02_cidr
availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "test_private_sn_01"
    stage = var.stage
    billing_tag = var.billing_tag
  }
}

# Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name        = "private-route-table"
    stage = var.stage
    billing_tag = var.billing_tag
  }
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
#associate rout tabel to private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.test_private_sn_01.id
  route_table_id = aws_route_table.private.id
}



# Routing table for public subnet 1
resource "aws_route_table" "test_public_sn_rt_01" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_ig.id
  }
  tags = {
    Name = "test_public_sn_rt_01"
    stage = var.stage
    billing_tag = var.billing_tag
  }
}

# Associate the routing table to public subnet 1
resource "aws_route_table_association" "test_public_sn_rt_01_assn" {
  subnet_id = aws_subnet.test_public_sn_01.id
  route_table_id = aws_route_table.test_public_sn_rt_01.id
}


# ECS Instance Security group
resource "aws_security_group" "test_public_sg" {
    name = "test_public_sg"
    description = "Test public access security group"
    vpc_id = aws_vpc.test_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = [ var.test_public_01_cidr , var.test_private_02_cidr ]
    }
    egress {
    # allow all traffic to private SN
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0"] 
    }

     tags = {
        Name = "test_public_sg"
        stage = var.stage
        billing_tag = var.billing_tag
    }
}
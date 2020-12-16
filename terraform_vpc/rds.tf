resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.test_private_sn_01.id, aws_subnet.test_private_sn_02.id]
}


resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Allows inbound access from ECS only"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = "5858"
    to_port         = "5858"
    security_groups = [aws_security_group.test_public_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier              = "production"
  name                    = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  port                    = "5858"
  engine                  = "postgres"
  engine_version          = "12.3"
  instance_class          = var.rds_instance_class
  allocated_storage       = "20"
  storage_encrypted       = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  multi_az                = false
  storage_type            = "gp2"
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
}
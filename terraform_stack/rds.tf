resource "aws_db_subnet_group" "db_subnet_group" {
  name = var.db_subnet_name
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.terraform_vpc.id
  name = var.db_sg_name
  dynamic "ingress" {
    for_each = var.db_sg_ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      security_groups = [aws_security_group.web_access.id]
    }
  }

  dynamic "egress" {
    for_each = var.db_sg_egress_rules
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

}

resource "aws_db_instance" "cakeshop_rds" {
  identifier = "cakeshop-db"
  db_name = "cakeshop_db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = "10"
  username = "admin"
  password = var.rds_password
  skip_final_snapshot = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name 
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az = false 
}
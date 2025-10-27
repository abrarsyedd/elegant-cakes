terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}


# 1. VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# 2. Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = var.pub_sub_1_cidr
  availability_zone = var.pub_sub_1_az
  map_public_ip_on_launch = true
  tags = {
    Name = var.pub_sub_1_name
  }
}

# 3. Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = var.pub_sub_2_cidr
  availability_zone = var.pub_sub_2_az
  map_public_ip_on_launch = true
  tags = {
    Name = var.pub_sub_2_name
  }
}

# Private Subnet
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = var.private_1_sub_cidr
  availability_zone = var.private_1_sub_az
  tags = {
    Name = var.private_1_sub_name
  }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = var.private_2_sub_cidr
  availability_zone = var.private_2_sub_az
  tags = {
    Name = var.private_2_sub_name
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = var.ig_name
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway in Public Subnet 1
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.private_1.id

  tags = {
    Name = "nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}



# 5. Route Table Public
resource "aws_route_table" "public_rt_1" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = var.rt_1_route
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.rt_1_name
  }
}

# 6. Route Table Private
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = var.rt_2_route
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = var.rt_2_name
  }
}

# 7. Route Table 1 Association
resource "aws_route_table_association" "pub_sub_1_association" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt_1.id
}

resource "aws_route_table_association" "pub_sub_2_association" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt_1.id
}

# 8. Route Table 2 Association
resource "aws_route_table_association" "private_sub_1_association" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_route_table_association" "private_sub_2_association" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

# 9. EC2 Security Group
resource "aws_security_group" "web_access" {
  vpc_id = aws_vpc.terraform_vpc.id
  name = var.sg_name

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

# 10. Find Latest ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Tell Terraform to upload your public key to AWS and name it ec2-key
resource "aws_key_pair" "my_key" {
  key_name = "ec2-key"
  public_key = file(var.ssh_key)
}

# 11. Ec2 instance
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_1.id
  security_groups = [aws_security_group.web_access.id]
  key_name = aws_key_pair.my_key.key_name

  user_data = templatefile("${path.module}/user-data.sh", {
    rds_endpoint = aws_db_instance.cakeshop_rds.address
    s3_url       = "https://s3.amazonaws.com/${aws_s3_bucket.assets_bucket.bucket}" 
  })
  tags = {
    Name = var.ec2_name
  }
}

# 12. ALB Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.terraform_vpc.id
  name = var.alb_sg_name

  dynamic "ingress" {
    for_each = var.alb_ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.alb_egress_rules
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

# 13. ALB
resource "aws_lb" "alb" {
  name = var.alb_name
  load_balancer_type = "application"
  internal = false
  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
}

# 14. Target Group
resource "aws_lb_target_group" "tg" {
  name = var.tg_name
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.terraform_vpc.id
}

# 15. HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.ssl_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 16. HTTP to HTTPS Redirect
resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 17. Attach EC2 Instance to Target Group
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.web.id
  port = 80
}
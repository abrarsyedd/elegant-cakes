variable "aws_region" {
  description = "AWS Region"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR Block For VPC"
  type = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
}

variable "pub_sub_1_name" {
  description = "Name of the Public Subnet 1"
  type = string
}

variable "pub_sub_1_cidr" {
  description = "CIDR Block For Public Subnet 1"
  type = string
}

variable "pub_sub_1_az" {
  description = "AZ For Public Subnet 1"
  type = string
}

variable "pub_sub_2_name" {
  description = "Name of the Public Subnet 2"
  type = string
}

variable "pub_sub_2_cidr" {
  description = "CIDR Block For Public Subnet 2"
  type = string
}

variable "pub_sub_2_az" {
  description = "AZ For Public Subnet 2"
  type = string
}

variable "private_1_sub_name" {
  description = "Name of Private Subnet 1"
  type = string
}

variable "private_1_sub_cidr" {
  description = "CIDR Block For Private Subnet 1"
  type = string
}

variable "private_1_sub_az" {
  description = "AZ For Private Subnet 1"
  type = string
}

variable "private_2_sub_name" {
  description = "Name of Private Subnet 2"
  type = string
}

variable "private_2_sub_cidr" {
  description = "CIDR Block For Private Subnet 2"
  type = string
}

variable "private_2_sub_az" {
  description = "AZ For Private Subnet 2"
  type = string
}

variable "ig_name" {
  description = "Nae of the Internet Gateway"
  type = string
}

variable "rt_1_name" {
  description = "Name of the Route Table 1"
  type = string
}

variable "rt_1_route" {
  description = "Route Table 1 Route"
  type = string
}

variable "rt_2_name" {
  description = "Name of the Route Table 2"
  type = string
}

variable "rt_2_route" {
  description = "Route Table 2 Route"
  type = string
}

variable "sg_name" {
  description = "Name of the Security Group"
  type = string
}

variable "ingress_rules" {
  description = "Inbound Rules For Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))
}

variable "egress_rules" {
  description = "Outbound Rule For Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))
}

variable "ec2_name" {
  description = "Name of the EC2 Instance"
  type = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
}

variable "ssh_key" {
  description = "SSH Key For EC2 Instance"
  type = string
}

variable "alb_sg_name" {
  description = "Name of the Security Group"
  type = string
}

variable "alb_ingress_rules" {
  description = "Inbound Rules For ALB Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))
}

variable "alb_egress_rules" {
  description = "Outbound Rule For ALB Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))
}

variable "alb_name" {
  description = "Name of the ALB"
  type = string
}

variable "tg_name" {
  description = "Name of the Target Group"
  type = string
}

variable "ssl_arn" {
  description = "SSL Certificate ARN"
  type = string
  sensitive = true
}

variable "db_sg_name" {
  description = "Name of DB Security Group"
  type = string
}

variable "db_sg_ingress_rules" {
  description = "Inbound Rules For DB Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    
  })) 
}

variable "db_sg_egress_rules" {
  description = "Outbound Rules For DB Security Group"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))
}

variable "db_subnet_name" {
  description = "Name of the DB Subnet Froup"
  type = string
}

variable "bucket_name" {
  description = "The name for your S3 bucket"
  type        = string
  default     = "elegant-cakeshop-public-assets"
}

variable "assets_folder" {
  description = "The local folder containing your static assets (css, js, images)"
  type        = string
  default     = "./public"
}
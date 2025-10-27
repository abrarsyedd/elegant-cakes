aws_region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
vpc_name = "Terraform VPC"
pub_sub_1_name = "Public_1"
pub_sub_1_cidr = "10.0.0.0/24"
pub_sub_1_az = "us-east-1a"
pub_sub_2_name = "Public_2"
pub_sub_2_cidr = "10.0.1.0/24"
pub_sub_2_az = "us-east-1b"
private_1_sub_name = "Private"
private_1_sub_cidr = "10.0.2.0/24"
private_1_sub_az = "us-east-1a"
private_2_sub_name = "Private"
private_2_sub_cidr = "10.0.3.0/24"
private_2_sub_az = "us-east-1b"

ig_name = "MyIGW"
rt_1_name = "Public_RT"
rt_1_route = "0.0.0.0/0"
rt_2_name = "Private_RT"
rt_2_route = "0.0.0.0/0"

sg_name = "WebAccess"
ingress_rules = [ {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
},
{
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
},
{
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]  
} ]

egress_rules = [ {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
} ]

ec2_name = "BlueWave"
instance_type = "t2.micro"
ssh_key = "~/.ssh/ec2-key.pub"

alb_sg_name = "ALBSG"
alb_ingress_rules = [ {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
},
{
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
} ]

alb_egress_rules = [ {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
} ]

alb_name = "MyALB"

tg_name = "MyTG"
ssl_arn = "arn:aws:acm:us-east-1:721128040838:certificate/b524a709-0de6-4592-a9dd-9fd4bc6861e7"

db_subnet_name = "db_subnet"

db_sg_name = "DB_SG"
db_sg_ingress_rules = [ {
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
} ]

db_sg_egress_rules = [ {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
} ]
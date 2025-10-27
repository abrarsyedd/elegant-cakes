# Deployment Guide - Elegant Cakes

Complete step-by-step guide to deploy the Elegant Cakes application on AWS using Terraform.

## 📋 Prerequisites

Before you start, ensure you have:

- ✅ AWS Account (with billing enabled)
- ✅ Terraform installed (v1.0+)
  ```bash
  terraform version
  ```
- ✅ GitHub Personal Access Token with `repo` scope
  - Generate at: https://github.com/settings/tokens
- ✅ AWS ACM SSL Certificate
  - Visit: https://console.aws.amazon.com/acm/
- ✅ EC2 Key Pair created in your AWS region
  - Visit: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs

## 🔧 Step 1: Setup Your Environment

### 1.1 Clone the Repository

```bash
git clone https://github.com/abrarsyedd/elegant-cakeshop.git
cd elegant-cakeshop
```

### 1.2 Create .env.example

```bash
cat > .env.example << 'EOF'
DB_HOST=your-rds-endpoint.rds.amazonaws.com
DB_USER=admin
DB_PASSWORD=your_strong_password
DB_NAME=cakeshop_db
PORT=3000
SESSION_SECRET=your_random_session_secret

USE_S3=true
S3_BUCKET_URL=https://your-bucket.s3.us-east-1.amazonaws.com
EOF
```

## 🏗️ Step 2: Configure Terraform

### 2.1 Initialize Terraform

```bash
cd terraform
terraform init
```

### 2.2 Create terraform.tfvars

```bash
cat > terraform.tfvars << 'EOF'
# AWS Configuration
aws_region = "us-east-1"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
vpc_name = "Elegant Cakes VPC"

# Public Subnets
pub_sub_1_name = "Public_Subnet_1"
pub_sub_1_cidr = "10.0.0.0/24"
pub_sub_1_az = "us-east-1a"

pub_sub_2_name = "Public_Subnet_2"
pub_sub_2_cidr = "10.0.1.0/24"
pub_sub_2_az = "us-east-1b"

# Private Subnets
private_1_sub_name = "Private_Subnet_1"
private_1_sub_cidr = "10.0.2.0/24"
private_1_sub_az = "us-east-1a"

private_2_sub_name = "Private_Subnet_2"
private_2_sub_cidr = "10.0.3.0/24"
private_2_sub_az = "us-east-1b"

# Internet Gateway
ig_name = "Elegant-Cakes-IGW"

# Route Tables
rt_1_name = "Public_Route_Table"
rt_1_route = "0.0.0.0/0"

rt_2_name = "Private_Route_Table"
rt_2_route = "0.0.0.0/0"

# Security Groups
sg_name = "Elegant-Cakes-WebAccess"

# EC2 Security Group Rules
ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP (e.g., 203.0.113.0/32)
  },
  {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# EC2 Instance
ec2_name = "Elegant-Cakes-App"
instance_type = "t2.micro"
ssh_key = "your-key-pair-name"  # Name of your EC2 key pair

# ALB Configuration
alb_sg_name = "Elegant-Cakes-ALB"
alb_name = "elegant-cakes-alb"
tg_name = "elegant-cakes-tg"

alb_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

alb_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# RDS Configuration
db_subnet_name = "Elegant-Cakes-DB-Subnet"
db_sg_name = "Elegant-Cakes-DB-SG"

db_sg_ingress_rules = [
  {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }
]

db_sg_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# S3 Configuration
bucket_name = "elegant-cakeshop-public-YOURNAME"  # Must be globally unique - add your name

# GitHub Token
github_token = "ghp_your_token_here"  # Replace with your GitHub token

# SSL Certificate ARN
ssl_arn = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERT_ID"
EOF
```

⚠️ **Important**: Replace `YOUR_IP`, `your-key-pair-name`, `bucket_name`, `github_token`, and `ssl_arn` with your actual values.

### 2.3 Validate Configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

## 🔍 Step 3: Review Terraform Plan

```bash
terraform plan
```

This shows all resources that will be created. Review carefully before proceeding.

## 🚀 Step 4: Deploy Infrastructure

### 4.1 Apply Terraform Configuration

```bash
terraform apply
```

When prompted, type:
```
yes
```

⏱️ **Deployment time**: 5-10 minutes

### 4.2 Save Outputs

After deployment completes, save important outputs:

```bash
terraform output -raw alb_dns_name
terraform output -raw rds_endpoint
terraform output -raw s3_bucket_url
```

## ✅ Step 5: Verify Deployment

### 5.1 SSH into EC2 Instance

```bash
# Get your EC2 public IP from AWS Console or:
aws ec2 describe-instances --region us-east-1 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

# SSH into instance
ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip

# Inside EC2, check application status
pm2 status
pm2 logs elegant-cakes

# Exit
exit
```

### 5.2 Test Application via ALB

```bash
# Get ALB DNS from Terraform output
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test HTTP to HTTPS redirect
curl -I http://$ALB_DNS

# Test HTTPS (might show certificate error in curl, that's ok)
curl -I https://$ALB_DNS -k
```

### 5.3 Test S3 Assets

```bash
# Replace with your bucket name
curl -I https://elegant-cakeshop-public-YOURNAME.s3.us-east-1.amazonaws.com/css/style.css

# Should return HTTP 200
```

### 5.4 Test Database Connection

```bash
# SSH into EC2
ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip

# Test database from EC2
mysql -h your-rds-endpoint.rds.amazonaws.com \
      -u admin \
      -p cakeshop_db \
      -e "SELECT 1"
```

## 🌐 Access Your Application

Your application is now accessible at:
```
https://<alb-dns-name>
```

From AWS Console:
1. Go to **EC2 → Load Balancers**
2. Find **elegant-cakes-alb**
3. Copy the **DNS name**
4. Visit in browser: `https://your-alb-dns-name`

## 📊 Monitor Application

### View Application Logs

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
pm2 logs elegant-cakes
```

### View Cloud-Init Setup Logs

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
tail -f /var/log/cloud-init-output.log
```

### View RDS Metrics

```bash
aws rds describe-db-instances \
  --db-instance-identifier cakeshop-db \
  --region us-east-1
```

## 🗑️ Cleanup (Destroy Everything)

To delete all AWS resources and stop incurring charges:

```bash
terraform destroy
```

When prompted:
```
yes
```

## ❌ Troubleshooting

### Terraform plan fails
```bash
terraform validate
aws sts get-caller-identity
```

### Cannot SSH into EC2
```bash
# Check key permissions
chmod 400 your-key.pem

# Verify security group allows SSH from your IP
aws ec2 describe-security-groups --group-names "Elegant-Cakes-WebAccess" --region us-east-1
```

### Application not running
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
pm2 logs elegant-cakes
pm2 status
```

### RDS connection timeout
```bash
# Check RDS security group
aws ec2 describe-security-groups --group-names "Elegant-Cakes-DB-SG" --region us-east-1

# Test from EC2
mysql -h rds-endpoint -u admin -p
```

### S3 returns 403 Forbidden
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket elegant-cakeshop-public-YOURNAME --region us-east-1

# Re-sync files with public-read ACL
aws s3 sync ./public s3://elegant-cakeshop-public-YOURNAME/ --region us-east-1 --acl public-read
```

## 📞 Help & Resources

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Docs**: https://docs.aws.amazon.com/
- **GitHub Issues**: https://github.com/abrarsyedd/elegant-cakeshop/issues

---

**Congratulations! Your 3-tier application is now live on AWS! 🚀**
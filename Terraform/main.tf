provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "app-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                 = 2
  vpc_id                = aws_vpc.main.id
  cidr_block            = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone     = element(["${var.aws_region}a", "${var.aws_region}b"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone = element(["${var.aws_region}a", "${var.aws_region}b"], count.index)
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.31.6"
  cluster_name    = "app-cluster"
  cluster_version = "1.31"
  vpc_id          = aws_vpc.main.id
  subnet_ids      = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)

  tags = {
    Name = "app-eks-cluster"
    Environment = "stage"
    Terraform   = "true"
  }
}


# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.2"
  instance_class          = "db.t3.micro"
  db_name                    = "appdb"
  username                = "appuser"
  password                = var.db_password
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [module.eks.cluster_security_group_id]
  skip_final_snapshot     = true # Skip the final snapshot during deletion
  tags = { Name = "app-database" }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "app-rds-subnet-group" }
}

# S3 Bucket for React Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "app-frontend-bucket"
  tags   = { Name = "app-frontend-bucket" }
  # region = "us-east-1"
}

resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-origin"
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    target_origin_id = "S3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = {
    Name = "app-cloudfront-distribution"
  }
}



# # Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "main-igw"
#   }
# }
#
# # Route Table for Public Subnets
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "public-route-table"
#   }
# }
#
# resource "aws_route" "public_internet_access" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.main.id
# }
#
# resource "aws_route_table_association" "public" {
#   count          = 2
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
#
# # NAT Gateway for Private Subnets
# resource "aws_eip" "nat" {
#   tags = {
#     Name = "nat-eip"
#   }
# }
#
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
#   tags = {
#     Name = "main-nat-gw"
#   }
# }
#
# # Route Table for Private Subnets
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "private-route-table"
#   }
# }
#
# resource "aws_route" "private_nat_access" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.main.id
# }
#
# resource "aws_route_table_association" "private" {
#   count          = 2
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }
#
# # Security Group for EKS
# resource "aws_security_group" "eks" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "eks-sg"
#   }
# }
#
# # S3 Bucket for Frontend
# # S3 Bucket Definition
# resource "aws_s3_bucket" "frontend_bucket" {
#   bucket = "frontend-bucket-testing"
#
#   tags = {
#     Name = "frontend-bucket"
#   }
# }
#
# # Configure Public Access Block
# resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
#   bucket                  = aws_s3_bucket.frontend_bucket.id
#   block_public_acls       = true
#   block_public_policy     = false  # Allow public policies
#   ignore_public_acls      = true
#   restrict_public_buckets = false
# }
#
# # Add Bucket Policy for Public Read Access
# resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
#   bucket = aws_s3_bucket.frontend_bucket.id
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject",
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "s3:GetObject",
#         Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
#       }
#     ]
#   })
# }
#
# # Configure Static Website Hosting
# resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
#   bucket = aws_s3_bucket.frontend_bucket.id
#
#   index_document {
#     suffix = "index.html"
#   }
#
#   error_document {
#     key = "error.html"
#   }
# }
#
#
#
# # CloudWatch Log Group
# resource "aws_cloudwatch_log_group" "eks_logs" {
#   name              = "/aws/eks/app-logs"
#   retention_in_days = 30
# }
#
# # RDS PostgreSQL Instance
# resource "aws_db_instance" "postgres" {
#   identifier              = "spring-boot-db"
#   allocated_storage       = 20
#   instance_class          = "db.t3.micro"
#   engine                  = "postgres"
#   engine_version          = "13.4"
#   username                = "springuser"
#   password                = var.db_password
#   db_subnet_group_name    = aws_db_subnet_group.main.name
#   vpc_security_group_ids  = [aws_security_group.rds_sg.id]
#   skip_final_snapshot     = true
#   publicly_accessible     = false
#   storage_encrypted       = true
# }
#
# # RDS Subnet Group
# resource "aws_db_subnet_group" "main" {
#   name       = "rds-subnet-group"
#   subnet_ids = aws_subnet.private[*].id
#
#   tags = {
#     Name = "rds-subnet-group"
#   }
# }
#
# # RDS Security Group
# resource "aws_security_group" "rds_sg" {
#   vpc_id = aws_vpc.main.id
#
#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # Restrict access to VPC
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# GcU1IvnXCxobAaVXze9WdUjA4cKBSDCurhCYYHxy
# AKIAS27DARWGU7O6W6G3

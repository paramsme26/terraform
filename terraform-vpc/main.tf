# Resource-1: VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidrs-block[0]
   tags = {
    Name = "${var.name}-${var.env[0]}"
    Project = "${var.project}"
    Terraform = "${var.terraform[0]}"

  }
}

# Resource-2: Public-Subnet-1

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc-cidrs-block[1]
  availability_zone = var.az["cal-az-1"]
  tags = {
    Name = "Main"
  }
}

# Resource-3: Public-Subnet-2

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc-cidrs-block[2]
  availability_zone = var.az["cal-az-2"]
  tags = {
    Name = "Main"
  }
}

# Resource-4: Private-Subnet-1

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc-cidrs-block[3]
  availability_zone = var.az["cal-az-1"]
  tags = {
    Name = "Main"
  }
}

# Resource-5: Private-Subnet-2

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc-cidrs-block[4]
  availability_zone = var.az["cal-az-2"]
  tags = {
    Name = "Main"
  }
}

# Resource-6: S3 Bucket

resource "aws_s3_bucket" "b" {
  bucket = "${var.name}"

  tags = {
    Name = trim("${var.name}-${var.env[0]}","parampreet-")
  }
}
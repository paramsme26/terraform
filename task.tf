# Terraform Block

terraform {
  required_version = "~> 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
  }

}

# Providers Block

provider "aws" {
  profile = "pam"
  region  = "us-west-1"
}

#variables

variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "us-west-1"
}


variable "EnvirnomentName"{
    description = "An environment name that is prefixed to resource names"
    type =  list(string)
	  default= ["dev", "prod", "stage"]
}

variable "availability_zone" {
  description = "Availiability Zones"
  type        = map(any)
  default = {
    "az-1" = "us-west-1c"
    "az-2" = "us-west-1b"
      }
}

variable "vpc_cidr" {
  
    type = string
	default = "10.192.0.0/16"
}

variable "PublicSubnet1CIDR" {
	type = string
	default = "10.192.10.0/24"
}

variable "PublicSubnet2CIDR" {
	type = string
	default = "10.192.11.0/24"
}

variable "PrivateSubnet1CIDR" {
	type = string
	default = "10.192.20.0/24"
}

variable "PrivateSubnet2CIDR" {
	type = string
	default = "10.192.21.0/24"
}


# Resource-1: VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
  Name = var.EnvirnomentName[0]

  }
}




#Resource-4:INTERNET GATEWAY 

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = var.EnvirnomentName[0]
    }
}




# Resource-6: Public-Subnet-1

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PublicSubnet1CIDR
  availability_zone = var.availability_zone["az-1"]
  map_public_ip_on_launch = true
  tags = {
    Name = var.EnvirnomentName[0]
  }
}

# Resource-7: Public-Subnet-2

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PublicSubnet2CIDR
  availability_zone = var.availability_zone["az-2"]
  map_public_ip_on_launch = true

  tags = {
    Name = var.EnvirnomentName[0]
  }
}

# Resource-8: Private-Subnet-1

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PrivateSubnet1CIDR
  availability_zone = var.availability_zone["az-1"]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.EnvirnomentName[0]}"
  }
}

# Resource-9: Private-Subnet-2

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.PrivateSubnet2CIDR
  availability_zone = var.availability_zone["az-2"]
  map_public_ip_on_launch = false
  tags = {
    Name = var.EnvirnomentName[0]
  }
}

#Elastic IP

resource "aws_eip" "NatGatewayEIP1" {
  vpc = true
}

resource "aws_eip" "NatGatewayEIP2" {
  vpc = true
}



# Resource-10:nat gateway1:

resource "aws_nat_gateway" "NatGateway1" {
  allocation_id = aws_eip.NatGatewayEIP1.id
  subnet_id     = aws_subnet.private-subnet-1.id 

}

# Resource-11:nat gateway2:

resource "aws_nat_gateway" "NatGateway2" {
  allocation_id = aws_eip.NatGatewayEIP2.id
  subnet_id     = aws_subnet.private-subnet-2.id 

}

#Resource-12:route tables and routes

resource "aws_route_table" "PublicRouteTable1" {
  vpc_id = aws_vpc.main.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
   
  }
  tags = {
    Name = "MyRoute"
  }
}


#Resource-13:route tables and routes


resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.main.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
   
  }
  tags = {
    Name = "MyRoute"
  }
}


# public subnet routetable association 1

resource "aws_route_table_association" "PublicSubnet1RouteTable" {
subnet_id = aws_subnet.public-subnet-1.id
route_table_id = aws_route_table.PublicRouteTable1.id

}

# public subnet routetable association 2

resource "aws_route_table_association" "PublicSubnet2RouteTable" {
subnet_id = aws_subnet.public-subnet-2.id
route_table_id = aws_route_table.PublicRouteTable1.id

}

#private route table

resource "aws_route_table" "PrivateRouteTable_1" {
   vpc_id = aws_vpc.main.id
   route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.NatGateway1.id

   }
}

# private subnet routetable association 2




resource "aws_route_table" "PrivateRouteTable_2" {
  vpc_id = aws_vpc.main.id
  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NatGateway2.id
  }
}

resource "aws_route_table_association" "PrivateSubnet2RouteTable" {
subnet_id = aws_subnet.public-subnet-2.id
route_table_id = aws_route_table.PublicRouteTable1.id

}


# security Group

resource "aws_security_group" "NoIngressSecurityGroup" {
   name = "n0-ingress-sg"
   description = "security Group"
   vpc_id = "${aws_vpc.main.id}"

}


#OUTPUTS

output "VPC"{
    value = aws_vpc.main.id
}

output "PublicSubnets" {
  value = join(", ", ["${aws_subnet.PublicSubnet1.id}", "${aws_subnet.PublicSubnet2.id}"])
}

output "PrivateSubnets" {
  value = join(", ", ["${aws_subnet.PrivateSubnet1.id}", "${aws_subnet.PrivateSubnet2.id}"])
}

output "PublicSubnet1" {
    value = aws_subnet.public-subnet-1.id
}

output "PublicSubnet2" {
    value = aws_subnet.public-subnet-2.id
}

output "PrivateSubnet1" {
    value = aws_subnet.private-subnet-1.id
}

output "PrivateSubnet2" {
    value = aws_subnet.private-subnet-2.id
}

output "NoIngressSecurityGroup" {
    value = aws_security_group.NoIngressSecurityGroup.id

}


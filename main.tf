 
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "my_vpc"
  }
} 
# Create  public subnet for  the infrastructure
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = " Public Subnet"
  }
}
# create private subnet 
resource "aws_subnet" "private_subnet" {
    vpc_id            = aws_vpc.my_vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
     Name = " Private Subnet"
   }
}

# Attach an internet gateway to the VPC
resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "frist Internet Gateway"
  }
}   


resource "aws_route_table" "public_rt" {
    vpc_id      = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_ig.id
    }
    tags = {
    Name = "Public Route Table"
   }
}   
# associate route table tp public subnet
resource "aws_route_table_association" "public_rt2" {
    subnet_id        = aws_subnet.public_subnet.id
    route_table_id   = aws_route_table.public_rt.id
}
# create security group 
resource "aws_security_group" "web_sg" {
    name   = "HTTP and SSH"
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        from_port  = 80
        to_port    = 80
        protocol   = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port  = -1
        to_port    = -1
        protocol   = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port  = 22
        to_port    = 22
        protocol   = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port  = 0
        to_port    = 0
        protocol   = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}
   
# create EC2 Instance on the subnet
resource "aws_instance" "web_instance" {
    ami          = "ami-0533f2ba8a1995cf9"
    instance_type = "t2.micro"
    key_name     = "MyKeyPair"
   
    subnet_id    = aws_subnet.public_subnet.id
    vpc_security_group_ids  = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    

  }


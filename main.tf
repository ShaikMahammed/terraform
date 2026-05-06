#Vpc
resource "aws_vpc" "vpc01" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "tf-vpc"
  }
}

#Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc01.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-public-subnet"
  }
}
#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "tf-igw"
  }
}
#Route Table of IGW for Public Subnet
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc01.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "tf-public-route"
  }
}
#route table association 
resource "aws_route_table_association" "table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
# Ec2 instance
resource "aws_instance" "web_instance" {
  ami = "ami-0c2af51e265bd5e0e" 
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_instance.id]
  tags = {
    Name = "web001"
  }
}
#Security Group
resource "aws_security_group" "sg_instance" {
  #ssh
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTP
  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-sg"
  }
}

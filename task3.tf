provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_vpc" "at_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "at_vpc"
  }
}

resource "aws_subnet" "at_subnet1" {
  vpc_id     = "${aws_vpc.at_vpc.id}"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "at_subnet1"
  }
}

resource "aws_subnet" "at_subnet2" {
  vpc_id     = "${aws_vpc.at_vpc.id}"
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "at_subnet2"
  }
}
resource "aws_internet_gateway" "at_gw" {
  vpc_id = "${aws_vpc.at_vpc.id}"

  tags = {
    Name = "at_gw"
  }
}

resource "aws_route_table" "at_r" {
  vpc_id = "${aws_vpc.at_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.at_gw.id}"
  }

  
  tags = {
    Name = "at_r"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.at_subnet1.id
  route_table_id = aws_route_table.at_r.id
}


resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow port 22 and 80 "
  vpc_id      = "${aws_vpc.at_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}

resource "aws_security_group" "sg2" {
  name        = "sg2"
  description = "Allow port 3306 "
  vpc_id      = "${aws_vpc.at_vpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg2"
  }
}

resource "aws_instance" "wp" {
  ami           = "ami-7e257211"
  instance_type = "t2.micro"
  key_name = "key1"
  subnet_id = "${aws_subnet.at_subnet1.id}"
  vpc_security_group_ids = [aws_security_group.sg1.id]

  tags = {
      Name = "wp"
  }
}

resource "aws_instance" "sql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "key1"
  subnet_id = "${aws_subnet.at_subnet2.id}"
  vpc_security_group_ids = [aws_security_group.sg2.id]

  tags = {
      Name = "sql"
  }
}
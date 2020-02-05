# Configure the AWS Provider
provider "aws" {
  region     = "${var.region}"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"

}

# ec2 instance
resource "aws_instance" "nezmur" { 
  ami             = "${var.imageid}"
  instance_type   = "${var.instancetype}"
  security_groups = ["${aws_security_group.allow_all.name}"]

  
}

# Create VPC
resource "aws_vpc" "g_ting" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "PubPriv_VPC"
  }
}

#Create VPC public subnet
resource "aws_subnet" "public_subnet_us_east_2a" {
  vpc_id                  = "${aws_vpc.g_ting.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
  	Name =  "G_public_ting_in_east2a"
  }
}

#Create VPC private subnet x2
resource "aws_subnet" "private1_subnet_us_east_2a" {
  vpc_id                  = "${aws_vpc.g_ting.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
  	Name =  "G_ting_private1_in_east2a"
  }
}

resource  "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpcid}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
   
  }
  tags = {
    Name = "allow_all"
  }
}

resource "aws_subnet" "private2_subnet_us_east_2a" {
  vpc_id                  = "${aws_vpc.g_ting.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
  	Name =  "G_ting_private2_in_east2a"
  }
}

#elastic ip
resource "aws_eip" "g_ting_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gting_gw"]
}
#IGW
resource "aws_internet_gateway" "gting_gw" {
  vpc_id = "${aws_vpc.g_ting.id}"
tags = {
    Name = "IGW"
}

}
#nat gateway
resource "aws_nat_gateway" "gting_nat" {
  allocation_id = "${aws_eip.g_ting_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet_us_east_2a.id}"
  depends_on    = ["aws_internet_gateway.gting_gw"]

  tags = {
    Name = "g-ting NAT"
  }
}

#Route to the internet

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.g_ting.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gting_gw.id}"



}

#private route table 
resource "aws_route_table" "proute_gting" {
    vpc_id = "${aws_vpc.g_ting.id}"

    tags = {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.proute_gting.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.gting_nat.id}"
}

#Create Route Table Associations 

resource "aws_route_table_association" "public_subnet_us_east_2a_association" {
    subnet_id = "${aws_subnet.public_subnet_us_east_2a.id}"
    route_table_id = "${aws_vpc.g_ting.main_route_table_id}"
}
resource "aws_route_table_association" "private1_subnet_us_east_2a" {
    subnet_id = "${aws_subnet.private1_subnet_us_east_2a.id}"
    route_table_id = "${aws_route_table.proute_gting.id}"
}
resource "aws_route_table_association" "private2_subnet_us_east_2a" {
    subnet_id = "${aws_subnet.private2_subnet_us_east_2a.id}"
    route_table_id = "${aws_route_table.proute_gting.id}"
}
provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = ".aws/credentials"
  profile                 = "terraform"
}

variable "enabled" {
    type = "string"
    default = "1"
}



resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

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
}

resource "aws_instance" "mysql" {
  count = "${var.enabled}"
  ami = "ami-0bdf93799014acdc4"
  instance_type = "t2.micro"
  key_name = "linux"
  tags {
    Name = "mysql.priv"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  subnet_id = "${aws_subnet.sn-private.id}"
  private_ip = "172.16.0.70"
  associate_public_ip_address = true
}

resource "aws_instance" "be" {
  count = "${var.enabled}"
  ami = "ami-0bdf93799014acdc4"
  instance_type = "t2.micro"
  key_name = "linux"
  tags {
    Name = "be"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  subnet_id = "${aws_subnet.sn-public.id}"
  private_ip = "172.16.0.11"
}



resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/24"
  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw-vpc"
  }
}

resource "aws_subnet" "sn-private" {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "172.16.0.64/26"
    availability_zone = "eu-central-1a"

    tags {
        Name = "sn-privat"
    }
}

resource "aws_subnet" "sn-public" {
    vpc_id = "${aws_vpc.vpc.id}"
    map_public_ip_on_launch  = true
    cidr_block = "172.16.0.0/26"
    availability_zone = "eu-central-1a"

    tags {
        Name = "sn-public"
    }
}

resource "aws_route_table" "rtb" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "rtb-vpc"
    }
}

resource "aws_route_table_association" "rtb-sn-association" {
    subnet_id = "${aws_subnet.sn-public.id}"
    route_table_id = "${aws_route_table.rtb.id}"
}
resource "aws_route_table_association" "rtb-sn-priv-association" {
    subnet_id = "${aws_subnet.sn-private.id}"
    route_table_id = "${aws_route_table.rtb.id}"
}



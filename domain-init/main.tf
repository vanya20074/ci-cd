provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  profile                 = "terraform"
}


resource "aws_instance" "jump" {
  ami = "ami-0bdf93799014acdc4"
  instance_type = "t2.micro"
  tags {
    Name = "JUMP"
  }
  disable_api_termination = "true" 
  iam_instance_profile = "ec2-full-access-role" 
}

resource "aws_route53_record" "www" {
  zone_id = "Z3H0VLRUQXW7E4"
  name    = "anekdot.cf"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jump.public_ip}"]
}

variable "key_name" {}
variable "sg_id" {}
variable "iam_id" {}
variable "public_subnet_id" {}
variable "instance_type" {}
variable "ami" {}

resource "aws_instance" "demo" {
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"

  tags = {
    Name = "Demo"
  }

  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg_id}"]
  iam_instance_profile   = "${var.iam_id}"
  subnet_id              = "${var.public_subnet_id}"
  associate_public_ip_address = true
  user_data = <<-EOF
	#!/bin/bash
	yum install httpd -y
	service httpd start
	echo "Hello world" > /var/www/html/index.html
	EOF
}

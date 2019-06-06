variable "key_name" {}
variable "sg_id" {}
variable "iam_id" {}
variable "public_subnet_id" {}
variable "azs" {}
variable "instance_type" {}
variable "ami" {}

resource "aws_instance" "demo" {
  count=2
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"

  tags = {
    Name = "Demo"
  }

  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg_id}"]
  iam_instance_profile   = "${var.iam_id}"
  subnet_id              = "${element(split(",", var.public_subnet_id),count.index+1)}"
  associate_public_ip_address = true
  user_data = <<-EOF
	#!/bin/bash
	yum install httpd -y
	service httpd start
	echo "Hello world from subnet ${element(split(",", var.public_subnet_id),count.index+1)}" > /var/www/html/index.html
	EOF
}

resource "aws_elb" "demo_elb" {
  name               = "demo-elb"
  subnets              = "${split(",",var.public_subnet_id)}"
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  security_groups=["${var.sg_id}"]
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 5
  }

  instances                   = "${aws_instance.demo.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "demo-elb"
  }
}


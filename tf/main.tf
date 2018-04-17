terraform {
  backend "s3" {
      bucket = "ctindel-squirrel"
      key = "tf/terraform.tfstate"
      region = "us-east-2"
  }
}

provider "aws" {
    region = "us-east-2"
}

variable name {
  default = "ctindel-squirrel"
  description = "The environment name; used as a prefix when naming resources."
}

variable unixid {
  default = "ctindel"
  description = "SA Unix Username"
}

variable ec2_instance_type {
  default = "t2.nano"
  description = "The EC2 instance type to use"
}

variable region {
  default = "us-east-2"
  description = "The AWS Region to use"
}

variable env {
  default = "prod"
  description = "dev/prod"
}

data "aws_ami" "ctindel-squirrel-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["ctindel-squirrel"]
  }
  owners = ["self"]
}

resource "aws_default_vpc" "default" {
    tags {
        Name = "Default VPC"
    }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"

    tags {
        Name = "Default subnet for us-east-2a"
    }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-2b"

    tags {
        Name = "Default subnet for us-east-2b"
    }
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = "us-east-2c"

    tags {
        Name = "Default subnet for us-east-2c"
    }
}

resource "aws_security_group" "ctindel-squirrel-sg" {
  name = "ctindel-squirrel-sg"
  description = "Allow inbound SSH traffic and web traffic"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ctindel-squirrel-lc" {
    name_prefix = "ctindel-squirrel-"
    image_id = "${data.aws_ami.ctindel-squirrel-ami.id}"
    instance_type = "${var.ec2_instance_type}"
    associate_public_ip_address = true
    key_name = "ctindel_elastic"
    security_groups = [ "${aws_security_group.ctindel-squirrel-sg.id}" ]

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "30"
    }
}

resource "aws_autoscaling_group" "ctindel-squirrel-asg" {
  name = "ctindel-squirrel-asg"
  max_size = "1"
  min_size = "1"
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 1
  force_delete = false
  launch_configuration = "${aws_launch_configuration.ctindel-squirrel-lc.name}"
  vpc_zone_identifier = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}", "${aws_default_subnet.default_az3.id}"]

  tag {
    key = "Name"
    value = "${var.name}-${var.env}"
    propagate_at_launch = true
  }

  tag {
    key = "env"
    value = "${var.env}"
    propagate_at_launch = true
  }
}

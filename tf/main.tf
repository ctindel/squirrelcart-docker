terraform {
  backend "s3" {
      bucket = "hoffman-house.com"
      key = "tf/terraform.tfstate"
      region = "us-east-2"
  }
}

provider "aws" {
    region = "us-east-2"
}

variable name {
  default = "hh-app"
  description = "The environment name; used as a prefix when naming resources."
}

variable unixid {
  default = "sah"
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

variable r53_domain {
  default = "hoffman-house.com"
  description = "domain"
}

variable "r53_zone_id" {
  default = "Z3NM2RE1EBLTT5"
}

data "aws_ami" "hh-squirrel-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["hh-squirrel-${var.env}"]
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

resource "aws_route53_record" "hoffman-house_com" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.r53_domain}"
  type    = "A"
  ttl     = "86048"
  records = ["162.215.248.217"]
}

resource "aws_route53_record" "www_hoffman-house_com" {
  zone_id = "${var.r53_zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "86048"
  records = ["${var.r53_domain}"]
}

resource "aws_route53_record" "mail_hoffman-house_com" {
  zone_id = "${var.r53_zone_id}"
  name    = "mail"
  type    = "CNAME"
  ttl     = "86048"
  records = ["shared49.accountservergroup.com"]
}

resource "aws_route53_record" "hoffman-house_mx" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.r53_domain}"
  type    = "MX"
  ttl     = "3600"
  records = ["0 mail.hoffman-house.com",
             "10 shared49.accountservergroup.com"]
}

resource "aws_security_group" "hh-squirrel-sg" {
    name = "hh-squirrel-sg"
    description = "Allow inbound SSH traffic and web traffic"
    vpc_id = "${aws_default_vpc.default.id}"
  
    ingress {
      from_port = 0
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      from_port = 0
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      from_port = 0
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "hh-sg-${var.env}"
    }
}

resource "aws_ebs_volume" "data" {
    availability_zone = "us-east-2a"
    size = 1
    encrypted = true
    tags {
        Name = "hh-mysql-${var.env}"
    }
}

resource "aws_launch_configuration" "hh-squirrel-lc" {
    name_prefix = "hh-squirrel-"
    image_id = "${data.aws_ami.hh-squirrel-ami.id}"
    instance_type = "${var.ec2_instance_type}"
    associate_public_ip_address = true
    key_name = "hh-20180608"
    security_groups = [ "${aws_security_group.hh-squirrel-sg.id}" ]
    user_data = "${data.template_cloudinit_config.hh-squirrel-user-data.rendered}"

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "20"
    }
}

resource "aws_autoscaling_group" "hh-squirrel-asg" {
  name = "hh-squirrel-asg"
  max_size = "1"
  min_size = "1"
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 1
  force_delete = false
  launch_configuration = "${aws_launch_configuration.hh-squirrel-lc.name}"
  # We only run in 1 AZ because we have to create the mysql EBS volume in a specific AZ
  vpc_zone_identifier = ["${aws_default_subnet.default_az1.id}"]

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

data "template_file" "hh-squirrel-user-data" {
  template = "${file("${path.module}/user_data.yml")}"

  vars {
    aws_region = "${var.region}"
    env = "${var.env}"
    hostname = "${var.name}"
    hh_dns_domain = "${var.env}.${var.r53_domain}"
    update_route53_mapping_service = "${file("${path.module}/update_route53_mapping.service")}"
    squirrelcart_service = "${file("${path.module}/squirrelcart.service")}"
    squirrelcart_backup_service = "${file("${path.module}/squirrelcart_backup.service")}"
    squirrelcart_backup_timer = "${file("${path.module}/squirrelcart_backup.timer")}"
    squirrelcart_cert_service = "${file("${path.module}/squirrelcart_cert.service")}"
    squirrelcart_cert_timer = "${file("${path.module}/squirrelcart_cert.timer")}"
    start_squirrel_sh = "${file("${path.module}/start_squirrel.sh")}"
    backup_squirrel_sh = "${file("${path.module}/backup_squirrel.sh")}"
    generate_cert_sh = "${file("${path.module}/generate_cert.sh")}"
    nginx_conf = "${file("${path.module}/nginx.conf")}"
    nginx_http_conf = "${file("${path.module}/nginx.http.conf")}"
    nginx_https_conf = "${file("${path.module}/nginx.https.conf")}"
    setup_storage_sh = "${file("${path.module}/setup_storage.sh")}"
    squirrel_docker_compose = "${file("${path.module}/../docker-compose.yml")}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "hh-squirrel-user-data" {
  gzip          = true
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.hh-squirrel-user-data.rendered}"
  }
}

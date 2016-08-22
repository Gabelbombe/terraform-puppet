#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>#
# ELB Security Groups
#
# Puppet CA ELB
resource "aws_security_group" "puppetca_elb" {
  name                  = "${var.owner}_puppet_puppetca_elb_sg"
  description           = "Puppet CA ELB SG"
  vpc_id                = "${aws_vpc.default.id}"

  # HTTPS from all
  ingress {
    from_port           = 8140
    to_port             = 8140
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  # Allows outbound traffic
  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  tags {
    Name                = "${var.owner}_puppet_puppetca_elb_sg"
    Owner               = "${var.owner}"
  }
}

# PuppetDB ELB
resource "aws_security_group" "puppetdb_elb" {
  name                  = "${var.owner}_puppet_puppetdb_elb_sg"
  description           = "Puppet DB ELB SG"
  vpc_id                = "${aws_vpc.default.id}"

  # HTTPS from all
  ingress {
    from_port           = 8081
    to_port             = 8081
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  # Allows outbound traffic
  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  tags {
    Name                = "${var.owner}_puppet_puppetdb_elb_sg"
    Owner               = "${var.owner}"
  }
}

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>#
# Instances Security Group
#
# Default SG
resource "aws_security_group" "default" {
  name                  = "${var.owner}_puppet_default_sg"
  description           = "Default SG for Puppet VPC"
  vpc_id                = "${aws_vpc.default.id}"

  # SSH within the VPC
  ingress {
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = ["${aws_vpc.default.cidr_block}"]
  }

  # ICMP within the VPC
  ingress {
    from_port           = -1
    to_port             = -1
    protocol            = "icmp"
    cidr_blocks         = ["${aws_vpc.default.cidr_block}"]
  }

  # Allows outbound traffic
  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  tags {
    Name                = "${var.owner}_puppet_default_sg"
    Owner               = "${var.owner}"
  }
}

# Bastion host SG
resource "aws_security_group" "bastion" {
  name                  = "${var.owner}_puppet_bastion_sg"
  description           = "Manages Bastion host traffic"
  vpc_id                = "${aws_vpc.default.id}"

  # SSH from all
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name  = "${var.owner}_puppet_bastion_sg"
    Owner = "${var.owner}"
  }
}

# PuppetDB SG
resource "aws_security_group" "puppetdb" {
  name        = "${var.owner}_puppet_puppetdb_sg"
  description = "PuppetDB SG"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTPS from VPC
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }

  # HTTPS from ELB
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = ["${aws_security_group.puppetdb_elb.id}"]
  }

  tags {
    Name  = "${var.owner}_puppet_puppetdb_sg"
    Owner = "${var.owner}"
  }
}

# PuppetCA SG
resource "aws_security_group" "puppetca" {
  name        = "${var.owner}_puppet_puppetca_sg"
  description = "PuppetDB SG"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTPS from VPC
  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }

  # HTTPS from ELB
  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    security_groups = ["${aws_security_group.puppetca_elb.id}"]
  }

  tags {
    Name  = "${var.owner}_puppet_puppetca_sg"
    Owner = "${var.owner}"
  }
}

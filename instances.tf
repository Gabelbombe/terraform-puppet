#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>#
# Puppet CA Instance
#
resource "aws_instance" "puppetca" {
  ami                     = "${lookup( var.amis_ubuntu_140404, var.region )}"
  instance_type           = "${var.instance_puppetca}"
  subnet_id               = "${aws_subnet.private_subnet.0.id}"
  key_name                = "${aws_key_pair.default.key_name}"
  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 1
    encrypted             = true
    delete_on_termination = false
  }
  security_groups         = ["${aws_security_group.default.id}","${aws_security_group.puppetca.id}"]
  user_data               = "${template_cloudinit_config.puppetca.rendered}"
  tags {
    Name                  = "${var.vdc}-puppetca01"
    Owner                 = "${var.owner}"
  }
}

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>#
# Puppet DB Instances
#
##NOTE: Placeholders to test setup ~jd
resource "aws_instance" "puppetdb" {
  ami                         = "${lookup( var.amis_ubuntu_140404, var.region )}"
  instance_type               = "${var.instance_puppetdb}"
  subnet_id                   = "${element( aws_subnet.private_subnet.*.id, count.index )}"
  key_name                    = "${aws_key_pair.default.key_name}"
  security_groups             = ["${aws_security_group.default.id}","${aws_security_group.puppetdb.id}"]
  user_data                   = "${element(template_cloudinit_config.puppetdb.*.rendered, count.index)}"
  count                       = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  tags {
    Name                      = "${var.vdc}-puppetdb0${count.index+1}"
    Owner                     = "${var.owner}"
  }
}

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>#
# Bastion
#
resource "aws_instance" "bastion" {
  ami                         = "${lookup( var.amis_ubuntu_140404, var.region )}"
  instance_type               = "${var.instance_bastion}"
  subnet_id                   = "${aws_subnet.public_subnet.0.id}"
  key_name                    = "${aws_key_pair.default.key_name}"
  security_groups             = ["${aws_security_group.default.id}","${aws_security_group.bastion.id}"]
  user_data                   = "${template_cloudinit_config.bastion.rendered}"
  associate_public_ip_address = true
  tags {
    Name                      = "${var.vdc}-bastion01"
    Owner                     = "${var.owner}"
  }
}

# This terraform file defines the bare basics needed to do anything useful in AWS.
# You will get a VPC (your network), a pair of public subnets, a pair of private 
# subnets (all private addresses netmask 255.255.128.0), a network address 
# translation (NAT) EC2 instance, and an SSH bastion host for creating SSH tunnels
# to your private IP addresses as needed.

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "sandbox-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# NAT instance
resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow services from the private subnet through NAT"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.private-A.cidr_block}"]
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.private-B.cidr_block}"]
  }

  vpc_id = "${aws_vpc.default.id}"
}

#resource "aws_instance" "nat" {
#  tags {
#    Name = "nat"
#  }
#  ami = "${var.nat_ami}"
#  availability_zone = "${var.zone_A}"
#  instance_type = "t2.micro"
#  key_name = "${var.key_name}"
#  security_groups = ["${aws_security_group.nat.id}"]
#  subnet_id = "${aws_subnet.public-A.id}"
#  associate_public_ip_address = true
#  source_dest_check = false
#}

# Public subnets
resource "aws_subnet" "public-A" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.zone_A}"
}

resource "aws_subnet" "public-B" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.zone_B}"
}

# Routing table for public subnets
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "public-A" {
  subnet_id = "${aws_subnet.public-A.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-B" {
  subnet_id = "${aws_subnet.public-B.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Private subsets (all private IPs fall in netmask 255.255.128.0)
resource "aws_subnet" "private-A" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.129.0/24"
  availability_zone = "${var.zone_A}"
}

resource "aws_subnet" "private-B" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.131.0/24"
  availability_zone = "${var.zone_B}"
}

# Routing table for private subnets
#resource "aws_route_table" "private" {
#  vpc_id = "${aws_vpc.default.id}"
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    instance_id = "${aws_instance.nat.id}"
#  }
#}

resource "aws_route_table_association" "private-A" {
  subnet_id = "${aws_subnet.private-A.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-B" {
  subnet_id = "${aws_subnet.private-B.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Bastion
resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "Allow SSH traffic from the internet"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"
}

#resource "aws_instance" "bastion" {
#  tags {
#    Name = "bastion"
#  }
#  ami = "${var.bastion_ami}"
#  availability_zone = "${var.zone_A}"
#  instance_type = "t2.micro"
#  key_name = "${var.key_name}"
#  security_groups = ["${aws_security_group.bastion.id}"]
#  subnet_id = "${aws_subnet.public-A.id}"
#}

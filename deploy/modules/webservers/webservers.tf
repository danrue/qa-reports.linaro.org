variable "environment" {
    type = "string"
}
variable "vpc_id" {
    type = "string"
}
variable "subnet_ids" {
    type = "list"
}
variable "ssh_key_path" {
    type = "string"
}
variable "ami_id" {
    type = "string"
}



# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "qa-reports-lb" {
  name        = "${var.environment}-qa-reports.linaro.org"
  description = "SG between ELB and web servers"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "qa-reports-ec2" {
  name        = "${var.environment}-qa-reports ec2 default"
  description = "Default SG for qa-reports webservers"
  vpc_id      = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "qa-reports-lb" {
  name = "${var.environment}-qa-reports-lb"

  subnets = "${var.subnet_ids}"
  security_groups = ["${aws_security_group.qa-reports-lb.id}"]
}
resource "aws_lb_target_group" "qa-reports-tg" {
  name = "${var.environment}-qa-reports-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}
resource "aws_lb_listener" "qa-reports-lb-listener-80" {
  load_balancer_arn = "${aws_lb.qa-reports-lb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.qa-reports-tg.arn}"
    type             = "forward"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "qa-reports"
  public_key = "${file(var.ssh_key_path)}"
}

resource "aws_instance" "qa-reports-web" {
  connection {
    user = "ubuntu"
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"
  ami = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.qa-reports-ec2.id}"]
  subnet_id = "${var.subnet_ids[0]}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}

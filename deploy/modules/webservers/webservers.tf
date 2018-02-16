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
variable "route53_zone_id" {
    type = "string"
}
variable "route53_base_domain_name" {
    type = "string"
}

# A security group for the load balancer so it is accessible via the web
resource "aws_security_group" "qa-reports-lb-sg" {
  name        = "${var.environment}-qa-reports.linaro.org"
  description = "Security group for load balancer"
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

# Instance security group to access the instances over SSH and HTTP
resource "aws_security_group" "qa-reports-ec2-www" {
  name        = "${var.environment}-qa-reports ec2 www"
  description = "Default SG for qa-reports webservers"
  vpc_id      = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
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
  security_groups = ["${aws_security_group.qa-reports-lb-sg.id}"]
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
resource "aws_route53_record" "qa-reports-lb-dns" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.environment}-qa-reports.${var.route53_base_domain_name}"
  type = "A"
  alias {
    name = "${aws_lb.qa-reports-lb.dns_name}"
    zone_id = "${aws_lb.qa-reports-lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "qa-reports"
  public_key = "${file(var.ssh_key_path)}"
}

resource "aws_instance" "qa-reports-www" {
  connection {
    user = "ubuntu"
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"
  ami = "${var.ami_id}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.qa-reports-ec2-www.id}"]
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

resource "aws_lb_target_group_attachment" "qa-reports-www-lb" {
  target_group_arn = "${aws_lb_target_group.qa-reports-tg.arn}"
  target_id = "${aws_instance.qa-reports-www.id}"
  port = 80
}

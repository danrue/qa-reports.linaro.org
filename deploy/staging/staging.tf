# Store state file in S3
# This has to be hard coded because it is loaded before anything else.
terraform {
  backend "s3" {
    bucket = "linaro-terraform-state"
    key = "qa-reports/staging/terraform.tfstate"
    region = "us-east-1"
  }
}

variable "environment" {
  type = "string"
  default = "staging"
}

# Discover VPC from cidr
data "aws_vpc" "selected" {
  cidr_block = "172.31.0.0/16"
}
variable "availability_zones" {
  type = "list"
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}
# Discover subnets from cidr
data "aws_subnet" "us-east-1a" {
  cidr_block = "172.31.1.0/24"
  availability_zone = "us-east-1a"
}
data "aws_subnet" "us-east-1b" {
  cidr_block = "172.31.2.0/24"
  availability_zone = "us-east-1b"
}
locals {
  availability_zone_to_subnet_map = {
    "us-east-1a" = "${data.aws_subnet.us-east-1a.id}",
    "us-east-1b" = "${data.aws_subnet.us-east-1b.id}"
  }
}

variable "ssh_key_path" {
  type = "string"
  default = "~/.ssh/qa-reports.pub"
}

variable "route53_zone_id" {
  type = "string"
  # ctt.linaro.org
  default = "Z27NRA2FV79C84"
}

variable "route53_base_domain_name" {
  type = "string"
  default = "ctt.linaro.org"
}

variable "ami_id" {
  type = "string"
  # us-east-1, 16.04LTS, hvm:ebs-ssd
  # see https://cloud-images.ubuntu.com/locator/ec2/
  default = "ami-0b383171"
}

provider "aws" {
  region = "us-east-1"
}

module "webservers" {
  source = "../modules/webservers"
  environment = "${var.environment}"
  vpc_id = "${data.aws_vpc.selected.id}"
  availability_zones = "${var.availability_zones}"
  availability_zone_to_subnet_map = "${local.availability_zone_to_subnet_map}"
  ssh_key_path = "${var.ssh_key_path}"
  ami_id = "${var.ami_id}"
  route53_zone_id = "${var.route53_zone_id}"
  route53_base_domain_name = "${var.route53_base_domain_name}"
}


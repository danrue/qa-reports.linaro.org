# Store state file in S3
# This has to be hard coded because it is loaded before anything else.
terraform {
  backend "s3" {
    bucket = "linaro-terraform-state"
    key = "qa-reports/staging/terraform.tfstate"
    region = "us-east-1"
  }
}

variable "route53_base_domain_name" { type = "string" }
variable "availability_zones" { type = "list" }
variable "environment" { type = "string" }
variable "availability_zone_to_subnet_map" { type = "map" }
variable "ssh_key_path" { type = "string" }
variable "ami_id" { type = "string" }
variable "route53_zone_id" { type = "string" }
variable "vpc_id" { type = "string" }
variable "region" { type = "string" }

provider "aws" {
  region = "${var.region}"
}

#module "rds" {
#  source = "modules/rds"
#  environment = "${var.environment}"
#}

module "webservers" {
  source = "modules/webservers"
  environment = "${var.environment}"
  vpc_id = "${var.vpc_id}"
  availability_zones = "${var.availability_zones}"
  availability_zone_to_subnet_map = "${var.availability_zone_to_subnet_map}"
  ssh_key_path = "${var.ssh_key_path}"
  ami_id = "${var.ami_id}"
  route53_zone_id = "${var.route53_zone_id}"
  route53_base_domain_name = "${var.route53_base_domain_name}"
}


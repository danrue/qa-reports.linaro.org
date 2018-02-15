variable "environment" {
    type = "string"
    default = "staging"
}

variable "vpc_id" {
    type = "string"
    default = "vpc-a13ba9d9"
}

variable "subnet_ids" {
    type = "list"
    default = ["subnet-85c308d8", "subnet-e820418c"]
}

variable "ssh_key_path" {
    type = "string"
    default = "~/.ssh/qa-reports.pub"
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

module "rds" {
    source = "../modules/rds"
    environment = "${var.environment}"
}

module "webservers" {
    source = "../modules/webservers"
    environment = "${var.environment}"
    vpc_id = "${var.vpc_id}"
    subnet_ids = "${var.subnet_ids}"
    ssh_key_path = "${var.ssh_key_path}"
    ami_id = "${var.ami_id}"
}

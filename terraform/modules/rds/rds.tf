variable "environment" {
    type = "string"
}

resource "aws_db_instance" "default" {
    allocated_storage = 20 # minimum
    engine = "postgres"
    instance_class = "db.t2.micro"
    name = "${var.environment}qareports"
    username = "drue"
    password = "1kU2BU2jpeUGjKCALq3WLXNXBSQ" # XXX
}

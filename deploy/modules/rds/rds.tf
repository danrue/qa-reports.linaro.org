variable "environment" {
    type = "string"
}

resource "aws_db_instance" "default" {
    allocated_storage = 20 # minimum
    engine = "postgresql"
    instance_class = "db.t2.micro"
    name = "${var.environment}-qa-reports"
    username = "drue"
    password = "1kU2BU2jpeUGjKCALq3WLXNXBSQ"
}

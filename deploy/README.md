# Terraform

- state is stored in s3

# Usage

terraform init
ssh-add ~/.ssh/qa-reports.pem
assume-ctt-admin 123456
terraform plan
terraform apply

# TODO

- Move state files to S3
  - manage the DB password for rds
- multiple webservers
- worker nodes
- db secret from ansible vault, pull from group vars
- ACM cert
- AZ colocation for web, workers, and rds

- ssh keys in repo for initial bootstrap
- rabbitmq on web host (master)
- rename to something better.. infrastructure/application? terraform/ansible?

- use discovery rather than hard coded strings
- set up prod
  - shared vars that span environments
- commit ansible inventory

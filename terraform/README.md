# Terraform

- state is stored in s3

# Usage

terraform init
ssh-add ~/.ssh/qa-reports.pem
assume-ctt-admin 123456
terraform plan
terraform apply

# TODO

- db secret from ansible vault, pull from group vars
- ACM cert

- ssh keys in repo for initial bootstrap
- rabbitmq on web host (master)
- rename to something better.. infrastructure/application? terraform/ansible?

- set up prod
  - shared vars that span environments
- commit ansible inventory

# Caveats

- state file in S3 is not locked; add dynamo to lock it
- state file in S3 is not encrypted
- AZs.. us-east-1a is primary, 1b is secondary (may lose it)
  - due to rabbitmq, rds

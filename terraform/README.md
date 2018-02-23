# Terraform

- state is stored in s3

# Usage

## Prerequisites
The qa-reports ssh key should be in your ssh agent:

    ssh-add ~/.ssh/qa-reports.pem

The AWS qa-admin role should be assumed:

    assume-ctt-admin 123456

## Deploy

Plan the deployment:

    make plan

Do the deployment:

    make apply

Update ansible's inventory:

    make inventory

# TODO

- db secret from ansible vault, pull from group vars
- ACM cert

- ssh keys in repo for initial bootstrap
- rabbitmq on web host (master)

- set up prod
- commit ansible inventory

# Caveats

- state file in S3 is not locked; add dynamo to lock it
- state file in S3 is not encrypted
- AZs.. us-east-1a is primary, 1b is secondary (may lose it)
  - due to rabbitmq, rds

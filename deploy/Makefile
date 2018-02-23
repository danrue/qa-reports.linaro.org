ENV := staging

all: plan apply

.terraform:
	terraform init

plan: .terraform
	terraform plan -var-file=shared.tfvars -var-file=${ENV}.tfvars .

apply:
	terraform apply -var-file=${ENV}.tfvars -state=${ENV}.tfstate -backup=-

destroy:
	terraform destroy -var-file=${ENV}.tfvars -state=${ENV}.tfstate -backup=-

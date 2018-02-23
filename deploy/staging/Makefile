ENV := staging

all: plan apply

plan:
	terraform plan -var-file=shared.tfvars -var-file=${ENV}.tfvars .

apply:
	terraform apply -var-file=${ENV}.tfvars -state=${ENV}.tfstate -backup=-

destroy:
	terraform destroy -var-file=${ENV}.tfvars -state=${ENV}.tfstate -backup=-

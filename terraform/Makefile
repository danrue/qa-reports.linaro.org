ENV := staging

all: plan apply

.terraform:
	terraform init

plan: .terraform
	terraform plan -var-file=shared.tfvars -var-file=${ENV}.tfvars .

repl: .terraform
	terraform console -var-file=shared.tfvars -var-file=${ENV}.tfvars .

apply:
	terraform apply -var-file=shared.tfvars -var-file=${ENV}.tfvars .

inventory:
	terraform state | ./scripts/state_to_ansible_inventory.py > inventory

clean:
	rm -rf .terraform

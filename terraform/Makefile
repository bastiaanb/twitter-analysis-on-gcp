STACK=dev

workspace:
	terraform workspace new $(STACK)
	
select-workspace:
	terraform workspace select $(STACK)

plan: select-workspace
	terraform plan -var-file=$(STACK).tfvars

apply: select-workspace
	terraform apply -var-file=$(STACK).tfvars

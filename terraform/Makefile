STACK=dev

JSONFEED_URL=$(shell terraform output jsonfeed_url)

init:
	terraform init

workspace:
	terraform workspace new $(STACK)

select-workspace:
	terraform workspace select $(STACK) || terraform workspace new $(STACK)

plan: select-workspace
	terraform plan -var-file=stacks/$(STACK).tfvars

apply: select-workspace
	terraform apply -var-file=stacks/$(STACK).tfvars

test: select-workspace
	curl -s $(JSONFEED_URL) | jq .
	@echo

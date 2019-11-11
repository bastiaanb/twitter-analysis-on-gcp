STACK=dev

JSONFEED_URL=$(shell terraform output jsonfeed_url)

workspace:
	terraform workspace new $(STACK)

select-workspace:
	terraform workspace select $(STACK)

plan: select-workspace
	terraform plan -var-file=$(STACK).tfvars

apply: select-workspace
	terraform apply -var-file=$(STACK).tfvars

test: select-workspace
	curl -s $(JSONFEED_URL) | jq .
	@echo

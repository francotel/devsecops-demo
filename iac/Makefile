# SHELL := /usr/bin/env bash
# .EXPORT_ALL_VARIABLES:

##  ENV  ##
demo:
	$(eval AWS_PROFILE   = $(shell echo "scc-admin"))
	$(eval AWS_REGION    = $(shell echo "us-east-1"))

# HOW TO EXECUTE

# Executing Terraform PLAN
#	$ make tf-plan env=<env>
#       make tf-plan env=dev

# Executing Terraform APPLY
#   $ make tf-apply env=<env>

# Executing Terraform DESTROY
#	$ make tf-destroy env=<env>

# Executing build-ami 
#	$ make build-ami type=<type> env=<env>
#       make build-ami type=bastion env=dev

#####  TERRAFORM  #####
all-test: clean tf-plan

.PHONY: clean tf-output tf-init tf-plan tf-apply tf-destroy build-ami
	rm -rf .terraform

tf-init: $(env)
	AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config envs/${env}/backend.conf -reconfigure -upgrade && terraform validate 

tf-plan: $(env)
	AWS_PROFILE=${AWS_PROFILE} terraform fmt --recursive && AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config envs/${env}/backend.conf -reconfigure -upgrade && terraform validate && AWS_PROFILE=${AWS_PROFILE} terraform plan -var-file envs/${env}/${env}.tfvars -out=tfplan

tf-apply: $(env)
	AWS_PROFILE=${AWS_PROFILE} terraform fmt --recursive && AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config envs/${env}/backend.conf -reconfigure && terraform validate && AWS_PROFILE=${AWS_PROFILE} terraform apply -auto-approve -parallelism=15 --input=false tfplan

tf-destroy: $(env)
	AWS_PROFILE=${AWS_PROFILE}  terraform init -backend-config envs/${env}/backend.conf -reconfigure && AWS_PROFILE=${AWS_PROFILE} terraform destroy -var-file envs/${env}/*.tfvars

tf-output: $(env)
	AWS_PROFILE=${AWS_PROFILE} terraform output
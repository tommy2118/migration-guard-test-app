# Terraform commands

TF_DIR := infra/terraform
ENV ?= staging

#=============================================================================
# Terraform Commands
#=============================================================================

.PHONY: terraform-init
terraform-init: ## Initialize Terraform
	@cd $(TF_DIR)/environments/$(ENV) && terraform init

.PHONY: terraform-plan
terraform-plan: ## Plan Terraform changes
	@cd $(TF_DIR)/environments/$(ENV) && terraform plan -out=tfplan

.PHONY: terraform-apply
terraform-apply: ## Apply Terraform changes
	@cd $(TF_DIR)/environments/$(ENV) && terraform apply tfplan

.PHONY: terraform-destroy
terraform-destroy: ## Destroy Terraform resources
	@echo "⚠️  This will destroy all resources in $(ENV)!"
	@read -p "Type '$(ENV)' to confirm: " confirm; \
	if [[ $$confirm == "$(ENV)" ]]; then \
		cd $(TF_DIR)/environments/$(ENV) && terraform destroy; \
	else \
		echo "Cancelled"; \
	fi

.PHONY: terraform-fmt
terraform-fmt: ## Format Terraform files
	@cd $(TF_DIR) && terraform fmt -recursive

.PHONY: terraform-validate
terraform-validate: ## Validate Terraform configuration
	@cd $(TF_DIR)/environments/$(ENV) && terraform validate

.PHONY: terraform-output
terraform-output: ## Show Terraform outputs
	@cd $(TF_DIR)/environments/$(ENV) && terraform output

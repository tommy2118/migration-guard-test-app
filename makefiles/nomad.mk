# Nomad deployment commands

NOMAD_DIR := infra/nomad
JOB_NAME := migration-guard-test-app
ENV ?= staging
TAG ?= latest

#=============================================================================
# Nomad Commands
#=============================================================================

.PHONY: nomad-plan
nomad-plan: ## Plan Nomad job deployment
	@nomad job plan \
		-var-file=$(NOMAD_DIR)/envs/$(ENV).yml \
		-var="image_tag=$(TAG)" \
		$(NOMAD_DIR)/$(JOB_NAME).nomad

.PHONY: nomad-deploy
nomad-deploy: ## Deploy to Nomad
	@echo "Deploying $(JOB_NAME) to $(ENV) with tag $(TAG)"
	@nomad job run \
		-var-file=$(NOMAD_DIR)/envs/$(ENV).yml \
		-var="image_tag=$(TAG)" \
		$(NOMAD_DIR)/$(JOB_NAME).nomad

.PHONY: nomad-status
nomad-status: ## Check job status
	@nomad job status $(JOB_NAME)

.PHONY: nomad-logs
nomad-logs: ## Stream logs from Nomad
	@nomad alloc logs -f $$(nomad job status $(JOB_NAME) | grep running | head -1 | awk '{print $$1}')

.PHONY: nomad-stop
nomad-stop: ## Stop Nomad job
	@nomad job stop $(JOB_NAME)

.PHONY: nomad-restart
nomad-restart: ## Restart Nomad job
	@nomad job restart $(JOB_NAME)

.PHONY: nomad-scale
nomad-scale: ## Scale Nomad job (COUNT required)
ifndef COUNT
	$(error COUNT is required. Usage: make nomad-scale COUNT=3)
endif
	@nomad job scale $(JOB_NAME) $(COUNT)

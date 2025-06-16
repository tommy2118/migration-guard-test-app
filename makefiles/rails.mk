# Rails-specific commands

#=============================================================================
# Rails Commands
#=============================================================================

.PHONY: rails
rails: ## Run Rails command (CMD required)
ifndef CMD
	$(error CMD is required. Usage: make rails CMD="routes")
endif
	@docker-compose run --rm web bin/rails $(CMD)

.PHONY: routes
routes: ## Show application routes
	@docker-compose run --rm web bin/rails routes

.PHONY: routes-grep
routes-grep: ## Search routes (PATTERN required)
ifndef PATTERN
	$(error PATTERN is required. Usage: make routes-grep PATTERN=user)
endif
	@docker-compose run --rm web bin/rails routes | grep $(PATTERN)

#=============================================================================
# Database Commands
#=============================================================================

.PHONY: db-setup
db-setup: ## Setup database (create, migrate, seed)
	@docker-compose run --rm web bin/rails db:create db:migrate db:seed

.PHONY: db-reset
db-reset: ## Reset database (drop, create, migrate, seed)
	@echo "⚠️  This will delete all data!"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose run --rm web bin/rails db:drop db:create db:migrate db:seed; \
	fi

.PHONY: db-migrate-status
db-migrate-status: ## Show migration status
	@docker-compose run --rm web bin/rails db:migrate:status

#=============================================================================
# Generators
#=============================================================================

.PHONY: generate
generate: ## Run Rails generator (GENERATOR and ARGS required)
ifndef GENERATOR
	$(error GENERATOR is required. Usage: make generate GENERATOR=model ARGS="User name:string")
endif
	@docker-compose run --rm web bin/rails generate $(GENERATOR) $(ARGS)

.PHONY: destroy
destroy: ## Destroy generated files (GENERATOR and ARGS required)
ifndef GENERATOR
	$(error GENERATOR is required. Usage: make destroy GENERATOR=model ARGS="User")
endif
	@docker-compose run --rm web bin/rails destroy $(GENERATOR) $(ARGS)

#=============================================================================
# Bundle Commands
#=============================================================================

.PHONY: bundle-install
bundle-install: ## Install gems
	@docker-compose run --rm web bundle install

.PHONY: bundle-update
bundle-update: ## Update gems
	@docker-compose run --rm web bundle update

.PHONY: bundle-outdated
bundle-outdated: ## Show outdated gems
	@docker-compose run --rm web bundle outdated

#=============================================================================
# Asset Commands (if not API-only)
#=============================================================================

.PHONY: assets-precompile
assets-precompile: ## Precompile assets
	@docker-compose run --rm web bin/rails assets:precompile

.PHONY: assets-clean
assets-clean: ## Clean assets
	@docker-compose run --rm web bin/rails assets:clean

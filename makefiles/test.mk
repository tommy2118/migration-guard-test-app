# Testing and code quality commands

#=============================================================================
# RSpec Commands
#=============================================================================

.PHONY: test-rspec
test-rspec: ## Run all RSpec tests
	@docker-compose run --rm web bundle exec rspec

.PHONY: test-rspec-file
test-rspec-file: ## Run specific test file (FILE required)
ifndef FILE
	$(error FILE is required. Usage: make test-rspec-file FILE=spec/models/user_spec.rb)
endif
	@docker-compose run --rm web bundle exec rspec $(FILE)

.PHONY: test-rspec-changed
test-rspec-changed: ## Run tests for changed files only
	@docker-compose run --rm web bash -c "git diff --name-only --cached | grep '_spec.rb$$' | xargs -r bundle exec rspec"

.PHONY: test-rspec-failed
test-rspec-failed: ## Re-run failed tests
	@docker-compose run --rm web bundle exec rspec --only-failures

#=============================================================================
# Code Quality Commands
#=============================================================================

.PHONY: test-rubocop
test-rubocop: ## Run RuboCop on all files
	@docker-compose run --rm web bundle exec rubocop

.PHONY: test-rubocop-fix
test-rubocop-fix: ## Auto-fix RuboCop violations
	@docker-compose run --rm web bundle exec rubocop -a

.PHONY: test-rubocop-changed
test-rubocop-changed: ## Run RuboCop on changed files only
	@docker-compose run --rm web bash -c "git diff --name-only --cached | grep '\.rb$$' | xargs -r bundle exec rubocop"

.PHONY: test-brakeman
test-brakeman: ## Run security scan with Brakeman
	@docker-compose run --rm web bundle exec brakeman

.PHONY: test-audit
test-audit: ## Audit dependencies for vulnerabilities
	@docker-compose run --rm web bundle exec bundle-audit check --update

#=============================================================================
# Coverage Commands
#=============================================================================

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@docker-compose run --rm -e COVERAGE=true web bundle exec rspec
	@echo "Coverage report available at: coverage/index.html"

#=============================================================================
# Continuous Testing
#=============================================================================

.PHONY: guard
guard: ## Start Guard for continuous testing
	@docker-compose run --rm web bundle exec guard

#=============================================================================
# All Tests
#=============================================================================

.PHONY: test-all
test-all: test-rubocop test-brakeman test-audit test-rspec ## Run all tests and checks

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose
This is a test application specifically designed to test the rails-migration-guard gem from https://github.com/tommy2118/rails-migration-guard. The gem prevents orphaned database migrations in development and staging environments by tracking migrations across git branches.

## Key Commands

### Development Workflow
```bash
# Initial setup
make setup

# Start services
make start           # Start all services
make dev            # Start with live logs
make console        # Rails console
make bash           # Shell in container

# Database operations
make db-migrate     # Run migrations
make db-rollback    # Rollback last migration
make db-seed        # Seed database
make db-console     # PostgreSQL console

# Running tests
make test           # Run all tests (RSpec + RuboCop)
make test-rspec     # Run RSpec only
make test-rspec-file FILE=spec/path/to/file_spec.rb  # Run single file
make test-rubocop   # Run RuboCop
make test-rubocop-fix  # Auto-fix RuboCop violations
make guard          # Continuous testing

# Pre-commit checks
make pre-commit     # Run RuboCop and RSpec on changed files
```

### Rails Migration Guard Commands (once installed)
```bash
rails db:migration:status         # Check migration status
rails db:migration:rollback_orphaned  # Roll back orphaned migrations
rails db:migration:check         # Check for migration issues
```

## Architecture & Structure

### Technology Stack
- Rails 8.0.2 with PostgreSQL database
- Docker-based development environment
- RSpec for testing with FactoryBot, Faker, and Shoulda Matchers
- RuboCop for code style enforcement
- Redis for caching, Sidekiq for background jobs
- Elasticsearch for search functionality

### Testing Rails Migration Guard
The gem is included via GitHub in the Gemfile:
```ruby
gem 'rails-migration-guard', github: 'tommy2118/rails-migration-guard'
```

Key areas to test based on open GitHub issues:
1. Rails 8.0 compatibility (Issue #72)
2. Team configuration sharing via .migration_guard.yml (Issue #23)
3. Migration tracking across git branches
4. Orphaned migration detection and rollback
5. CI/CD integration capabilities

### Database Configuration
- PostgreSQL with multiple databases (primary, cache, queue, cable)
- No existing migrations yet (clean state for testing)
- Schema version: 0

### RuboCop Configuration
- Always use `aggregate_failures` when there are multiple expectations in a spec
- Run `rubocop -A` to fix whitespace issues quickly
- Custom rules in .rubocop.yml for Rails/RSpec/Performance cops

## Important Notes
- Never modify schema.rb directly - use Rails generators for migrations
- This is a test harness for the rails-migration-guard gem
- The app has minimal application code to focus on testing the gem
- Docker handles all service dependencies
- Always run tests before committing changes
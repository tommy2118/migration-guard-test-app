# Docker-related commands

DOCKER_REGISTRY ?= your-registry.com
IMAGE_NAME := migration-guard-test-app
DOCKER_COMPOSE := docker-compose

#=============================================================================
# Build Commands
#=============================================================================

.PHONY: docker-build
docker-build: docker-build-base ## Build development Docker images
	@echo "Building development images..."
	@$(DOCKER_COMPOSE) build

.PHONY: docker-build-prod
docker-build-prod: ## Build production Docker image
	@echo "Building production image..."
	@docker build -f docker/Dockerfile -t $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest .

.PHONY: docker-build-base
docker-build-base: ## Rebuild base image
	@docker build -f docker/Dockerfile.base -t $(IMAGE_NAME)-base:latest .

#=============================================================================
# Registry Commands
#=============================================================================

.PHONY: docker-push
docker-push: ## Push Docker image to registry (TAG required)
ifndef TAG
	$(error TAG is required. Usage: make docker-push TAG=v1.0.0)
endif
	@echo "Pushing image with tag: $(TAG)"
	@docker tag $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)
	@docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: docker-pull
docker-pull: ## Pull latest images
	@$(DOCKER_COMPOSE) pull

#=============================================================================
# Container Management
#=============================================================================

.PHONY: docker-ps
docker-ps: ## Show running containers
	@$(DOCKER_COMPOSE) ps

.PHONY: docker-exec
docker-exec: ## Execute command in web container (CMD required)
ifndef CMD
	$(error CMD is required. Usage: make docker-exec CMD="rails routes")
endif
	@$(DOCKER_COMPOSE) exec web $(CMD)

.PHONY: docker-stats
docker-stats: ## Show container resource usage
	@docker stats --no-stream $$($(DOCKER_COMPOSE) ps -q)

#=============================================================================
# Cleanup Commands
#=============================================================================

.PHONY: docker-clean-containers
docker-clean-containers: ## Remove stopped containers
	@docker container prune -f

.PHONY: docker-clean-images
docker-clean-images: ## Remove dangling images
	@docker image prune -f

.PHONY: docker-clean-volumes
docker-clean-volumes: ## Remove unused volumes
	@docker volume prune -f

.PHONY: docker-clean-all
docker-clean-all: docker-clean-containers docker-clean-images docker-clean-volumes ## Clean everything
	@echo "Docker cleanup complete"

#!/bin/bash
set -e

# Default values
ENV=${ENV:-staging}
TAG=${TAG:-latest}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying migration-guard-test-app to ${ENV} with tag ${TAG}${NC}"

# Validate environment
if [[ ! -f "envs/${ENV}.yml" ]]; then
  echo -e "${RED}Error: Environment file envs/${ENV}.yml not found${NC}"
  exit 1
fi

# Run Nomad job plan
echo -e "${YELLOW}Planning deployment...${NC}"
nomad job plan \
  -var-file="envs/${ENV}.yml" \
  -var="image_tag=${TAG}" \
  migration-guard-test-app.nomad > plan.out

# Show the plan
cat plan.out

# Ask for confirmation in production
if [[ "${ENV}" == "production" ]]; then
  echo -e "${RED}WARNING: This will deploy to PRODUCTION!${NC}"
  read -p "Are you sure you want to continue? (yes/no) " -n 3 -r
  echo
  if [[ ! $REPLY =~ ^yes$ ]]; then
    echo "Deployment cancelled"
    exit 0
  fi
fi

# Extract job modify index from plan
JOB_MODIFY_INDEX=$(grep -E "Job Modify Index:" plan.out | awk '{print $4}')

# Run the deployment
echo -e "${YELLOW}Running deployment...${NC}"
nomad job run \
  -var-file="envs/${ENV}.yml" \
  -var="image_tag=${TAG}" \
  -check-index ${JOB_MODIFY_INDEX} \
  migration-guard-test-app.nomad

# Monitor deployment
echo -e "${YELLOW}Monitoring deployment...${NC}"
nomad job status migration-guard-test-app

echo -e "${GREEN}Deployment initiated successfully!${NC}"
echo "Monitor progress with: nomad job status migration-guard-test-app"

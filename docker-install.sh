#!/bin/bash

# Probe Tech Control - Docker Automated Installer
# Version: v1.0.0

# Colors
BLUE='\033[1;34m'
GOLD='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_box() {
    echo -e "${BLUE}=====================================================================${NC}"
    echo -e "${GOLD}      $1      ${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
}

echo -e "${BLUE}Starting Probe Tech Control Docker Installer...${NC}"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found!${NC}"
    echo -e "${GOLD}Please install Docker first: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

# Check for Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose V2 not found!${NC}"
    echo -e "${GOLD}Please install Docker Compose V2.${NC}"
    exit 1
fi

print_box "DOCKER DEPLOYMENT"

# Check for branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo -e "Current Branch: ${GREEN}${CURRENT_BRANCH}${NC}"

if [ "$CURRENT_BRANCH" != "docker-develop" ]; then
    echo -e "${GOLD}Warning: You are not on the 'docker-develop' branch.${NC}"
    read -p "Do you want to switch to 'docker-develop'? (y/n): " switch_branch
    if [[ "$switch_branch" =~ ^[Yy]$ ]]; then
        git checkout docker-develop || git checkout -b docker-develop
    fi
fi

echo -e "${BLUE}Building and starting containers...${NC}"
docker compose up --build -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${GREEN}✓ Probe Tech Control is now running in Docker!${NC}"
    echo -e "${GOLD}Access it at: http://localhost:8080${NC}"
    echo -e "${GREEN}=====================================================================${NC}"
else
    echo -e "${RED}Failed to start Docker containers. Check logs with 'docker compose logs'${NC}"
fi

#!/bin/bash

# Clear the terminal for a clean start
clear

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print fancy header
echo -e "${RED}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  Stopping Development                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a port is in use
check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# Function to stop process on a port
stop_port() {
    local port=$1
    local name=$2
    
    if check_port $port; then
        echo -e "${BLUE}→ Stopping $name on port $port...${NC}"
        lsof -ti:$port | xargs kill -9 2>/dev/null
        echo -e "${GREEN}✓ Stopped $name${NC}"
    else
        echo -e "${YELLOW}→ $name not running on port $port${NC}"
    fi
}

# Stop all services
echo -e "\n${BOLD}${PURPLE}Stopping services...${NC}"
stop_port 3000 "Development Server"
stop_port 5555 "Prisma Studio"

# Print status
echo -e "\n${BOLD}${GREEN}✓ All services stopped!${NC}\n" 
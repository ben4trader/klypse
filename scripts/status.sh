#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print fancy header
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   Development Status                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a port is in use
check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# Function to get process info for a port
get_process_info() {
    local port=$1
    lsof -i:$port | tail -n +2
}

# Check Development Server
echo -e "\n${BOLD}${BLUE}Development Server (Port 3000):${NC}"
if check_port 3000; then
    echo -e "${GREEN}✓ Running${NC}"
    get_process_info 3000 | awk '{printf "  → PID: %s (%s)\n", $2, $1}'
else
    echo -e "${RED}✗ Not running${NC}"
fi

# Check Prisma Studio
echo -e "\n${BOLD}${BLUE}Prisma Studio (Port 5555):${NC}"
if check_port 5555; then
    echo -e "${GREEN}✓ Running${NC}"
    get_process_info 5555 | awk '{printf "  → PID: %s (%s)\n", $2, $1}'
else
    echo -e "${RED}✗ Not running${NC}"
fi

# Print URLs if services are running
echo -e "\n${BOLD}${BLUE}Service URLs:${NC}"
if check_port 3000; then
    echo -e "${CYAN}Development Server:${NC} http://localhost:3000"
fi
if check_port 5555; then
    echo -e "${CYAN}Prisma Studio:${NC} http://localhost:5555"
fi
echo "" 
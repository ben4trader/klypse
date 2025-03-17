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
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   Starting 2kin Development              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Docker container is running
echo -e "\n${BOLD}${PURPLE}Checking Docker...${NC}"
if ! docker ps | grep -q "2kin-db"; then
    echo -e "${BLUE}→ Starting database container...${NC}"
    docker-compose up -d 2kin-db
    echo -e "${GREEN}✓ Database container started${NC}"
fi

# Function to check if a port is in use
check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# Function to get process info for a port
get_port_info() {
    local port=$1
    lsof -i:$port | tail -n +2
}

# Function to wait until port is free
wait_for_port() {
    local port=$1
    
    if check_port $port; then
        echo -e "${YELLOW}⚠️  Port $port in use${NC}"
        echo -e "${BLUE}→ Process using port $port:${NC}"
        get_port_info $port
        echo -e "${BLUE}→ Attempting to free port $port...${NC}"
        
        # Kill immediately with -9 for speed
        lsof -ti:$port | xargs kill -9 2>/dev/null
        sleep 0.5
        
        if check_port $port; then
            echo -e "${RED}Failed to free port $port${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Port $port freed${NC}"
    fi
}

# Clean up ports
echo -e "\n${BOLD}${PURPLE}Checking ports...${NC}"
wait_for_port 3000
wait_for_port 5555

# Kill any existing Prisma Studio instance
echo -e "\nKilling existing Prisma Studio..."
lsof -ti:5555 | xargs kill -9 2>/dev/null || true

# Start Prisma Studio
echo -e "\nStarting Prisma Studio..."
cd packages/database && bun run db:studio &

# Wait for Prisma Studio to be ready
echo -e "${BLUE}→ Waiting for Prisma Studio to start...${NC}"
while ! check_port 5555; do
    sleep 0.2
done
echo -e "${GREEN}✓ Prisma Studio ready${NC}"

# Start the main server
echo -e "\n${BOLD}${PURPLE}Starting development server...${NC}"
cd packages/backend && bun run dev &

# Wait for server to be ready
echo -e "${BLUE}→ Waiting for development server to start...${NC}"
while ! check_port 3000; do
    sleep 0.2
done
echo -e "${GREEN}✓ Development server ready${NC}"

# Print status
echo -e "\n${BOLD}${GREEN}🚀 Development environment ready!${NC}\n"
echo -e "${CYAN}Prisma Studio:${NC} http://localhost:5555"
echo -e "${CYAN}Development Server:${NC} http://localhost:3000"
echo -e "\n${YELLOW}Press Ctrl+C to stop all services${NC}\n"

# Function to stop process on a port
cleanup() {
    echo -e "\n${BOLD}${RED}Stopping services...${NC}"
    
    if check_port 3000; then
        echo -e "${BLUE}→ Stopping Development Server...${NC}"
        lsof -ti:3000 | xargs kill -9 2>/dev/null
        echo -e "${GREEN}✓ Stopped Development Server${NC}"
    fi
    
    if check_port 5555; then
        echo -e "${BLUE}→ Stopping Prisma Studio...${NC}"
        lsof -ti:5555 | xargs kill -9 2>/dev/null
        echo -e "${GREEN}✓ Stopped Prisma Studio${NC}"
    fi
    
    echo -e "${BOLD}${GREEN}✓ All services stopped!${NC}\n"
    exit 0
}

# Trap Ctrl+C and cleanup
trap cleanup INT TERM

# Keep script running
wait
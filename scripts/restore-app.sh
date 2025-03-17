#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 
BOLD='\033[1m'

# Show available backups
echo -e "${BLUE}Available backups:${NC}"
ls -lt ~/2kin.backups/ | grep -v "_db$"

# Get backup to restore
read -p "Enter backup timestamp or full name (e.g., 202411201937 or 202411201937_testing): " BACKUP_TIME

if [ ! -d ~/2kin.backups/$BACKUP_TIME ]; then
    echo -e "${RED}Error: Backup not found${NC}"
    exit 1
fi

# Confirm
echo -e "\n${YELLOW}This will replace your current 2kin directory.${NC}"
read -p "Are you sure? (y/N): " confirm
if [ "$confirm" != "y" ]; then
    echo -e "${BLUE}Restore cancelled${NC}"
    exit 0
fi

# ===== 1. Backup Phase =====
echo -e "\n${BLUE}Backup Phase:${NC}"
if [ -d ~/2kin_previous ]; then
    echo -e "${YELLOW}Removing existing 2kin_previous...${NC}"
    rm -rf ~/2kin_previous
fi

echo -e "${BLUE}Moving current 2kin to 2kin_previous...${NC}"
mv ~/2kin ~/2kin_previous 2>/dev/null || true

# ===== 2. Restore Phase =====
echo -e "\n${BLUE}Restore Phase:${NC}"
echo -e "${BLUE}Creating fresh 2kin directory...${NC}"
mkdir -p ~/2kin

echo -e "${BLUE}Restoring from backup ${CYAN}$BACKUP_TIME${NC}..."
INNER_DIR=$(ls ~/2kin.backups/$BACKUP_TIME)
cp -r ~/2kin.backups/$BACKUP_TIME/$INNER_DIR/. ~/2kin/

# ===== 3. Environment Files Phase =====
echo -e "\n${BLUE}Environment Files Phase:${NC}"
if [ -d ~/2kin_previous ]; then
    ENV_FILES=$(find ~/2kin_previous -maxdepth 1 -name ".env*")
    if [ -n "$ENV_FILES" ]; then
        echo -e "${BLUE}Copying .env files from previous installation...${NC}"
        cp ~/2kin_previous/.env* ~/2kin/ 2>/dev/null || true
    else
        echo -e "${YELLOW}Warning: No .env files found in previous installation${NC}"
    fi
else
    echo -e "${YELLOW}Warning: No previous installation found to copy .env files from${NC}"
fi

# ===== 4. Finalization =====
echo -e "\n${BLUE}Finalization Phase:${NC}"
echo -e "${BLUE}Installing dependencies...${NC}"
cd ~/2kin && make install

echo -e "\n${GREEN}✓ App restore completed!${NC}"
echo -e "${BLUE}Your previous version is saved at: ${CYAN}~/2kin_previous${NC}\n" 
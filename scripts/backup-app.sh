#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 
BOLD='\033[1m'

# Directories
SOURCE_DIR="$HOME/2kin"
BACKUPS_ROOT="$HOME/2kin.backups"

# Create backups directory if it doesn't exist
mkdir -p "$BACKUPS_ROOT"

# Create timestamped backup
TIMESTAMP=$(date +%Y%m%d%H%M)
BACKUP_DIR="${BACKUPS_ROOT}/${TIMESTAMP}"

# Add keyword to backup dir if provided
if [ $# -eq 1 ]; then
    BACKUP_DIR="${BACKUP_DIR}_${1}"
fi

echo -e "${BLUE}Creating backup of 2kin app files...${NC}"
echo -e "To: ${CYAN}$BACKUP_DIR${NC}"

# Perform the backup
rsync -av \
    --exclude 'node_modules' \
    --exclude '.env' \
    --exclude '.git' \
    --exclude 'dist' \
    --exclude '.vite' \
    "$SOURCE_DIR/" "$BACKUP_DIR/"

echo -e "\n${GREEN}✓ App backup completed!${NC}"
echo -e "${BLUE}Location: ${CYAN}$BACKUP_DIR${NC}\n" 
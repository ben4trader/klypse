#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 
BOLD='\033[1m'

# Load database configuration from .env
source "$HOME/2kin/packages/backend/.env"

# Create backup directory
BACKUPS_ROOT="$HOME/2kin.backups"
TIMESTAMP=$(date +%Y%m%d%H%M)
DB_BACKUP_DIR="${BACKUPS_ROOT}/${TIMESTAMP}_db"

mkdir -p "$DB_BACKUP_DIR"

echo -e "${BLUE}Creating PostgreSQL database backup...${NC}"
echo -e "To: ${CYAN}$DB_BACKUP_DIR${NC}"

# Extract database connection details from DATABASE_URL
# Format: postgresql://postgres:mysecretpassword@localhost:5432/postgres
DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DATABASE_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DATABASE_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Set PGPASSWORD environment variable
export PGPASSWORD="$DB_PASS"

# Perform database backup
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -F c -b -v -f "$DB_BACKUP_DIR/database.backup" "$DB_NAME"

echo -e "\n${GREEN}✓ Database backup completed!${NC}"
echo -e "${BLUE}Location: ${CYAN}$DB_BACKUP_DIR/database.backup${NC}\n" 
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 
BOLD='\033[1m'

# Load database configuration from .env
source ~/2kin/packages/backend/.env

# Show available backups
echo -e "${BLUE}Available database backups:${NC}"
ls -lt ~/2kin.backups/ | grep "_db$"

# Get backup to restore
read -p "Enter backup timestamp or full name (e.g., 202411201937 or 202411201937_testing): " BACKUP_TIME

DB_BACKUP_DIR=~/2kin.backups/${BACKUP_TIME}_db
if [ ! -d "$DB_BACKUP_DIR" ]; then
    echo -e "${RED}Error: Database backup not found${NC}"
    exit 1
fi

# Confirm
echo -e "\n${YELLOW}This will replace your current database.${NC}"
read -p "Are you sure? (y/N): " confirm
if [ "$confirm" != "y" ]; then
    echo -e "${BLUE}Restore cancelled${NC}"
    exit 0
fi

# Extract database connection details from DATABASE_URL
DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DATABASE_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DATABASE_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Set PGPASSWORD environment variable
export PGPASSWORD="$DB_PASS"

echo -e "${BLUE}Restoring database from backup ${CYAN}$BACKUP_TIME${NC}..."

# First, terminate all connections to the database
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();"

# Drop and recreate the database
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;"

# Restore with better flags
pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  --no-owner --no-privileges --verbose \
  "$DB_BACKUP_DIR/database.backup"

echo -e "\n${GREEN}✓ Database restore completed!${NC}\n" 
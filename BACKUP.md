# Backup and Restore Documentation

This document outlines the backup and restore procedures for the Klypse application.

## Backup System

The application uses a built-in backup system that creates complete snapshots of the application state, including code, database, and configuration.

### Backup Contents

Each backup includes:
- All git-tracked application code
- PostgreSQL database dump
- Environment configuration files (.env*)
- User-uploaded content
- Excludes: node_modules, dist directories, and .git files

### Creating Backups

#### Standard Backup

```bash
make backup-full
```

This creates a timestamped backup in the `./backups` directory.

#### Labeled Backup (Recommended)

```bash
make backup-full keyword=reason-for-backup
```

Examples:
- `make backup-full keyword=pre-deployment`
- `make backup-full keyword=feature-complete`
- `make backup-full keyword=database-migration`

### Backup Storage

Backups are stored in the `./backups` directory in the project root.

For production environments, we recommend:
1. Transferring backups to secure cloud storage
2. Implementing a rotation policy (keep 7 daily, 4 weekly, 12 monthly)
3. Testing backups periodically

## Restore Process

### Listing Available Backups

```bash
make list-full-backups
```

### Performing a Restore

```bash
make restore-full backup=./backups/full_backup_20250321_120321_pre-release.tar.gz
```

### Post-Restore Steps

After restoring, run:

```bash
make install
```

This rebuilds dependencies and ensures all generated files are up to date.

## Backup Schedule

- Development: Before major changes
- Staging: Daily automated backups
- Production: Daily automated backups with offsite storage

## Troubleshooting

If you encounter issues with database backup/restore:
1. Check database connection settings
2. Verify PostgreSQL client tools are installed
3. See error logs in the terminal output 
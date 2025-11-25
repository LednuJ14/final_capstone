@echo off
echo =====================================================
echo JACS Database Backup Script
echo =====================================================

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo Creating backups with timestamp: %TIMESTAMP%

echo Backing up main domain database...
mysqldump -u root -p jacs_property_db > "backups/backup_main_domain_%TIMESTAMP%.sql"

echo Backing up sub domain database...
mysqldump -u root -p jacs_property_management > "backups/backup_sub_domain_%TIMESTAMP%.sql"

echo Backup completed successfully!
echo Files created:
echo - backups/backup_main_domain_%TIMESTAMP%.sql
echo - backups/backup_sub_domain_%TIMESTAMP%.sql

pause

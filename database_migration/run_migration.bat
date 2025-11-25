@echo off
echo =====================================================
echo JACS DATABASE MIGRATION - SAFE CONSOLIDATION
echo =====================================================
echo.
echo This script will safely migrate your two databases
echo into one unified database without losing any data.
echo.
echo IMPORTANT: Make sure you have:
echo 1. MySQL Server running
echo 2. Both applications currently working
echo 3. Administrative access to MySQL
echo 4. Sufficient disk space for backups
echo.

set /p confirm="Do you want to proceed? (y/n): "
if /i not "%confirm%"=="y" (
    echo Migration cancelled.
    pause
    exit /b
)

echo.
echo =====================================================
echo STEP 1: CREATING BACKUPS
echo =====================================================
echo.

if not exist "backups" mkdir backups

echo Creating backup of main domain database...
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

mysqldump -u root -p jacs_property_db > "backups/backup_main_domain_%TIMESTAMP%.sql"
if errorlevel 1 (
    echo ERROR: Failed to backup main domain database
    pause
    exit /b 1
)

echo Creating backup of sub domain database...
mysqldump -u root -p jacs_property_management > "backups/backup_sub_domain_%TIMESTAMP%.sql"
if errorlevel 1 (
    echo ERROR: Failed to backup sub domain database
    pause
    exit /b 1
)

echo ✅ Backups created successfully!
echo.

echo =====================================================
echo STEP 2: CREATING UNIFIED DATABASE SCHEMA
echo =====================================================
echo.

echo Creating unified database schema...
mysql -u root -p < 02_create_unified_schema.sql
if errorlevel 1 (
    echo ERROR: Failed to create unified schema part 1
    pause
    exit /b 1
)

mysql -u root -p < 02_create_unified_schema_part2.sql
if errorlevel 1 (
    echo ERROR: Failed to create unified schema part 2
    pause
    exit /b 1
)

echo ✅ Unified database schema created successfully!
echo.

echo =====================================================
echo STEP 3: MIGRATING DATA
echo =====================================================
echo.

echo Installing required Python packages...
pip install mysql-connector-python

echo Running data migration script...
python 03_migrate_data_safely.py
if errorlevel 1 (
    echo ERROR: Data migration failed
    echo Check the migration logs for details
    pause
    exit /b 1
)

echo ✅ Data migration completed successfully!
echo.

echo =====================================================
echo STEP 4: UPDATING APPLICATION CONFIGURATIONS
echo =====================================================
echo.

echo Updating application configurations...
python 04_update_configs.py
if errorlevel 1 (
    echo ERROR: Configuration update failed
    pause
    exit /b 1
)

echo ✅ Configurations updated successfully!
echo.

echo =====================================================
echo STEP 5: VERIFYING MIGRATION
echo =====================================================
echo.

echo Verifying migration success...
python verify_migration.py
if errorlevel 1 (
    echo WARNING: Migration verification found issues
    echo Check the verification output above
    echo You may need to investigate before proceeding
)

echo.
echo =====================================================
echo MIGRATION COMPLETED!
echo =====================================================
echo.
echo ✅ Your databases have been successfully consolidated!
echo.
echo NEXT STEPS:
echo 1. Copy .env.unified to .env in both backend directories
echo 2. Update the .env files with your database credentials
echo 3. Test both applications
echo 4. Deploy the changes
echo.
echo BACKUP FILES LOCATION:
echo - backups/backup_main_domain_%TIMESTAMP%.sql
echo - backups/backup_sub_domain_%TIMESTAMP%.sql
echo.
echo If you encounter any issues, you can rollback using:
echo   python rollback_migration.py
echo.
echo Congratulations! You now have a unified database! 🎉
echo.

pause

-- =====================================================
-- BACKUP SCRIPT - Run this FIRST before any migration
-- =====================================================

-- Backup Main Domain Database
mysqldump -u root -p jacs_property_db > backup_main_domain_$(date +%Y%m%d_%H%M%S).sql

-- Backup Sub Domain Database  
mysqldump -u root -p jacs_property_management > backup_sub_domain_$(date +%Y%m%d_%H%M%S).sql

-- Create backup verification
SELECT 
    'Main Domain Backup' as backup_type,
    COUNT(*) as total_users 
FROM jacs_property_db.users
UNION ALL
SELECT 
    'Sub Domain Backup' as backup_type,
    COUNT(*) as total_users 
FROM jacs_property_management.users;

-- Verify all important tables exist
SHOW TABLES FROM jacs_property_db;
SHOW TABLES FROM jacs_property_management;

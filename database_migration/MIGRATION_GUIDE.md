# JACS Database Migration Guide
## Safe Consolidation from Two Databases to One

This guide will help you safely migrate from your current two-database setup to a single unified database without crashing your system.

## 🛡️ Safety Features

- ✅ **Complete backups** before any changes
- ✅ **Rollback capability** if something goes wrong
- ✅ **Step-by-step verification** at each stage
- ✅ **Zero data loss** - all data is preserved
- ✅ **Migration tracking** to monitor progress

## 📋 Prerequisites

1. **MySQL Server** running
2. **Python 3.8+** installed
3. **Both applications** currently working
4. **Administrative access** to MySQL
5. **Sufficient disk space** for backups

## 🚀 Migration Steps

### Step 1: Create Backups (CRITICAL)

```bash
# Navigate to migration directory
cd database_migration

# Create backups directory
mkdir backups

# Run backup script
./backup_script.bat
# OR manually:
mysqldump -u root -p jacs_property_db > backups/backup_main_domain_$(date +%Y%m%d_%H%M%S).sql
mysqldump -u root -p jacs_property_management > backups/backup_sub_domain_$(date +%Y%m%d_%H%M%S).sql
```

**⚠️ IMPORTANT: Do not proceed until backups are completed successfully!**

### Step 2: Create Unified Database Schema

```bash
# Connect to MySQL and run schema creation
mysql -u root -p < 02_create_unified_schema.sql
mysql -u root -p < 02_create_unified_schema_part2.sql
```

**Verify schema creation:**
```sql
USE jacs_property_platform;
SHOW TABLES;
-- Should show all unified tables
```

### Step 3: Run Data Migration

```bash
# Install required Python packages
pip install mysql-connector-python

# Run the migration script
python 03_migrate_data_safely.py
```

**The script will:**
- Connect to all three databases
- Migrate users (merge duplicates by email)
- Migrate properties (combine listing + management data)
- Migrate all related data (units, tenancies, bills, etc.)
- Track migration progress in `migration_log` table
- Provide detailed logging

### Step 4: Update Application Configurations

```bash
# Update both applications to use unified database
python 04_update_configs.py
```

**This will:**
- Backup original config files
- Update database names in both applications
- Create unified `.env` templates
- Generate verification and rollback scripts

### Step 5: Update Environment Files

```bash
# Copy unified environment templates
cp ../main-domain/backend/.env.unified ../main-domain/backend/.env
cp ../sub-domain/backend/.env.unified ../sub-domain/backend/.env

# Edit both .env files with your actual database credentials
# Make sure MYSQL_DATABASE=jacs_property_platform
```

### Step 6: Test Applications

```bash
# Test main-domain backend
cd ../main-domain/backend
python app.py

# In another terminal, test sub-domain backend
cd ../sub-domain/backend
python run.py

# Test frontends
cd ../main-domain/frontend
npm start

cd ../sub-domain/frontend
npm run dev
```

### Step 7: Verify Migration Success

```bash
cd database_migration
python verify_migration.py
```

**This will check:**
- All tables have expected data
- Migration log shows success
- No failed migration steps
- Data integrity is maintained

## 🔄 If Something Goes Wrong (Rollback)

If you encounter any issues, you can safely rollback:

```bash
# Run rollback script
python rollback_migration.py

# Restore original config files
cp ../main-domain/backend/config.py.backup_* ../main-domain/backend/config.py
cp ../sub-domain/backend/config/config.py.backup_* ../sub-domain/backend/config/config.py

# Restart applications with original databases
```

## 📊 Expected Results

After successful migration, you'll have:

### **Single Database: `jacs_property_platform`**
- ✅ All users merged (duplicates combined by email)
- ✅ All properties with both listing and management data
- ✅ All tenancy, billing, and maintenance data preserved
- ✅ All communication and document data preserved
- ✅ Migration tracking for audit purposes

### **Unified Data Model:**
```
Users: Combined from both systems
├── Properties: Listing + Management data
│   ├── Units: Available + Occupied units
│   ├── Tenancies: Active leases
│   ├── Inquiries: Potential tenant inquiries
│   └── Images/Amenities: Property media
├── Subscriptions: Property manager plans
├── Bills: Tenant billing
├── Requests: Maintenance requests
├── Tasks: Staff assignments
├── Announcements: Property communications
├── Documents: File management
└── Feedback: Tenant feedback
```

## 🎯 Benefits After Migration

1. **Single Source of Truth**: All data in one place
2. **Simplified Development**: One codebase to maintain
3. **Better Data Integrity**: Proper foreign key relationships
4. **Easier Reporting**: All data accessible in single queries
5. **Reduced Complexity**: No more data synchronization issues
6. **Better Performance**: No cross-database queries needed

## 🔍 Troubleshooting

### Common Issues:

**Migration Script Fails:**
- Check MySQL credentials
- Ensure all databases are accessible
- Check disk space for migration logs
- Review migration log table for specific errors

**Applications Won't Start:**
- Verify .env files have correct database name
- Check database connection settings
- Ensure unified database exists and has data

**Data Missing:**
- Check migration_log table for failed steps
- Review migration script logs
- Verify backup files are intact for rollback

**Performance Issues:**
- Run `ANALYZE TABLE` on all tables after migration
- Check MySQL configuration for optimal settings
- Consider adding additional indexes if needed

## 📞 Support

If you encounter issues:

1. **Check the logs**: Migration script creates detailed logs
2. **Verify backups**: Ensure you can rollback if needed
3. **Test incrementally**: Test each application separately
4. **Check migration_log**: Review what steps completed successfully

## 🎉 Success Checklist

- [ ] Backups created successfully
- [ ] Unified database schema created
- [ ] Data migration completed without errors
- [ ] Both applications start successfully
- [ ] Login works in both applications
- [ ] Property data displays correctly
- [ ] Tenant data is accessible
- [ ] No data loss verified
- [ ] Migration verification script passes

**Congratulations! You now have a unified, maintainable database architecture! 🚀**

---

**Remember**: Keep your backup files safe until you're completely confident the migration was successful. You can always rollback if needed.

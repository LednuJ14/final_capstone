#!/usr/bin/env python3
"""
Update application configurations to use the unified database
"""

import os
import shutil
from datetime import datetime

def backup_config_file(file_path):
    """Create backup of configuration file"""
    if os.path.exists(file_path):
        backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        shutil.copy2(file_path, backup_path)
        print(f"✅ Backed up {file_path} to {backup_path}")
        return backup_path
    return None

def update_main_domain_config():
    """Update main-domain backend configuration"""
    config_path = "../main-domain/backend/config.py"
    
    # Backup original
    backup_config_file(config_path)
    
    # Read current config
    with open(config_path, 'r') as f:
        content = f.read()
    
    # Update database name
    updated_content = content.replace(
        "f\"{os.environ.get('MYSQL_DATABASE', 'jacs_property_db')}\"",
        "f\"{os.environ.get('MYSQL_DATABASE', 'jacs_property_platform')}\""
    )
    
    # Write updated config
    with open(config_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ Updated main-domain/backend/config.py")

def update_sub_domain_config():
    """Update sub-domain backend configuration"""
    config_path = "../sub-domain/backend/config/config.py"
    
    # Backup original
    backup_config_file(config_path)
    
    # Read current config
    with open(config_path, 'r') as f:
        content = f.read()
    
    # Update database name
    updated_content = content.replace(
        "f\"{os.environ.get('MYSQL_DATABASE', 'jacs_property_management')}\"",
        "f\"{os.environ.get('MYSQL_DATABASE', 'jacs_property_platform')}\""
    )
    
    # Write updated config
    with open(config_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ Updated sub-domain/backend/config/config.py")

def create_unified_env_template():
    """Create unified environment template"""
    env_content = """# JACS Property Platform - Unified Database Configuration
# Copy this to .env and update with your actual values

# Flask Configuration
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=your-super-secret-key-change-in-production

# Unified Database Configuration
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your-mysql-password
MYSQL_DATABASE=jacs_property_platform

# JWT Configuration
JWT_SECRET_KEY=your-jwt-secret-key-change-in-production
JWT_ACCESS_TOKEN_EXPIRES=3600
JWT_REFRESH_TOKEN_EXPIRES=2592000

# Email Configuration (optional)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Upload Configuration
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=16777216  # 16MB

# Rate Limiting
RATELIMIT_STORAGE_URL=memory://
RATELIMIT_DEFAULT=100 per hour

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080

# Stripe Configuration (for subscriptions)
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret
"""
    
    # Write to both backend directories
    main_env_path = "../main-domain/backend/.env.unified"
    sub_env_path = "../sub-domain/backend/.env.unified"
    
    with open(main_env_path, 'w') as f:
        f.write(env_content)
    
    with open(sub_env_path, 'w') as f:
        f.write(env_content)
    
    print("✅ Created unified .env templates:")
    print(f"   - {main_env_path}")
    print(f"   - {sub_env_path}")

def create_migration_verification_script():
    """Create script to verify migration success"""
    script_content = """#!/usr/bin/env python3
\"\"\"
Verify that the database migration was successful
\"\"\"

import mysql.connector
import sys

def verify_migration():
    try:
        # Connect to unified database
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password=input("Enter MySQL root password: "),
            database='jacs_property_platform'
        )
        
        cursor = conn.cursor()
        
        print("🔍 Verifying migration...")
        
        # Check table counts
        tables_to_check = [
            'users', 'properties', 'units', 'tenancies', 'inquiries',
            'subscriptions', 'bills', 'requests', 'tasks', 'announcements',
            'documents', 'feedback', 'property_images', 'property_amenities'
        ]
        
        for table in tables_to_check:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"✅ {table}: {count} records")
        
        # Check migration log
        cursor.execute("SELECT * FROM migration_log WHERE status = 'completed'")
        completed_migrations = cursor.fetchall()
        print(f"\\n✅ Completed migration steps: {len(completed_migrations)}")
        
        # Check for any failed migrations
        cursor.execute("SELECT * FROM migration_log WHERE status = 'failed'")
        failed_migrations = cursor.fetchall()
        if failed_migrations:
            print(f"\\n❌ Failed migration steps: {len(failed_migrations)}")
            for migration in failed_migrations:
                print(f"   - {migration[1]}: {migration[6]}")
        else:
            print("\\n🎉 All migrations completed successfully!")
        
        cursor.close()
        conn.close()
        
        return len(failed_migrations) == 0
        
    except Exception as e:
        print(f"❌ Verification failed: {e}")
        return False

if __name__ == "__main__":
    success = verify_migration()
    sys.exit(0 if success else 1)
"""
    
    with open("verify_migration.py", 'w') as f:
        f.write(script_content)
    
    # Make executable on Unix systems
    os.chmod("verify_migration.py", 0o755)
    
    print("✅ Created migration verification script: verify_migration.py")

def create_rollback_script():
    """Create rollback script in case something goes wrong"""
    script_content = """#!/usr/bin/env python3
\"\"\"
Rollback script - restore original databases if needed
\"\"\"

import mysql.connector
import os
import glob
from datetime import datetime

def rollback_databases():
    password = input("Enter MySQL root password: ")
    
    print("🔍 Looking for backup files...")
    
    # Find backup files
    main_backups = glob.glob("backups/backup_main_domain_*.sql")
    sub_backups = glob.glob("backups/backup_sub_domain_*.sql")
    
    if not main_backups or not sub_backups:
        print("❌ Backup files not found!")
        return False
    
    # Get latest backups
    latest_main = max(main_backups, key=os.path.getctime)
    latest_sub = max(sub_backups, key=os.path.getctime)
    
    print(f"📁 Latest main backup: {latest_main}")
    print(f"📁 Latest sub backup: {latest_sub}")
    
    confirm = input("\\nRestore from these backups? (yes/no): ")
    if confirm.lower() != 'yes':
        print("Rollback cancelled.")
        return False
    
    try:
        # Connect to MySQL
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password=password
        )
        cursor = conn.cursor()
        
        # Drop and recreate databases
        print("🗑️ Dropping current databases...")
        cursor.execute("DROP DATABASE IF EXISTS jacs_property_db")
        cursor.execute("DROP DATABASE IF EXISTS jacs_property_management")
        cursor.execute("CREATE DATABASE jacs_property_db")
        cursor.execute("CREATE DATABASE jacs_property_management")
        
        cursor.close()
        conn.close()
        
        # Restore from backups
        print("📥 Restoring main domain database...")
        os.system(f"mysql -u root -p{password} jacs_property_db < {latest_main}")
        
        print("📥 Restoring sub domain database...")
        os.system(f"mysql -u root -p{password} jacs_property_management < {latest_sub}")
        
        print("✅ Rollback completed successfully!")
        print("\\n⚠️  Remember to:")
        print("1. Restore original configuration files from .backup files")
        print("2. Restart your applications")
        
        return True
        
    except Exception as e:
        print(f"❌ Rollback failed: {e}")
        return False

if __name__ == "__main__":
    rollback_databases()
"""
    
    with open("rollback_migration.py", 'w') as f:
        f.write(script_content)
    
    os.chmod("rollback_migration.py", 0o755)
    
    print("✅ Created rollback script: rollback_migration.py")

def main():
    """Main function to update all configurations"""
    print("🔧 Updating application configurations for unified database...")
    
    try:
        # Create backups directory
        os.makedirs("backups", exist_ok=True)
        
        # Update configurations
        update_main_domain_config()
        update_sub_domain_config()
        
        # Create templates and scripts
        create_unified_env_template()
        create_migration_verification_script()
        create_rollback_script()
        
        print("\\n✅ Configuration update completed!")
        print("\\nNext steps:")
        print("1. Copy .env.unified to .env in both backend directories")
        print("2. Update the .env files with your actual database credentials")
        print("3. Test both applications with the unified database")
        print("4. Run verify_migration.py to confirm everything works")
        
    except Exception as e:
        print(f"❌ Configuration update failed: {e}")

if __name__ == "__main__":
    main()

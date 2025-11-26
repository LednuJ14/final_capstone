# XAMPP Manual Database Migration Guide
## Convert Two Databases to One Using phpMyAdmin

Since you're using XAMPP, we can do this manually through phpMyAdmin - it's actually easier and more visual!

## 🚀 Step-by-Step Manual Migration

### Step 1: Backup Your Current Databases (CRITICAL!)

1. **Open phpMyAdmin** (http://localhost/phpmyadmin)
2. **Export main-domain database:**
   - Click on `jacs_property_db` database
   - Click **Export** tab
   - Select **Quick** export method
   - Format: **SQL**
   - Click **Go** and save as `backup_main_domain.sql`

3. **Export sub-domain database:**
   - Click on `jacs_property_management` database
   - Click **Export** tab
   - Select **Quick** export method
   - Format: **SQL**
   - Click **Go** and save as `backup_sub_domain.sql`

**⚠️ IMPORTANT: Keep these backup files safe!**

### Step 2: Create New Unified Database

1. In phpMyAdmin, click **New** (or **Databases** tab)
2. **Database name:** `jacs_property_platform`
3. **Collation:** `utf8mb4_unicode_ci`
4. Click **Create**

### Step 3: Create Unified Tables

I'll give you the simplified SQL commands to run in phpMyAdmin:

#### 3.1 Create Users Table (Unified)
```sql
USE jacs_property_platform;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(120) UNIQUE NOT NULL,
    username VARCHAR(80) UNIQUE NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    role ENUM('admin', 'property_manager', 'staff', 'tenant') NOT NULL DEFAULT 'tenant',
    status ENUM('active', 'inactive', 'suspended', 'pending_verification') DEFAULT 'active',
    profile_image_url VARCHAR(255),
    company VARCHAR(255),
    location VARCHAR(255),
    bio TEXT,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Philippines',
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    failed_login_attempts INT DEFAULT 0,
    locked_until DATETIME,
    password_reset_token VARCHAR(255),
    password_reset_expires DATETIME,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 3.2 Create Properties Table (Unified)
```sql
CREATE TABLE properties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    property_type ENUM('apartment', 'condominium', 'house', 'commercial', 'other') NOT NULL,
    listing_status ENUM('draft', 'pending_approval', 'active', 'inactive', 'rented', 'maintenance') DEFAULT 'draft',
    management_status ENUM('not_managed', 'managed', 'maintenance') DEFAULT 'not_managed',
    address VARCHAR(255) NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) DEFAULT 'Cebu',
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Philippines',
    latitude FLOAT,
    longitude FLOAT,
    total_units INT DEFAULT 0,
    year_built INT,
    total_floors INT,
    property_value DECIMAL(12, 2),
    monthly_maintenance_fee DECIMAL(10, 2) DEFAULT 0.00,
    owner_id INT NOT NULL,
    manager_id INT NOT NULL,
    manager_phone VARCHAR(20),
    manager_email VARCHAR(120),
    contact_name VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(120),
    amenities JSON,
    parking_spaces INT DEFAULT 0,
    has_elevator BOOLEAN DEFAULT FALSE,
    has_security BOOLEAN DEFAULT FALSE,
    has_gym BOOLEAN DEFAULT FALSE,
    has_pool BOOLEAN DEFAULT FALSE,
    has_laundry BOOLEAN DEFAULT FALSE,
    portal_enabled BOOLEAN DEFAULT FALSE,
    portal_subdomain VARCHAR(100) UNIQUE,
    portal_theme VARCHAR(50) DEFAULT 'default',
    view_count INT DEFAULT 0,
    inquiry_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    FOREIGN KEY (manager_id) REFERENCES users(id)
);
```

#### 3.3 Create Units Table
```sql
CREATE TABLE units (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    unit_number VARCHAR(20) NOT NULL,
    floor INT,
    unit_type VARCHAR(50),
    bedrooms INT DEFAULT 0,
    bathrooms DECIMAL(3,1) DEFAULT 1.0,
    square_feet INT,
    square_meters DECIMAL(8,2),
    is_furnished BOOLEAN DEFAULT FALSE,
    furnishing ENUM('unfurnished', 'semi_furnished', 'fully_furnished') DEFAULT 'unfurnished',
    has_balcony BOOLEAN DEFAULT FALSE,
    has_parking BOOLEAN DEFAULT FALSE,
    parking_space_number VARCHAR(20),
    pet_friendly BOOLEAN DEFAULT FALSE,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2),
    advance_payment INT DEFAULT 1,
    listing_status ENUM('available', 'rented', 'maintenance', 'reserved') DEFAULT 'available',
    occupancy_status ENUM('vacant', 'occupied', 'reserved', 'maintenance') DEFAULT 'vacant',
    available_date DATE,
    minimum_lease_term INT DEFAULT 12,
    maximum_occupants INT,
    utilities_included JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    UNIQUE KEY unique_unit_per_property (property_id, unit_number)
);
```

#### 3.4 Create Other Essential Tables
```sql
-- Tenancies (lease management)
CREATE TABLE tenancies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    unit_id INT NOT NULL,
    tenant_id INT NOT NULL,
    lease_start DATE NOT NULL,
    lease_end DATE NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2),
    status ENUM('active', 'ended', 'terminated', 'pending') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Inquiries
CREATE TABLE inquiries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    unit_id INT NULL,
    tenant_id INT NULL,
    contact_name VARCHAR(100),
    contact_email VARCHAR(120),
    contact_phone VARCHAR(20),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    status ENUM('new', 'responded', 'closed') DEFAULT 'new',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Bills
CREATE TABLE bills (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tenancy_id INT NOT NULL,
    bill_type ENUM('rent', 'utilities', 'maintenance', 'late_fee', 'other') NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    paid_amount DECIMAL(10,2) DEFAULT 0.00,
    paid_at DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenancy_id) REFERENCES tenancies(id) ON DELETE CASCADE
);

-- Maintenance Requests
CREATE TABLE requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    unit_id INT NOT NULL,
    tenant_id INT NOT NULL,
    assigned_staff_id INT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'completed', 'cancelled') DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_staff_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Subscriptions
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    status ENUM('active', 'cancelled', 'expired') DEFAULT 'active',
    max_properties INT DEFAULT 1,
    max_units INT DEFAULT 10,
    monthly_fee DECIMAL(8,2) NOT NULL,
    current_period_start DATE NOT NULL,
    current_period_end DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Property Images
CREATE TABLE property_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_size INT,
    mime_type VARCHAR(100),
    width INT,
    height INT,
    is_primary BOOLEAN DEFAULT FALSE,
    order_index INT DEFAULT 0,
    alt_text VARCHAR(255),
    caption VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

-- Blacklisted Tokens
CREATE TABLE blacklisted_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    jti VARCHAR(36) NOT NULL UNIQUE,
    token_type ENUM('access', 'refresh') NOT NULL,
    user_id INT,
    revoked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Step 4: Migrate Data Manually

Now we'll copy data from your existing databases:

#### 4.1 Migrate Users
```sql
-- Insert users from main domain
INSERT INTO jacs_property_platform.users 
(email, password_hash, first_name, last_name, phone_number, role, status, 
 profile_image_url, company, location, bio, address_line1, city, province, 
 country, email_verified, created_at, updated_at)
SELECT 
    email, password_hash, first_name, last_name, phone_number,
    CASE 
        WHEN role = 'manager' THEN 'property_manager'
        WHEN role = 'admin' THEN 'admin'
        ELSE 'tenant'
    END as role,
    CASE 
        WHEN status = 'active' THEN 'active'
        WHEN status = 'inactive' THEN 'inactive'
        ELSE 'active'
    END as status,
    profile_image_url, company, location, bio, address_line1, city, province,
    country, email_verified, created_at, updated_at
FROM jacs_property_db.users;

-- Insert users from sub domain (only if they don't exist)
INSERT IGNORE INTO jacs_property_platform.users 
(email, username, password_hash, first_name, last_name, phone_number, role, 
 emergency_contact_name, emergency_contact_phone, is_active, created_at, updated_at)
SELECT 
    email, username, password_hash, first_name, last_name, phone_number,
    CASE 
        WHEN role = 'property_manager' THEN 'property_manager'
        WHEN role = 'staff' THEN 'staff'
        ELSE 'tenant'
    END as role,
    emergency_contact_name, emergency_contact_phone, is_active, created_at, updated_at
FROM jacs_property_management.users
WHERE email NOT IN (SELECT email FROM jacs_property_platform.users);
```

#### 4.2 Migrate Properties
```sql
-- First, create a mapping table for user IDs
CREATE TEMPORARY TABLE user_id_mapping AS
SELECT 
    old_main.id as old_main_id,
    old_sub.id as old_sub_id,
    new.id as new_id,
    new.email
FROM jacs_property_platform.users new
LEFT JOIN jacs_property_db.users old_main ON new.email = old_main.email
LEFT JOIN jacs_property_management.users old_sub ON new.email = old_sub.email;

-- Migrate properties from main domain
INSERT INTO jacs_property_platform.properties 
(name, title, description, property_type, listing_status, address, address_line1, 
 city, province, postal_code, latitude, longitude, owner_id, contact_name, 
 contact_phone, contact_email, portal_enabled, portal_subdomain, portal_theme, 
 view_count, inquiry_count, created_at, updated_at)
SELECT 
    p.title as name, p.title, p.description, p.property_type, p.status as listing_status,
    p.address_line1 as address, p.address_line1, p.city, p.province, p.postal_code,
    p.latitude, p.longitude, m.new_id as owner_id, p.contact_name, p.contact_phone,
    p.contact_email, p.portal_enabled, p.portal_subdomain, p.portal_theme,
    p.view_count, p.inquiry_count, p.created_at, p.updated_at
FROM jacs_property_db.properties p
JOIN user_id_mapping m ON p.owner_id = m.old_main_id;

-- Migrate properties from sub domain (if they don't exist)
INSERT INTO jacs_property_platform.properties 
(name, title, description, property_type, management_status, address, address_line1, 
 city, province, total_units, year_built, total_floors, property_value, 
 monthly_maintenance_fee, owner_id, manager_id, manager_phone, manager_email,
 amenities, parking_spaces, has_elevator, has_security, has_gym, has_pool, 
 has_laundry, created_at, updated_at)
SELECT 
    p.name, p.name as title, p.description, p.property_type, 'managed' as management_status,
    p.address, p.address as address_line1, p.city, p.state as province, p.total_units,
    p.year_built, p.total_floors, p.property_value, p.monthly_maintenance_fee,
    m.new_id as owner_id, m.new_id as manager_id, p.manager_phone, p.manager_email,
    p.amenities, p.parking_spaces, p.has_elevator, p.has_security, p.has_gym,
    p.has_pool, p.has_laundry, p.created_at, p.updated_at
FROM jacs_property_management.properties p
JOIN user_id_mapping m ON p.manager_id = m.old_sub_id
WHERE p.name NOT IN (SELECT name FROM jacs_property_platform.properties);
```

#### 4.3 Continue with Other Tables
```sql
-- Migrate units from sub domain
INSERT INTO jacs_property_platform.units 
(property_id, unit_number, floor, unit_type, bedrooms, bathrooms, square_feet, 
 square_meters, is_furnished, has_balcony, has_parking, parking_space_number, 
 pet_friendly, monthly_rent, security_deposit, occupancy_status, available_date, 
 utilities_included, created_at, updated_at)
SELECT 
    (SELECT new_p.id FROM jacs_property_platform.properties new_p 
     JOIN jacs_property_management.properties old_p ON new_p.name = old_p.name 
     WHERE old_p.id = u.property_id LIMIT 1) as property_id,
    u.unit_number, u.floor, u.unit_type, u.bedrooms, u.bathrooms, u.square_feet,
    u.square_meters, u.is_furnished, u.has_balcony, u.has_parking, u.parking_space_number,
    u.pet_friendly, u.monthly_rent, u.security_deposit, u.status as occupancy_status,
    u.available_date, u.utilities_included, u.created_at, u.updated_at
FROM jacs_property_management.units u;

-- Continue with other tables (bills, requests, etc.)
-- ... (similar pattern for each table)
```

### Step 5: Update Your Application Configurations

#### 5.1 Update Main Domain Config
Edit `main-domain/backend/config.py`:
```python
# Change this line:
f"{os.environ.get('MYSQL_DATABASE', 'jacs_property_db')}"
# To:
f"{os.environ.get('MYSQL_DATABASE', 'jacs_property_platform')}"
```

#### 5.2 Update Sub Domain Config
Edit `sub-domain/backend/config/config.py`:
```python
# Change this line:
f"{os.environ.get('MYSQL_DATABASE', 'jacs_property_management')}"
# To:
f"{os.environ.get('MYSQL_DATABASE', 'jacs_property_platform')}"
```

#### 5.3 Update Environment Files
Update both `.env` files:
```
MYSQL_DATABASE=jacs_property_platform
```

### Step 6: Test Your Applications

1. **Start XAMPP** (Apache + MySQL)
2. **Test main-domain backend:**
   ```bash
   cd main-domain/backend
   python app.py
   ```
3. **Test sub-domain backend:**
   ```bash
   cd sub-domain/backend
   python run.py
   ```
4. **Test frontends:**
   ```bash
   cd main-domain/frontend
   npm start
   
   cd sub-domain/frontend
   npm run dev
   ```

### Step 7: Verify Everything Works

1. **Login to both applications**
2. **Check that property data displays correctly**
3. **Verify tenant data is accessible**
4. **Test creating new properties/tenants**

## 🔄 If Something Goes Wrong

1. **Stop your applications**
2. **In phpMyAdmin:**
   - Drop `jacs_property_platform` database
   - Import your backup files:
     - Create `jacs_property_db` → Import `backup_main_domain.sql`
     - Create `jacs_property_management` → Import `backup_sub_domain.sql`
3. **Restore original config files**
4. **Restart applications**

## 🎉 Success!

After this migration, you'll have:
- ✅ **One unified database** with all your data
- ✅ **Both applications working** with the same database
- ✅ **No data loss** - everything preserved
- ✅ **Better architecture** for your capstone project

This manual approach gives you full control and visibility over the process!

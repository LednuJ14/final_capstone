-- =====================================================
-- UNIFIED JACS PROPERTY PLATFORM DATABASE SCHEMA
-- =====================================================

-- Create the new unified database
CREATE DATABASE IF NOT EXISTS jacs_property_platform 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE jacs_property_platform;

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Unified Users Table (combines both user systems)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Authentication
    email VARCHAR(120) UNIQUE NOT NULL,
    username VARCHAR(80) UNIQUE NULL, -- for sub-domain compatibility
    password_hash VARCHAR(255) NOT NULL,
    
    -- Personal Information
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    
    -- Role and Status (unified from both systems)
    role ENUM('admin', 'property_manager', 'staff', 'tenant') NOT NULL DEFAULT 'tenant',
    status ENUM('active', 'inactive', 'suspended', 'pending_verification') DEFAULT 'pending_verification',
    
    -- Profile Information
    profile_image_url VARCHAR(255),
    avatar_url VARCHAR(255), -- alias for sub-domain compatibility
    company VARCHAR(255),
    location VARCHAR(255),
    bio TEXT,
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    address TEXT, -- for sub-domain compatibility
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Philippines',
    
    -- Emergency Contact (from sub-domain)
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    
    -- Verification
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE, -- alias for sub-domain
    is_active BOOLEAN DEFAULT TRUE, -- alias for sub-domain
    
    -- Security
    last_login DATETIME,
    failed_login_attempts INT DEFAULT 0,
    locked_until DATETIME,
    password_reset_token VARCHAR(255),
    password_reset_expires DATETIME,
    reset_token VARCHAR(255), -- alias for sub-domain
    reset_token_expiry DATETIME, -- alias for sub-domain
    
    -- Two-factor authentication
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(32),
    two_factor_email_code VARCHAR(8),
    two_factor_email_expires DATETIME,
    
    -- Migration tracking
    migrated_from ENUM('main_domain', 'sub_domain', 'both') NULL,
    original_main_id INT NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    
    -- Indexes
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status),
    INDEX idx_migration (migrated_from, original_main_id, original_sub_id)
);

-- Unified Properties Table
CREATE TABLE properties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Basic Information
    name VARCHAR(100) NOT NULL, -- from sub-domain
    title VARCHAR(255) NOT NULL, -- from main-domain (can be same as name)
    description TEXT,
    
    -- Property Type and Status
    property_type ENUM('bed_space', 'dormitory', 'boarding_house', 'studio_apartment', 'room_for_rent') NOT NULL,
    
    -- Dual Status System (for both listing and management)
    listing_status ENUM('draft', 'pending_approval', 'active', 'inactive', 'rented', 'maintenance', 'rejected') DEFAULT 'draft',
    management_status ENUM('not_managed', 'managed', 'maintenance') DEFAULT 'not_managed',
    
    -- Location
    address VARCHAR(255) NOT NULL, -- unified field
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    barangay VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100), -- for sub-domain compatibility
    province VARCHAR(100) DEFAULT 'Cebu',
    zip_code VARCHAR(20), -- for sub-domain compatibility
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Philippines',
    
    -- Geographic coordinates
    latitude FLOAT,
    longitude FLOAT,
    
    -- Property Details
    total_units INT DEFAULT 0,
    year_built INT,
    total_floors INT,
    floor_area FLOAT, -- in square meters
    lot_area FLOAT, -- in square meters
    
    -- Financial Information
    property_value DECIMAL(12, 2),
    monthly_maintenance_fee DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Management Information
    owner_id INT NOT NULL, -- from main-domain
    manager_id INT NOT NULL, -- from sub-domain (can be same as owner_id)
    manager_phone VARCHAR(20),
    manager_email VARCHAR(120),
    
    -- Contact Information (for listings)
    contact_name VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(120),
    
    -- Amenities and Features
    amenities JSON, -- unified from both systems
    parking_spaces INT DEFAULT 0,
    has_elevator BOOLEAN DEFAULT FALSE,
    has_security BOOLEAN DEFAULT FALSE,
    has_gym BOOLEAN DEFAULT FALSE,
    has_pool BOOLEAN DEFAULT FALSE,
    has_laundry BOOLEAN DEFAULT FALSE,
    
    -- SEO and Portal Features (from main-domain)
    slug VARCHAR(255) UNIQUE,
    keywords TEXT,
    view_count INT DEFAULT 0,
    inquiry_count INT DEFAULT 0,
    
    -- Portal Configuration
    portal_enabled BOOLEAN DEFAULT FALSE,
    portal_subdomain VARCHAR(100) UNIQUE,
    portal_theme VARCHAR(50) DEFAULT 'default',
    portal_custom_css TEXT,
    portal_logo_url VARCHAR(500),
    portal_banner_url VARCHAR(500),
    portal_contact_info TEXT, -- JSON string
    portal_features TEXT, -- JSON string
    portal_custom_domain VARCHAR(255),
    
    -- Migration tracking
    migrated_from ENUM('main_domain', 'sub_domain', 'merged') NULL,
    original_main_id INT NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    approved_by INT,
    approved_at DATETIME,
    
    -- Foreign Keys
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_owner (owner_id),
    INDEX idx_manager (manager_id),
    INDEX idx_listing_status (listing_status),
    INDEX idx_management_status (management_status),
    INDEX idx_city (city),
    INDEX idx_property_type (property_type),
    INDEX idx_portal_subdomain (portal_subdomain),
    INDEX idx_migration (migrated_from, original_main_id, original_sub_id)
);

-- Unified Units Table
CREATE TABLE units (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    
    -- Unit Identification
    unit_number VARCHAR(20) NOT NULL,
    floor INT,
    unit_type VARCHAR(50), -- Studio, 1BR, 2BR, etc.
    
    -- Physical Details
    bedrooms INT DEFAULT 0,
    bathrooms ENUM('own', 'share') DEFAULT 'own',
    square_feet INT,
    square_meters DECIMAL(8,2),
    floor_area FLOAT, -- alias for compatibility
    lot_area FLOAT, -- for houses
    
    -- Features
    is_furnished BOOLEAN DEFAULT FALSE,
    furnishing ENUM('unfurnished', 'semi_furnished', 'fully_furnished') DEFAULT 'unfurnished',
    has_balcony BOOLEAN DEFAULT FALSE,
    has_parking BOOLEAN DEFAULT FALSE,
    parking_space_number VARCHAR(20),
    parking_spaces INT DEFAULT 0, -- for compatibility
    has_storage BOOLEAN DEFAULT FALSE,
    pet_friendly BOOLEAN DEFAULT FALSE,
    pets_allowed BOOLEAN DEFAULT FALSE, -- alias
    smoking_allowed BOOLEAN DEFAULT FALSE,
    
    -- Utilities and Amenities
    utilities_included JSON,
    utility_bills_included BOOLEAN DEFAULT FALSE,
    maximum_occupants INT,
    
    -- Financial Information
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2),
    advance_payment INT DEFAULT 1, -- months
    
    -- Availability
    listing_status ENUM('available', 'rented', 'maintenance', 'reserved') DEFAULT 'available',
    occupancy_status ENUM('vacant', 'occupied', 'reserved', 'maintenance') DEFAULT 'vacant',
    available_date DATE,
    available_from DATE, -- alias
    minimum_lease_term INT DEFAULT 12, -- months
    
    -- Migration tracking
    migrated_from ENUM('main_domain', 'sub_domain', 'generated') NULL,
    original_main_id INT NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    
    -- Constraints
    UNIQUE KEY unique_unit_per_property (property_id, unit_number),
    
    -- Indexes
    INDEX idx_property (property_id),
    INDEX idx_listing_status (listing_status),
    INDEX idx_occupancy_status (occupancy_status),
    INDEX idx_monthly_rent (monthly_rent),
    INDEX idx_migration (migrated_from, original_main_id, original_sub_id)
);

-- =====================================================
-- TENANCY AND LEASE MANAGEMENT
-- =====================================================

-- Tenancy Management (replaces TenantUnit from sub-domain)
CREATE TABLE tenancies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    unit_id INT NOT NULL,
    tenant_id INT NOT NULL,
    
    -- Lease Information
    lease_start DATE NOT NULL,
    lease_end DATE NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2),
    advance_payment_months INT DEFAULT 1,
    
    -- Status
    status ENUM('active', 'ended', 'terminated', 'pending') DEFAULT 'pending',
    is_active BOOLEAN DEFAULT TRUE, -- for compatibility
    
    -- Migration tracking
    migrated_from ENUM('sub_domain', 'generated') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    move_in_date DATE,
    move_out_date DATE,
    
    -- Foreign Keys
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_unit (unit_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status),
    INDEX idx_lease_dates (lease_start, lease_end)
);

-- =====================================================
-- COMMUNICATION AND INQUIRIES
-- =====================================================

-- Unified Inquiries Table (from main-domain)
CREATE TABLE inquiries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    unit_id INT NULL, -- specific unit inquiry
    
    -- Inquirer Information
    tenant_id INT NULL, -- registered user inquiry
    property_manager_id INT NULL, -- who receives the inquiry
    
    -- Anonymous Inquirer Info (for non-registered users)
    contact_name VARCHAR(100),
    contact_email VARCHAR(120),
    contact_phone VARCHAR(20),
    
    -- Inquiry Details
    subject VARCHAR(255),
    message TEXT NOT NULL,
    inquiry_type ENUM('general', 'viewing', 'rental', 'maintenance') DEFAULT 'general',
    
    -- Status and Response
    status ENUM('new', 'responded', 'closed', 'spam') DEFAULT 'new',
    response TEXT,
    responded_at DATETIME,
    responded_by INT,
    
    -- Migration tracking
    migrated_from ENUM('main_domain') NULL,
    original_main_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (property_manager_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (responded_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_property (property_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- SUBSCRIPTION MANAGEMENT (from main-domain)
-- =====================================================

-- Subscription Plans
CREATE TABLE subscription_plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Pricing
    monthly_price DECIMAL(8,2) NOT NULL,
    yearly_price DECIMAL(8,2),
    
    -- Limits
    max_properties INT DEFAULT 1,
    max_units INT DEFAULT 10,
    max_inquiries_per_month INT DEFAULT 100,
    
    -- Features
    features JSON,
    portal_enabled BOOLEAN DEFAULT TRUE,
    analytics_enabled BOOLEAN DEFAULT FALSE,
    priority_support BOOLEAN DEFAULT FALSE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User Subscriptions
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    
    -- Subscription Details
    status ENUM('active', 'cancelled', 'expired', 'suspended') DEFAULT 'active',
    
    -- Billing
    current_period_start DATE NOT NULL,
    current_period_end DATE NOT NULL,
    next_billing_date DATE NOT NULL,
    
    -- Usage Tracking
    properties_count INT DEFAULT 0,
    units_count INT DEFAULT 0,
    inquiries_this_month INT DEFAULT 0,
    
    -- Payment Information
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id VARCHAR(255),
    
    -- Migration tracking
    migrated_from ENUM('main_domain') NULL,
    original_main_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    cancelled_at DATETIME,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_billing_date (next_billing_date)
);

-- Continue in next part due to length...

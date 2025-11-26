-- =====================================================
-- UNIFIED JACS PROPERTY PLATFORM DATABASE SCHEMA - PART 2
-- =====================================================

USE jacs_property_platform;

-- =====================================================
-- PROPERTY MANAGEMENT OPERATIONS (from sub-domain)
-- =====================================================

-- Staff Management (from sub-domain)
CREATE TABLE staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    
    -- Staff Details
    employee_id VARCHAR(50) UNIQUE,
    department VARCHAR(100),
    position VARCHAR(100),
    hire_date DATE,
    
    -- Contact and Emergency
    work_phone VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user (user_id),
    INDEX idx_employee_id (employee_id),
    INDEX idx_department (department)
);

-- Maintenance Requests (from sub-domain)
CREATE TABLE requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    unit_id INT NOT NULL,
    tenant_id INT NOT NULL,
    assigned_staff_id INT NULL,
    
    -- Request Details
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    request_type ENUM('maintenance', 'repair', 'complaint', 'inquiry', 'other') DEFAULT 'maintenance',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    
    -- Status
    status ENUM('open', 'in_progress', 'completed', 'cancelled', 'on_hold') DEFAULT 'open',
    
    -- Resolution
    resolution TEXT,
    estimated_cost DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    assigned_at DATETIME,
    started_at DATETIME,
    completed_at DATETIME,
    
    -- Foreign Keys
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_staff_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_unit (unit_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_assigned_staff (assigned_staff_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at)
);

-- Task Management (from sub-domain)
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Task Details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    task_type ENUM('maintenance', 'inspection', 'administrative', 'cleaning', 'other') DEFAULT 'maintenance',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    
    -- Assignment
    assigned_to INT NULL, -- staff member
    assigned_by INT NULL, -- who assigned the task
    property_id INT NULL,
    unit_id INT NULL,
    request_id INT NULL, -- linked to maintenance request
    
    -- Status and Progress
    status ENUM('pending', 'in_progress', 'completed', 'cancelled', 'on_hold') DEFAULT 'pending',
    progress_percentage INT DEFAULT 0,
    
    -- Scheduling
    due_date DATE,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    
    -- Completion
    completion_notes TEXT,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    started_at DATETIME,
    completed_at DATETIME,
    
    -- Foreign Keys
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_assigned_by (assigned_by),
    INDEX idx_property (property_id),
    INDEX idx_unit (unit_id),
    INDEX idx_request (request_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- =====================================================
-- BILLING AND FINANCIAL MANAGEMENT (from sub-domain)
-- =====================================================

-- Bills (from sub-domain)
CREATE TABLE bills (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tenancy_id INT NOT NULL,
    
    -- Bill Details
    bill_type ENUM('rent', 'utilities', 'maintenance', 'late_fee', 'deposit', 'other') NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    
    -- Due Date and Status
    due_date DATE NOT NULL,
    status ENUM('pending', 'paid', 'overdue', 'cancelled', 'partial') DEFAULT 'pending',
    
    -- Payment Information
    paid_amount DECIMAL(10,2) DEFAULT 0.00,
    paid_at DATETIME NULL,
    payment_method ENUM('cash', 'bank_transfer', 'check', 'online', 'other') NULL,
    payment_reference VARCHAR(255),
    
    -- Late Fees
    late_fee_amount DECIMAL(10,2) DEFAULT 0.00,
    late_fee_applied_at DATETIME NULL,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (tenancy_id) REFERENCES tenancies(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_tenancy (tenancy_id),
    INDEX idx_bill_type (bill_type),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- COMMUNICATION SYSTEM (from sub-domain)
-- =====================================================

-- Announcements (from sub-domain)
CREATE TABLE announcements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Announcement Details
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    announcement_type ENUM('general', 'maintenance', 'emergency', 'event', 'policy') DEFAULT 'general',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    
    -- Targeting
    property_id INT NULL, -- specific property or all properties
    unit_id INT NULL, -- specific unit
    target_audience ENUM('all_tenants', 'property_tenants', 'unit_tenant', 'staff') DEFAULT 'all_tenants',
    
    -- Publishing
    published_by INT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    publish_date DATETIME,
    expiry_date DATETIME,
    
    -- Visibility
    is_urgent BOOLEAN DEFAULT FALSE,
    requires_acknowledgment BOOLEAN DEFAULT FALSE,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_property (property_id),
    INDEX idx_unit (unit_id),
    INDEX idx_published_by (published_by),
    INDEX idx_announcement_type (announcement_type),
    INDEX idx_priority (priority),
    INDEX idx_publish_date (publish_date),
    INDEX idx_is_published (is_published)
);

-- Document Management (from sub-domain)
CREATE TABLE documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Document Details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    mime_type VARCHAR(100),
    
    -- Document Type and Category
    document_type ENUM('lease', 'policy', 'form', 'notice', 'report', 'other') DEFAULT 'other',
    category VARCHAR(100),
    
    -- Access Control
    uploaded_by INT NOT NULL,
    property_id INT NULL, -- property-specific document
    unit_id INT NULL, -- unit-specific document
    tenancy_id INT NULL, -- tenant-specific document
    visibility ENUM('public', 'tenants_only', 'property_tenants', 'unit_tenant', 'staff_only', 'private') DEFAULT 'private',
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    requires_signature BOOLEAN DEFAULT FALSE,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (tenancy_id) REFERENCES tenancies(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_uploaded_by (uploaded_by),
    INDEX idx_property (property_id),
    INDEX idx_unit (unit_id),
    INDEX idx_tenancy (tenancy_id),
    INDEX idx_document_type (document_type),
    INDEX idx_visibility (visibility),
    INDEX idx_is_active (is_active)
);

-- Feedback System (from sub-domain)
CREATE TABLE feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Feedback Details
    subject VARCHAR(255),
    message TEXT NOT NULL,
    feedback_type ENUM('complaint', 'suggestion', 'compliment', 'maintenance', 'service', 'other') DEFAULT 'other',
    rating INT CHECK (rating >= 1 AND rating <= 5),
    
    -- Source
    submitted_by INT NOT NULL,
    property_id INT NULL,
    unit_id INT NULL,
    staff_id INT NULL, -- feedback about specific staff member
    
    -- Response
    status ENUM('new', 'reviewed', 'responded', 'resolved', 'closed') DEFAULT 'new',
    response TEXT,
    responded_by INT NULL,
    responded_at DATETIME,
    
    -- Privacy
    is_anonymous BOOLEAN DEFAULT FALSE,
    
    -- Migration tracking
    migrated_from ENUM('sub_domain') NULL,
    original_sub_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (responded_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_submitted_by (submitted_by),
    INDEX idx_property (property_id),
    INDEX idx_unit (unit_id),
    INDEX idx_staff (staff_id),
    INDEX idx_feedback_type (feedback_type),
    INDEX idx_status (status),
    INDEX idx_rating (rating)
);

-- =====================================================
-- MEDIA AND FILES (from main-domain)
-- =====================================================

-- Property Images (from main-domain)
CREATE TABLE property_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    
    -- Image Details
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_path VARCHAR(500),
    file_size INT,
    mime_type VARCHAR(100),
    
    -- Image Properties
    width INT,
    height INT,
    is_primary BOOLEAN DEFAULT FALSE,
    order_index INT DEFAULT 0,
    
    -- Metadata
    alt_text VARCHAR(255),
    caption VARCHAR(500),
    
    -- Migration tracking
    migrated_from ENUM('main_domain') NULL,
    original_main_id INT NULL,
    
    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_property (property_id),
    INDEX idx_is_primary (is_primary),
    INDEX idx_order (order_index)
);

-- Property Amenities (from main-domain)
CREATE TABLE property_amenities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    
    -- Amenity Details
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50), -- e.g., 'security', 'recreation', 'utilities'
    icon VARCHAR(50), -- CSS class or icon name
    description VARCHAR(255),
    
    -- Migration tracking
    migrated_from ENUM('main_domain') NULL,
    original_main_id INT NULL,
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_property (property_id),
    INDEX idx_category (category)
);

-- =====================================================
-- SECURITY AND AUDIT (from main-domain)
-- =====================================================

-- Blacklisted Tokens (from main-domain)
CREATE TABLE blacklisted_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    jti VARCHAR(36) NOT NULL UNIQUE, -- JWT ID
    token_type ENUM('access', 'refresh') NOT NULL,
    user_id INT,
    revoked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    
    -- Migration tracking
    migrated_from ENUM('main_domain') NULL,
    original_main_id INT NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_jti (jti),
    INDEX idx_user (user_id),
    INDEX idx_expires_at (expires_at)
);

-- =====================================================
-- INITIAL DATA SETUP
-- =====================================================

-- Insert default subscription plans
INSERT INTO subscription_plans (name, description, monthly_price, yearly_price, max_properties, max_units, features) VALUES
('Basic', 'Perfect for individual property owners', 0.00, 0.00, 1, 5, '["property_listing", "basic_portal", "inquiry_management"]'),
('Professional', 'For small property management companies', 999.00, 9990.00, 5, 50, '["property_listing", "advanced_portal", "inquiry_management", "tenant_management", "basic_analytics"]'),
('Enterprise', 'For large property management companies', 2999.00, 29990.00, 25, 500, '["property_listing", "premium_portal", "inquiry_management", "tenant_management", "advanced_analytics", "priority_support", "custom_branding"]');

-- Create indexes for better performance
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_properties_listing_management ON properties(listing_status, management_status);
CREATE INDEX idx_units_property_status ON units(property_id, listing_status, occupancy_status);
CREATE INDEX idx_tenancies_dates ON tenancies(lease_start, lease_end, status);
CREATE INDEX idx_bills_due_status ON bills(due_date, status);
CREATE INDEX idx_requests_status_priority ON requests(status, priority);
CREATE INDEX idx_tasks_assigned_status ON tasks(assigned_to, status);

-- Add migration tracking table
CREATE TABLE migration_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migration_step VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    records_migrated INT DEFAULT 0,
    status ENUM('started', 'completed', 'failed') DEFAULT 'started',
    error_message TEXT,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    
    INDEX idx_migration_step (migration_step),
    INDEX idx_status (status)
);

-- Schema creation completed
SELECT 'Unified database schema created successfully!' as status;

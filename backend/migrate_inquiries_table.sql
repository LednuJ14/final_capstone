-- =====================================================
-- INQUIRIES TABLE MIGRATION GUIDE
-- =====================================================
-- This script will:
-- 1. Remove unnecessary columns (tenant_name, tenant_email, tenant_phone, subject, preferred_viewing_date, preferred_viewing_time, response_message, responded_at)
-- 2. Create a new inquiry_attachments table for file uploads (images, videos, files)
-- 3. Optionally create inquiry_messages table for better conversation management
--
-- IMPORTANT: BACKUP YOUR DATABASE BEFORE RUNNING THESE COMMANDS!
-- =====================================================

-- =====================================================
-- STEP 1: BACKUP EXISTING DATA (OPTIONAL BUT RECOMMENDED)
-- =====================================================
-- Create a backup table with all current data
CREATE TABLE IF NOT EXISTS inquiries_backup AS SELECT * FROM inquiries;

-- =====================================================
-- STEP 2: CREATE INQUIRY_ATTACHMENTS TABLE
-- =====================================================
-- This table will store all file attachments (images, videos, documents) for inquiries
CREATE TABLE IF NOT EXISTS inquiry_attachments (
    id INT(11) NOT NULL AUTO_INCREMENT,
    inquiry_id INT(11) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL COMMENT 'image, video, document, other',
    file_size INT(11) NOT NULL COMMENT 'Size in bytes',
    mime_type VARCHAR(100) NOT NULL COMMENT 'e.g., image/jpeg, video/mp4, application/pdf',
    uploaded_by INT(11) NOT NULL COMMENT 'User ID who uploaded the file',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT 0,
    PRIMARY KEY (id),
    INDEX idx_inquiry_id (inquiry_id),
    INDEX idx_file_type (file_type),
    INDEX idx_uploaded_by (uploaded_by),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (inquiry_id) REFERENCES inquiries(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_file_type CHECK (file_type IN ('image', 'video', 'document', 'other'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- STEP 3: CREATE INQUIRY_MESSAGES TABLE (OPTIONAL)
-- =====================================================
-- This table allows for better conversation management with threaded messages
-- If you want to keep response_message in inquiries table, skip this step
CREATE TABLE IF NOT EXISTS inquiry_messages (
    id INT(11) NOT NULL AUTO_INCREMENT,
    inquiry_id INT(11) NOT NULL,
    sender_id INT(11) NOT NULL COMMENT 'User ID of the sender (tenant or manager)',
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_inquiry_id (inquiry_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_created_at (created_at),
    INDEX idx_is_read (is_read),
    FOREIGN KEY (inquiry_id) REFERENCES inquiries(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- STEP 4: MIGRATE EXISTING RESPONSE MESSAGES (IF USING INQUIRY_MESSAGES)
-- =====================================================
-- If you created inquiry_messages table, migrate existing response_message data
-- Uncomment the following if you want to migrate existing responses:
/*
INSERT INTO inquiry_messages (inquiry_id, sender_id, message, created_at)
SELECT 
    id,
    property_manager_id,
    response_message,
    responded_at
FROM inquiries
WHERE response_message IS NOT NULL 
  AND response_message != ''
  AND responded_at IS NOT NULL;
*/

-- =====================================================
-- STEP 5: REMOVE UNNECESSARY COLUMNS FROM INQUIRIES TABLE
-- =====================================================
-- Remove columns that can be derived from related tables or are no longer needed

-- Remove tenant_name (can get from users table via tenant_id)
ALTER TABLE inquiries DROP COLUMN IF EXISTS tenant_name;

-- Remove tenant_email (can get from users table via tenant_id)
ALTER TABLE inquiries DROP COLUMN IF EXISTS tenant_email;

-- Remove tenant_phone (can get from users table via tenant_id)
ALTER TABLE inquiries DROP COLUMN IF EXISTS tenant_phone;

-- Remove subject (not necessary, can be part of message)
ALTER TABLE inquiries DROP COLUMN IF EXISTS subject;

-- Remove preferred_viewing_date (can be in message or separate table if needed)
ALTER TABLE inquiries DROP COLUMN IF EXISTS preferred_viewing_date;

-- Remove preferred_viewing_time (can be in message or separate table if needed)
ALTER TABLE inquiries DROP COLUMN IF EXISTS preferred_viewing_time;

-- Remove response_message (moved to inquiry_messages table if you created it)
-- If you're NOT using inquiry_messages table, keep this column
ALTER TABLE inquiries DROP COLUMN IF EXISTS response_message;

-- Remove responded_at (can be derived from inquiry_messages or status change)
-- If you're NOT using inquiry_messages table, keep this column
ALTER TABLE inquiries DROP COLUMN IF EXISTS responded_at;

-- =====================================================
-- STEP 6: VERIFY THE FINAL SCHEMA
-- =====================================================
-- After running the above commands, your inquiries table should have:
-- - id (INT, PRIMARY KEY, AUTO_INCREMENT)
-- - property_id (INT, FOREIGN KEY)
-- - unit_id (INT, FOREIGN KEY, NULLABLE)
-- - tenant_id (INT, FOREIGN KEY)
-- - property_manager_id (INT, FOREIGN KEY)
-- - inquiry_type (ENUM)
-- - status (ENUM)
-- - message (TEXT) - initial inquiry message
-- - is_urgent (TINYINT(1))
-- - is_archived (TINYINT(1))
-- - created_at (DATETIME)
-- - updated_at (DATETIME)
-- - read_at (DATETIME)

-- =====================================================
-- STEP 7: UPDATE ENUM VALUES (IF NEEDED)
-- =====================================================
-- Ensure inquiry_type enum includes all needed values
-- Adjust based on your InquiryType enum in Python
ALTER TABLE inquiries MODIFY COLUMN inquiry_type ENUM(
    'viewing_request',
    'rental_inquiry',
    'information_request',
    'complaint',
    'other'
) NOT NULL DEFAULT 'rental_inquiry';

-- Ensure status enum includes all needed values
-- Adjust based on your InquiryStatus enum in Python
ALTER TABLE inquiries MODIFY COLUMN status ENUM(
    'pending',
    'read',
    'responded',
    'closed',
    'spam',
    'assigned'
) NOT NULL DEFAULT 'pending';

-- =====================================================
-- STEP 8: CREATE INDEXES FOR BETTER PERFORMANCE
-- =====================================================
-- Add indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_inquiries_property_id ON inquiries(property_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_tenant_id ON inquiries(tenant_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_manager_id ON inquiries(property_manager_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_status ON inquiries(status);
CREATE INDEX IF NOT EXISTS idx_inquiries_created_at ON inquiries(created_at);
CREATE INDEX IF NOT EXISTS idx_inquiries_is_archived ON inquiries(is_archived);

-- =====================================================
-- NOTES:
-- =====================================================
-- 1. After migration, update your Python models to reflect the new schema
-- 2. Update API routes to use users table for tenant info instead of inquiry columns
-- 3. Implement file upload endpoints for inquiry_attachments
-- 4. If using inquiry_messages, update conversation/messaging logic
-- 5. Test thoroughly before deploying to production
-- =====================================================


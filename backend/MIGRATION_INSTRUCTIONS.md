# Inquiries Table Migration Instructions

## Overview
This migration will:
1. **Remove unnecessary columns** from the `inquiries` table
2. **Add file attachment support** via a new `inquiry_attachments` table
3. **Optionally add message threading** via a new `inquiry_messages` table

## Prerequisites
- **BACKUP YOUR DATABASE** before running any migration commands
- Access to your MySQL/MariaDB database
- Understanding of your current data structure

## Step-by-Step Instructions

### Step 1: Backup Your Database
```bash
# Using mysqldump
mysqldump -u your_username -p your_database_name > inquiries_backup_$(date +%Y%m%d_%H%M%S).sql

# Or create a backup table
CREATE TABLE inquiries_backup AS SELECT * FROM inquiries;
```

### Step 2: Review the Migration Script
Open `migrate_inquiries_table.sql` and review all commands. Customize based on your needs:
- **Option A**: Keep `response_message` in `inquiries` table (simpler, less changes)
- **Option B**: Use `inquiry_messages` table (better for conversations, more changes needed)

### Step 3: Run the Migration Script
```bash
# Option 1: Run entire script
mysql -u your_username -p your_database_name < migrate_inquiries_table.sql

# Option 2: Run commands one by one in MySQL client
mysql -u your_username -p your_database_name
# Then copy-paste commands from the SQL file
```

### Step 4: Verify the Changes
```sql
-- Check inquiries table structure
DESCRIBE inquiries;

-- Check new tables were created
SHOW TABLES LIKE 'inquiry%';

-- Verify data integrity
SELECT COUNT(*) FROM inquiries;
SELECT COUNT(*) FROM inquiry_attachments;
```

### Step 5: Update Your Code

#### A. Update Python Model (`app/models/inquiry.py`)
Remove references to deleted columns:
- `tenant_name`, `tenant_email`, `tenant_phone` → Get from `User` model via `tenant_id`
- `subject` → Remove or make optional
- `preferred_viewing_date`, `preferred_viewing_time` → Remove or add to message
- `response_message`, `responded_at` → Use `inquiry_messages` table if created

#### B. Update API Routes
- **Get tenant info**: Join with `users` table instead of using inquiry columns
- **File uploads**: Create endpoints to handle `inquiry_attachments`
- **Messages**: If using `inquiry_messages`, update conversation endpoints

#### C. Create New Models (if needed)
```python
# app/models/inquiry_attachment.py
class InquiryAttachment(db.Model):
    __tablename__ = 'inquiry_attachments'
    id = db.Column(db.Integer, primary_key=True)
    inquiry_id = db.Column(db.Integer, db.ForeignKey('inquiries.id'), nullable=False)
    file_name = db.Column(db.String(255), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    file_type = db.Column(db.String(100), nullable=False)  # image, video, document
    file_size = db.Column(db.Integer, nullable=False)
    mime_type = db.Column(db.String(100), nullable=False)
    uploaded_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_deleted = db.Column(db.Boolean, default=False)
```

## Columns Being Removed

| Column | Reason | Alternative |
|--------|--------|-------------|
| `tenant_name` | Redundant | Get from `users.first_name` + `users.last_name` via `tenant_id` |
| `tenant_email` | Redundant | Get from `users.email` via `tenant_id` |
| `tenant_phone` | Redundant | Get from `users.phone_number` via `tenant_id` |
| `subject` | Not needed | Can be part of message or removed |
| `preferred_viewing_date` | Rarely used | Can be in message text or separate table |
| `preferred_viewing_time` | Rarely used | Can be in message text or separate table |
| `response_message` | Better in messages table | Use `inquiry_messages` table (optional) |
| `responded_at` | Can be derived | From `inquiry_messages` or status change |

## New Tables Created

### `inquiry_attachments`
Stores file uploads (images, videos, documents) for inquiries.

**Key Fields:**
- `inquiry_id`: Links to inquiry
- `file_name`: Original filename
- `file_path`: Storage path on server
- `file_type`: image, video, document, other
- `file_size`: Size in bytes
- `mime_type`: MIME type (e.g., image/jpeg)
- `uploaded_by`: User who uploaded

### `inquiry_messages` (Optional)
Stores threaded conversation messages for better inquiry management.

**Key Fields:**
- `inquiry_id`: Links to inquiry
- `sender_id`: User who sent the message
- `message`: Message content
- `is_read`: Read status
- `created_at`: Timestamp

## File Upload Implementation Guide

### Backend (Flask)
1. Create upload endpoint:
```python
@inquiry_bp.route('/<int:inquiry_id>/attachments', methods=['POST'])
@tenant_required  # or manager_required
def upload_attachment(current_user, inquiry_id):
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    # Validate file type, size
    # Save file to storage
    # Create InquiryAttachment record
    # Return attachment info
```

2. File storage options:
   - Local filesystem: `uploads/inquiries/{inquiry_id}/`
   - Cloud storage: AWS S3, Google Cloud Storage, etc.

### Frontend (React)
1. File input component:
```jsx
<input 
  type="file" 
  accept="image/*,video/*,.pdf,.doc,.docx"
  multiple
  onChange={handleFileUpload}
/>
```

2. Upload function:
```javascript
const uploadFiles = async (inquiryId, files) => {
  const formData = new FormData();
  files.forEach(file => {
    formData.append('files', file);
  });
  
  const response = await fetch(`/api/inquiries/${inquiryId}/attachments`, {
    method: 'POST',
    body: formData,
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
};
```

## Rollback Plan

If something goes wrong:

```sql
-- Restore from backup table
DROP TABLE IF EXISTS inquiries;
CREATE TABLE inquiries AS SELECT * FROM inquiries_backup;

-- Or restore from SQL dump
mysql -u your_username -p your_database_name < inquiries_backup_YYYYMMDD_HHMMSS.sql
```

## Testing Checklist

- [ ] Backup created successfully
- [ ] Migration script runs without errors
- [ ] All inquiries still accessible
- [ ] Tenant info retrievable from users table
- [ ] File upload works
- [ ] File download works
- [ ] API endpoints updated
- [ ] Frontend displays correctly
- [ ] No data loss

## Support

If you encounter issues:
1. Check MySQL error logs
2. Verify foreign key constraints
3. Check data types match
4. Ensure indexes are created
5. Test with a small dataset first


# Inquiries Table Migration - Completed Steps

## ✅ Completed Tasks

### 1. Updated Python Models

#### `app/models/inquiry.py`
- ✅ Removed columns: `tenant_name`, `tenant_email`, `tenant_phone`, `subject`, `preferred_viewing_date`, `preferred_viewing_time`, `response_message`, `responded_at`
- ✅ Updated `__init__` method to remove tenant_name/email parameters
- ✅ Updated `to_dict()` to get tenant info from `User` relationship
- ✅ Updated `respond()` method to use `InquiryMessage` instead of `response_message`
- ✅ Added relationships: `attachments` and `messages`

#### `app/models/inquiry_attachment.py` (NEW)
- ✅ Created model for file attachments
- ✅ Supports: images, videos, documents, other files
- ✅ Includes: file metadata (name, path, type, size, MIME type)
- ✅ Soft delete support
- ✅ Relationships to `Inquiry` and `User`

#### `app/models/inquiry_message.py` (NEW)
- ✅ Created model for threaded conversation messages
- ✅ Supports read/unread status
- ✅ Relationships to `Inquiry` and `User` (sender)

#### `app/models/__init__.py`
- ✅ Added exports for new models: `InquiryAttachment`, `FileType`, `InquiryMessage`

### 2. Updated API Routes

#### `app/routes/tenant_inquiries_new.py`
- ✅ Removed references to deleted columns in SQL queries
- ✅ Updated to fetch tenant info from `users` table via JOIN
- ✅ Updated INSERT statement to exclude deleted columns
- ✅ Updated response format to use `tenant` object instead of separate fields

#### `app/routes/manager_inquiries_new.py`
- ✅ Removed references to deleted columns in SQL queries
- ✅ Updated to fetch tenant info from `users` table
- ✅ Updated response format to use `tenant` object

#### `app/routes/inquiry_attachments.py` (NEW)
- ✅ Created file upload endpoint: `POST /api/inquiries/<inquiry_id>/attachments`
- ✅ Created get attachments endpoint: `GET /api/inquiries/<inquiry_id>/attachments`
- ✅ Created download endpoint: `GET /api/inquiries/attachments/<attachment_id>`
- ✅ Created delete endpoint: `DELETE /api/inquiries/attachments/<attachment_id>`
- ✅ File validation (type, size limits)
- ✅ Security checks (user permissions)
- ✅ Support for multiple file uploads
- ✅ File storage in `uploads/inquiries/<inquiry_id>/`

### 3. Registered Blueprints

#### `app/__init__.py`
- ✅ Registered `inquiry_attachments_bp` at `/api/inquiries`

## 📋 API Endpoints

### File Upload Endpoints

1. **Upload Files**
   ```
   POST /api/inquiries/<inquiry_id>/attachments
   Headers: Authorization: Bearer <token>
   Body: multipart/form-data
     - files: [file1, file2, ...]
   Response: { attachments: [...], errors: [...] }
   ```

2. **Get Attachments**
   ```
   GET /api/inquiries/<inquiry_id>/attachments
   Headers: Authorization: Bearer <token>
   Response: { attachments: [...] }
   ```

3. **Download Attachment**
   ```
   GET /api/inquiries/attachments/<attachment_id>
   Headers: Authorization: Bearer <token>
   Response: File download
   ```

4. **Delete Attachment**
   ```
   DELETE /api/inquiries/attachments/<attachment_id>
   Headers: Authorization: Bearer <token>
   Response: { message: "Attachment deleted successfully" }
   ```

## 🔧 Configuration

### File Upload Settings
- **Max file size**: 50MB per file
- **Allowed types**:
  - Images: jpg, jpeg, png, gif, webp, svg
  - Videos: mp4, avi, mov, wmv, flv, webm, mkv
  - Documents: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, rtf
  - Other: zip, rar, 7z
- **Storage location**: `backend/uploads/inquiries/<inquiry_id>/`

## 📝 Next Steps (Frontend)

### 1. Update API Service
Add methods to `frontend/src/services/api.js`:
```javascript
// Upload files
uploadInquiryAttachments(inquiryId, files) {
  const formData = new FormData();
  files.forEach(file => {
    formData.append('files', file);
  });
  return this.request(`/inquiries/${inquiryId}/attachments`, {
    method: 'POST',
    body: formData,
    headers: {} // Don't set Content-Type, let browser set it with boundary
  });
}

// Get attachments
getInquiryAttachments(inquiryId) {
  return this.request(`/inquiries/${inquiryId}/attachments`);
}

// Download attachment
downloadAttachment(attachmentId) {
  return this.request(`/inquiries/attachments/${attachmentId}`, {
    responseType: 'blob'
  });
}

// Delete attachment
deleteAttachment(attachmentId) {
  return this.request(`/inquiries/attachments/${attachmentId}`, {
    method: 'DELETE'
  });
}
```

### 2. Update Inquiry Components
- Remove references to `tenant_name`, `tenant_email`, `tenant_phone`
- Use `inquiry.tenant` object instead
- Add file upload UI component
- Display attachments in inquiry view
- Add download/delete buttons for attachments

### 3. File Upload Component
Create a reusable file upload component:
```jsx
<FileUpload
  inquiryId={inquiryId}
  onUploadComplete={(attachments) => {...}}
  maxSize={50 * 1024 * 1024}
  acceptedTypes="image/*,video/*,.pdf,.doc,.docx"
/>
```

## ⚠️ Important Notes

1. **Database Migration**: Make sure you've run the SQL migration script before using these changes
2. **Upload Directory**: Ensure the `uploads/inquiries/` directory is writable
3. **File Security**: Files are stored with UUID names for security
4. **Permissions**: Only tenant and manager of an inquiry can upload/view/delete attachments
5. **Soft Delete**: Attachments are soft-deleted (not physically removed)

## 🧪 Testing Checklist

- [ ] Test file upload (single and multiple files)
- [ ] Test file download
- [ ] Test file deletion
- [ ] Test permission checks (unauthorized users)
- [ ] Test file size limits
- [ ] Test file type validation
- [ ] Verify tenant info is fetched from users table
- [ ] Verify no references to deleted columns remain

## 📚 Related Files

- `migrate_inquiries_table.sql` - Database migration script
- `MIGRATION_INSTRUCTIONS.md` - Detailed migration guide
- `app/models/inquiry.py` - Updated inquiry model
- `app/models/inquiry_attachment.py` - New attachment model
- `app/models/inquiry_message.py` - New message model
- `app/routes/inquiry_attachments.py` - File upload routes


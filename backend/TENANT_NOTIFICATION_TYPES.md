# Tenant Notification Types - Main Domain

This document lists all notification types specifically for tenants in the main-domain system.

## Overview
The main-domain focuses on **property discovery and inquiry management** for tenants. Notifications are centered around:
- Inquiry communications with property managers
- Property availability and updates
- Account and profile management

---

## Notification Types

### 1. **INQUIRY_RESPONSE** ✅ (Already implemented)
**When triggered:**
- Property manager responds to a tenant's inquiry
- Property manager sends a new message in an existing inquiry thread

**Example notifications:**
- "Property Manager John Doe responded to your inquiry about [Property Name]"
- "You have a new message about your viewing request for [Property Name]"

**Related entities:**
- `related_type`: "inquiry"
- `related_id`: inquiry_id

---

### 2. **INQUIRY_STATUS_CHANGE** (New)
**When triggered:**
- Inquiry status changes (pending → responded, responded → closed, etc.)
- Inquiry is assigned to a property manager
- Inquiry is marked as spam or closed

**Example notifications:**
- "Your inquiry about [Property Name] has been assigned to a property manager"
- "Your inquiry about [Property Name] has been closed"
- "Your viewing request for [Property Name] has been confirmed"

**Related entities:**
- `related_type`: "inquiry"
- `related_id`: inquiry_id

---

### 3. **PROPERTY_AVAILABLE** (New)
**When triggered:**
- A new property matching tenant's saved search criteria becomes available
- A property the tenant viewed becomes available again (was unavailable, now available)
- A new unit is added to a property the tenant is interested in

**Example notifications:**
- "New property available: [Property Name] in [Location]"
- "[Property Name] is now available for rent"
- "New unit added to [Property Name] - check it out!"

**Related entities:**
- `related_type`: "property"
- `related_id`: property_id

---

### 4. **PROPERTY_UPDATE** (New)
**When triggered:**
- Property details are updated (price, amenities, availability)
- Property status changes (active → inactive, or vice versa)
- Property images are updated

**Example notifications:**
- "[Property Name] price has been updated"
- "New photos added to [Property Name]"
- "[Property Name] details have been updated"

**Related entities:**
- `related_type`: "property"
- `related_id`: property_id

---

### 5. **VIEWING_CONFIRMED** (New)
**When triggered:**
- Property manager confirms a viewing appointment
- Viewing appointment is scheduled
- Viewing appointment is cancelled or rescheduled

**Example notifications:**
- "Your viewing request for [Property Name] has been confirmed for [Date/Time]"
- "Viewing appointment for [Property Name] has been rescheduled"
- "Viewing appointment for [Property Name] has been cancelled"

**Related entities:**
- `related_type`: "inquiry" or "viewing"
- `related_id`: inquiry_id or viewing_id

---

### 6. **ACCOUNT_UPDATE** (New)
**When triggered:**
- Profile information is updated
- Account settings are changed
- Password is changed
- Email is verified

**Example notifications:**
- "Your profile has been updated successfully"
- "Your password has been changed"
- "Your email has been verified"

**Related entities:**
- `related_type`: "account"
- `related_id`: user_id

---

### 7. **SYSTEM** ✅ (Already implemented)
**When triggered:**
- System maintenance announcements
- Platform updates
- General system messages

**Example notifications:**
- "Scheduled maintenance on [Date] from [Time]"
- "New features available on the platform"
- "Welcome to JACS Property Management!"

**Related entities:**
- `related_type`: "system"
- `related_id`: null

---

## Summary Table

| Notification Type | Priority | Frequency | User Action Required |
|------------------|----------|-----------|---------------------|
| INQUIRY_RESPONSE | High | Real-time | View message |
| INQUIRY_STATUS_CHANGE | Medium | On status change | Optional |
| PROPERTY_AVAILABLE | Medium | Daily/Weekly | View property |
| PROPERTY_UPDATE | Low | On update | Optional |
| VIEWING_CONFIRMED | High | On confirmation | Confirm attendance |
| ACCOUNT_UPDATE | Low | On change | Optional |
| SYSTEM | Low | As needed | Optional |

---

## Implementation Notes

1. **Notification Priority:**
   - High: Requires immediate attention (inquiry responses, viewing confirmations)
   - Medium: Important but not urgent (property availability, status changes)
   - Low: Informational (updates, system messages)

2. **Notification Frequency:**
   - Real-time: Sent immediately when event occurs
   - Daily digest: Grouped notifications sent once per day
   - Weekly summary: Summary of weekly activity

3. **User Preferences:**
   - Tenants should be able to enable/disable specific notification types
   - Email notifications can be configured separately from in-app notifications

---

## Next Steps

1. Update `NotificationType` enum to include new types
2. Create notification service/helper functions
3. Integrate notification triggers in relevant routes:
   - `tenant_inquiries_new.py` - for inquiry-related notifications
   - `public_units.py` - for property-related notifications
   - `tenant_profile.py` - for account-related notifications
4. Add notification preferences to tenant settings


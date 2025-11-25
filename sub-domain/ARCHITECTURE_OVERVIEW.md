# JACS Subdomain Architecture Overview

## 📋 Table of Contents
1. [Overview](#overview)
2. [Backend Architecture](#backend-architecture)
3. [Frontend Architecture](#frontend-architecture)
4. [Data Models](#data-models)
5. [API Routes](#api-routes)
6. [Authentication & Authorization](#authentication--authorization)
7. [User Roles & Permissions](#user-roles--permissions)
8. [Key Features](#key-features)

---

## Overview

The **JACS Subdomain** is a **Property Management System** designed to handle day-to-day operations for property managers, staff, and tenants. It's a separate system from the main domain, running on **port 5001** (backend) and **port 5173** (frontend).

### Purpose
- **Property Management**: Manage properties, units, and occupancy
- **Tenant Management**: Handle tenant profiles, leases, and communications
- **Staff Management**: Coordinate staff, tasks, and assignments
- **Financial Operations**: Billing, payments, and financial reporting
- **Maintenance**: Track maintenance requests and task assignments
- **Communication**: Announcements and document management
- **Analytics**: Dashboard metrics and reports

### Technology Stack
- **Backend**: Flask 2.3.3, MySQL, SQLAlchemy, JWT Authentication
- **Frontend**: React 18, Vite, React Router, Tailwind CSS, Shadcn UI
- **Ports**: Backend (5001), Frontend (5173)

---

## Backend Architecture

### Directory Structure
```
sub-domain/backend/
├── app/
│   └── __init__.py          # Flask app factory, blueprint registration
├── models/                   # Database models (SQLAlchemy)
│   ├── user.py              # User model with roles
│   ├── property.py          # Property and Unit models
│   ├── tenant.py            # Tenant and Lease models
│   ├── staff.py             # Staff management models
│   ├── bill.py              # Billing and Payment models
│   ├── request.py           # Maintenance Request models
│   ├── announcement.py     # Announcement models
│   ├── document.py          # Document management models
│   ├── task.py              # Task management models
│   └── feedback.py          # Feedback models
├── routes/                   # API route handlers (REST endpoints)
│   ├── auth_routes.py       # Authentication endpoints
│   ├── user_routes.py       # User management
│   ├── property_routes.py   # Property operations
│   ├── tenant_routes.py     # Tenant operations
│   ├── staff_routes.py      # Staff operations
│   ├── billing_routes.py    # Billing operations
│   ├── request_routes.py    # Maintenance requests
│   ├── announcement_routes.py  # Announcements
│   ├── document_routes.py   # Documents
│   ├── task_routes.py       # Tasks
│   └── analytics_routes.py  # Dashboard analytics
├── services/                 # Business logic services
│   └── email_service.py     # Email notifications
├── config/
│   └── config.py           # Configuration (dev/prod/test)
├── migrations/              # Database migrations (Alembic)
├── uploads/                 # File upload directory
├── run.py                   # Application entry point
└── requirements.txt         # Python dependencies
```

### Key Components

#### 1. App Factory (`app/__init__.py`)
- Creates Flask application instance
- Initializes extensions (SQLAlchemy, JWT, CORS, Mail)
- Registers all blueprints with `/api` prefix
- Configures CORS for frontend communication
- Sets up error handlers and health check

#### 2. Configuration (`config/config.py`)
- **Development**: Debug mode, SQL query logging
- **Production**: Optimized settings
- **Testing**: In-memory SQLite database
- Environment variables for database, JWT, mail, uploads

#### 3. Database Models
All models use SQLAlchemy ORM with relationships:
- **User**: Base user model with roles (property_manager, staff, tenant)
- **Property**: Properties with units and occupancy tracking
- **Tenant**: Tenant profiles linked to users and properties
- **Staff**: Staff profiles with departments and positions
- **Bill**: Billing records and payment tracking
- **Request**: Maintenance requests with status tracking
- **Announcement**: System-wide and targeted announcements
- **Document**: File management and document sharing
- **Task**: Task assignments for staff
- **Feedback**: Tenant feedback system

---

## Frontend Architecture

### Directory Structure
```
sub-domain/frontend/
├── src/
│   ├── App.jsx              # Main router configuration
│   ├── main.jsx             # React entry point
│   ├── services/
│   │   └── api.js           # API service layer
│   ├── JACS/
│   │   ├── components/      # Reusable components
│   │   │   ├── RouteProtection.jsx
│   │   │   ├── LoginForm.jsx
│   │   │   ├── Header.jsx
│   │   │   ├── Navigation.jsx
│   │   │   └── ...
│   │   └── pages/           # Page components
│   │       ├── LoginPage.jsx
│   │       ├── property manager/  # Property Manager pages
│   │       │   ├── DashboardPage.jsx
│   │       │   ├── TenantsPage.jsx
│   │       │   ├── StaffPage.jsx
│   │       │   ├── BillsPage.jsx
│   │       │   ├── RequestsPage.jsx
│   │       │   ├── AnnouncementPage.jsx
│   │       │   ├── DocumentsPage.jsx
│   │       │   ├── AnalyticsPage.jsx
│   │       │   ├── TasksPage.jsx
│   │       │   ├── FeedbackPage.jsx
│   │       │   ├── ProfileEditModal.jsx
│   │       │   └── SettingsModal.jsx
│   │       ├── staff/       # Staff pages
│   │       │   ├── StaffDashboardPage.jsx
│   │       │   ├── StaffTasksPage.jsx
│   │       │   ├── StaffRequestsPage.jsx
│   │       │   ├── StaffAnnouncementsPage.jsx
│   │       │   ├── StaffDocumentsPage.jsx
│   │       │   └── ...
│   │       └── tenant/     # Tenant pages
│   │           ├── TenantDashboardPage.jsx
│   │           ├── TenantBillsPage.jsx
│   │           ├── TenantRequestsPage.jsx
│   │           ├── TenantAnnouncementPage.jsx
│   │           ├── TenantDocumentsPage.jsx
│   │           └── ...
│   └── components/ui/       # Shadcn UI components
└── package.json
```

### Key Components

#### 1. App Router (`App.jsx`)
- Defines all routes for the application
- Routes organized by user role:
  - `/` and `/login` - Login page
  - `/dashboard` - Property Manager dashboard
  - `/tenant` - Tenant dashboard
  - `/staff` - Staff dashboard
  - Role-specific pages for each user type

#### 2. API Service (`services/api.js`)
- Centralized API communication layer
- Handles authentication tokens
- Supports dual API endpoints (property portal + main domain)
- Methods for all CRUD operations
- Error handling and token management

#### 3. Route Protection (`components/RouteProtection.jsx`)
- Protects routes based on authentication
- Checks user roles and permissions
- Redirects unauthorized users
- Handles loading states

---

## Data Models

### User Model
```python
- id: Integer (Primary Key)
- email: String (Unique, Indexed)
- username: String (Unique, Indexed)
- password_hash: String
- first_name, last_name: String
- phone_number: String
- role: Enum (property_manager, staff, tenant)
- is_active: Boolean
- is_verified: Boolean
- created_at, updated_at: DateTime
- Relationships: tenant_profile, staff_profile
```

### Property Model
```python
- id: Integer (Primary Key)
- name: String
- address: Text
- property_type: String
- total_units: Integer
- occupied_units: Integer
- created_at, updated_at: DateTime
- Relationships: units, tenants
```

### Tenant Model
```python
- id: Integer (Primary Key)
- user_id: ForeignKey (User)
- property_id: ForeignKey (Property)
- assigned_room: String
- lease_start_date: Date
- lease_end_date: Date
- monthly_rent: Decimal
- Relationships: user, property, bills, requests
```

### Staff Model
```python
- id: Integer (Primary Key)
- user_id: ForeignKey (User)
- department: String
- position: String
- hire_date: Date
- salary: Decimal
- Relationships: user, tasks, requests
```

---

## API Routes

### Authentication (`/api/auth`)
- `POST /login` - User login
- `POST /register` - User registration
- `POST /refresh` - Refresh access token
- `POST /forgot-password` - Request password reset
- `POST /reset-password` - Reset password with token
- `POST /change-password` - Change password (authenticated)
- `GET /me` - Get current user info
- `POST /logout` - User logout

### Properties (`/api/properties`)
- `GET /` - List all properties
- `POST /` - Create property
- `GET /:id` - Get property details
- `PUT /:id` - Update property
- `DELETE /:id` - Delete property

### Tenants (`/api/tenants`)
- `GET /` - List all tenants
- `POST /` - Create tenant
- `GET /:id` - Get tenant details
- `PUT /:id` - Update tenant
- `DELETE /:id` - Delete tenant

### Staff (`/api/staff`)
- `GET /` - List all staff
- `POST /` - Create staff member
- `GET /:id` - Get staff details
- `PUT /:id` - Update staff
- `DELETE /:id` - Delete staff

### Billing (`/api/billing`)
- `GET /income` - Get income records
- `POST /income` - Create income record
- `GET /bills` - List bills
- `POST /bills` - Create bill
- `PUT /bills/:id` - Update bill
- `DELETE /bills/:id` - Delete bill

### Requests (`/api/requests`)
- `GET /` - List maintenance requests
- `POST /` - Create request
- `GET /:id` - Get request details
- `PUT /:id` - Update request
- `DELETE /:id` - Delete request

### Announcements (`/api/announcements`)
- `GET /` - List announcements (with filters)
- `POST /` - Create announcement
- `GET /:id` - Get announcement
- `PUT /:id` - Update announcement
- `DELETE /:id` - Delete announcement
- `GET /stats` - Get announcement statistics

### Documents (`/api/documents`)
- `GET /` - List documents
- `POST /` - Upload document
- `GET /:id` - Get document
- `DELETE /:id` - Delete document

### Tasks (`/api/tasks`)
- `GET /` - List tasks
- `POST /` - Create task
- `GET /:id` - Get task details
- `PUT /:id` - Update task
- `DELETE /:id` - Delete task

### Analytics (`/api/analytics`)
- `GET /dashboard` - Get role-based dashboard data
- `GET /financial-summary` - Financial summary (Manager only)
- `GET /occupancy-report` - Occupancy report (Manager only)

---

## Authentication & Authorization

### JWT Authentication
- **Token Type**: JWT (JSON Web Tokens)
- **Library**: Flask-JWT-Extended
- **Token Storage**: LocalStorage (frontend)
- **Token Expiry**: 1 hour (configurable)
- **Refresh Tokens**: 30 days

### Authentication Flow
1. User submits login credentials
2. Backend validates credentials
3. Backend generates JWT access token + refresh token
4. Frontend stores tokens in LocalStorage
5. Frontend includes token in `Authorization: Bearer <token>` header
6. Backend validates token on protected routes

### Route Protection
- **RouteProtection Component**: Checks authentication before rendering
- **JWT Required Decorator**: Backend validates token on API calls
- **Role-Based Access**: Routes restricted by user role

---

## User Roles & Permissions

### Property Manager
**Access:**
- Full system access
- Dashboard with all metrics
- Manage tenants, staff, properties
- Create/edit/delete announcements
- View analytics and reports
- Manage billing and payments
- Handle maintenance requests
- Manage documents

**Pages:**
- Dashboard, Tenants, Staff, Bills, Requests
- Announcements, Documents, Analytics, Tasks, Feedback

### Staff
**Access:**
- Limited dashboard
- View assigned tasks
- Handle maintenance requests
- View announcements
- Access documents
- Update own profile

**Pages:**
- Staff Dashboard, Tasks, Requests
- Announcements, Documents

### Tenant
**Access:**
- Personal dashboard
- View own bills
- Submit maintenance requests
- View announcements
- Access documents
- Update own profile

**Pages:**
- Tenant Dashboard, Bills, Requests
- Announcements, Documents

---

## Key Features

### 1. Multi-Role System
- Three distinct user roles with different permissions
- Role-based routing and UI rendering
- Separate dashboards for each role

### 2. Property Management
- Create and manage properties
- Track units and occupancy
- Assign tenants to properties/rooms

### 3. Tenant Management
- Complete tenant profiles
- Lease management (start/end dates, rent)
- Tenant-property relationships

### 4. Staff Management
- Staff profiles with departments
- Task assignments
- Position and salary tracking

### 5. Billing System
- Bill creation and management
- Income tracking
- Payment records

### 6. Maintenance Requests
- Request submission (tenants)
- Request assignment (managers)
- Status tracking (pending, in-progress, completed)

### 7. Announcements
- System-wide announcements
- Targeted announcements (by role/property)
- Rich text content
- Priority levels

### 8. Document Management
- File uploads
- Document categorization
- Access control by role

### 9. Task Management
- Task creation and assignment
- Task status tracking
- Staff task lists

### 10. Analytics & Reporting
- Dashboard metrics
- Financial summaries
- Occupancy reports
- Role-based analytics

### 11. Profile Management
- User profile editing
- Emergency contacts
- Professional information
- Address management

### 12. Settings
- Account settings
- Password management
- Notification preferences

---

## API Communication

### Base URLs
- **Property Portal API**: `http://localhost:5001/api`
- **Main Domain API**: `http://localhost:5000/api` (fallback)

### Request Format
```javascript
Headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer <access_token>'
}
```

### Response Format
**Success:**
```json
{
  "data": { ... },
  "message": "Operation successful"
}
```

**Error:**
```json
{
  "error": "Error description",
  "status_code": 400
}
```

---

## Development Workflow

### Starting the Backend
```bash
cd sub-domain/backend
python run.py
# Runs on http://localhost:5001
```

### Starting the Frontend
```bash
cd sub-domain/frontend
npm run dev
# Runs on http://localhost:5173
```

### Environment Variables
Backend requires `.env` file with:
- Database credentials (MySQL)
- JWT secret keys
- Mail server configuration
- Upload folder settings

---

## Next Steps for Understanding

1. **Explore Models**: Review each model file to understand data structure
2. **Review Routes**: Check route handlers to see API endpoints
3. **Examine Components**: Look at React components to understand UI flow
4. **Test API**: Use API service methods to understand data flow
5. **Check Authentication**: Review JWT implementation and route protection

---

This architecture supports a complete property management system with role-based access, comprehensive CRUD operations, and a modern React frontend.


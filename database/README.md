# SE Course Planner Database

Database setup and management for the CS 348 SE Course Planner project.

## 📋 Prerequisites

- MySQL 8.0+ installed and running
- Python 3.11+ with required packages

## 🚀 Quick Setup

### 1. Install MySQL Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Database Connection

Set environment variables (optional - defaults to localhost):

```bash
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=your_password
export DB_NAME=se_course_planner
```

### 3. Initialize Database

```bash
cd database
python setup_database.py reset
```

This will:
- Create the `se_course_planner` database
- Create all tables with proper indexes
- Insert sample data for testing
- Show a summary of loaded data

## 📊 Database Schema

### Core Tables

- **`students`** - Student profiles and authentication
- **`courses`** - Course catalog with descriptions and credits
- **`requirements`** - SE graduation requirements by cohort
- **`terms`** - Academic terms (Fall, Winter, Spring)

### Relationship Tables

- **`student_courses`** - Course enrollments and completions
- **`student_requirements`** - Graduation progress tracking
- **`requirement_courses`** - Course-to-requirement mappings
- **`prerequisites`** - Course prerequisite relationships

### Views

- **`student_progress_summary`** - Aggregated graduation progress
- **`course_prerequisites_view`** - Courses with prerequisite info

## 🔧 Management Commands

### Create Database and Schema
```bash
python setup_database.py create
```

### Reset with Sample Data
```bash
python setup_database.py reset
```

### Test Connection
```bash
python setup_database.py test
```

### View Sample Data
```bash
python setup_database.py sample
```

## 📋 Sample Data

The database includes sample data for:

- **4 SE students** from cohort 2027
- **SE curriculum courses** (1st and 2nd year)
- **Graduation requirements** organized by category
- **Sample course completions** with grades
- **Academic terms** for 2024-2025

### Sample Students

1. **Alice Johnson** - Strong student with completed fall term
2. **Bob Smith** - Average student with some completions
3. **Carol Davis** - New student just starting
4. **David Wilson** - Empty record for testing

## 🔍 Key Features

### Automatic Progress Tracking

The database includes triggers that automatically update graduation requirement progress when students complete courses.

### Flexible Requirements System

Requirements are organized by:
- **Category** (Core, Electives, Skills, Experience)
- **Subcategory** (Software Engineering, Computer Science, Mathematics, etc.)
- **Cohort Year** (allows different requirements for different graduating classes)

### Performance Optimized

Tables include strategic indexes for:
- Student lookups by ID, email, UWID
- Course searches by department, level
- Requirement filtering by category and cohort
- Academic history queries by student and term

## 🧪 Testing Queries

Once the database is set up, you can test with these queries:

```sql
-- View student progress
SELECT * FROM student_progress_summary;

-- Check course prerequisites
SELECT * FROM course_prerequisites_view WHERE course_code = 'CS240';

-- See a student's completed courses
SELECT c.course_code, c.title, sc.grade, sc.completion_date
FROM student_courses sc
JOIN courses c ON sc.course_code = c.course_code
WHERE sc.student_id = 1 AND sc.status = 'completed';
```

## 🔒 Database Security

- Passwords are hashed using bcrypt
- Connection pooling prevents resource exhaustion
- Prepared statements prevent SQL injection
- Environment variables for sensitive configuration

## 📈 Next Steps

After database setup, the next phases involve:

1. **API Development** - Creating FastAPI endpoints
2. **Frontend Integration** - Connecting React components
3. **Authentication System** - Student login/registration
4. **Core Features** - Dashboard, course planning, progress tracking 
-- SE Course Planner Database Schema
-- CS 348 Project - Spring 2025
-- Database: MySQL

-- Drop existing tables if they exist (for reset functionality)
DROP TABLE IF EXISTS student_requirements;
DROP TABLE IF EXISTS student_courses;
DROP TABLE IF EXISTS requirement_courses;
DROP TABLE IF EXISTS prerequisites;
DROP TABLE IF EXISTS requirements;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS terms;

-- Create Terms table
CREATE TABLE terms (
    term_id INT AUTO_INCREMENT PRIMARY KEY,
    term_code VARCHAR(10) UNIQUE NOT NULL,
    term_name VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    start_date DATE,
    end_date DATE
);

-- Create Students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    uwid VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    cohort_year INT NOT NULL,
    program VARCHAR(50) DEFAULT 'Software Engineering'
);

-- Create Courses table
CREATE TABLE courses (
    course_code VARCHAR(20) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    credits DECIMAL(3,2) NOT NULL DEFAULT 0.50,
    department VARCHAR(10) NOT NULL,
    course_level INT NOT NULL
);

-- Create Prerequisites table
CREATE TABLE prerequisites (
    prereq_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    prereq_course_code VARCHAR(20) NOT NULL,
    prereq_type ENUM('prerequisite', 'corequisite', 'antirequisite') DEFAULT 'prerequisite',
    is_required BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (course_code) REFERENCES courses(course_code) ON DELETE CASCADE,
    FOREIGN KEY (prereq_course_code) REFERENCES courses(course_code) ON DELETE CASCADE,
    UNIQUE KEY unique_course_prereq (course_code, prereq_course_code, prereq_type)
);

-- Create Requirements table
CREATE TABLE requirements (
    requirement_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    credits_needed DECIMAL(4,2) NOT NULL,
    cohort_year INT NOT NULL,
    description TEXT
);

-- Create Requirement_Courses junction table
CREATE TABLE requirement_courses (
    req_course_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    notes TEXT,
    FOREIGN KEY (requirement_id) REFERENCES requirements(requirement_id) ON DELETE CASCADE,
    FOREIGN KEY (course_code) REFERENCES courses(course_code) ON DELETE CASCADE,
    UNIQUE KEY unique_req_course (requirement_id, course_code)
);

-- Create Student_Courses table
-- grade field uses 0-100 numeric scale
CREATE TABLE student_courses (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    term_code VARCHAR(10) NOT NULL,
    year INT NOT NULL,
    status ENUM('enrolled', 'completed', 'dropped', 'failed', 'in_progress') DEFAULT 'enrolled',
    grade DECIMAL(5,2) NOT NULL CHECK (grade >= 0 AND grade <= 100),
    completion_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_code) REFERENCES courses(course_code) ON DELETE CASCADE,
    UNIQUE KEY unique_student_course_term (student_id, course_code, term_code, year)
);

-- Create Student_Requirements table
CREATE TABLE student_requirements (
    student_req_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    requirement_id INT NOT NULL,
    credits_completed DECIMAL(4,2) DEFAULT 0.00,
    is_satisfied BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (requirement_id) REFERENCES requirements(requirement_id) ON DELETE CASCADE,
    UNIQUE KEY unique_student_requirement (student_id, requirement_id)  
);

-- Create triggers to update student_requirements when courses are completed
CREATE TRIGGER update_student_requirements_after_completion
AFTER UPDATE ON student_courses
FOR EACH ROW
BEGIN
    -- Only update if status changed to completed and grade is passing
    IF NEW.status = 'completed' AND OLD.status != 'completed' AND NEW.grade >= 50 THEN
        
        -- Update all requirements that this course satisfies
        UPDATE student_requirements sr
        INNER JOIN requirement_courses rc ON sr.requirement_id = rc.requirement_id
        SET sr.credits_completed = (
            SELECT COALESCE(SUM(c.credits), 0)
            FROM student_courses sc
            INNER JOIN courses c ON sc.course_code = c.course_code
            INNER JOIN requirement_courses rc2 ON c.course_code = rc2.course_code
            WHERE sc.student_id = NEW.student_id 
                AND rc2.requirement_id = sr.requirement_id
                AND sc.status = 'completed'
                AND sc.grade >= 50
        ),
        sr.is_satisfied = (
            SELECT CASE 
                WHEN COALESCE(SUM(c.credits), 0) >= r.credits_needed THEN TRUE 
                ELSE FALSE 
            END
            FROM student_courses sc
            INNER JOIN courses c ON sc.course_code = c.course_code
            INNER JOIN requirement_courses rc2 ON c.course_code = rc2.course_code
            INNER JOIN requirements r ON rc2.requirement_id = r.requirement_id
            WHERE sc.student_id = NEW.student_id 
                AND rc2.requirement_id = sr.requirement_id
                AND sc.status = 'completed'
                AND sc.grade >= 50
            GROUP BY r.requirement_id
        )
        WHERE sr.student_id = NEW.student_id
            AND rc.course_code = NEW.course_code;
    END IF;
END;

-- Sample data will be inserted via separate script
-- Views for common queries
CREATE OR REPLACE VIEW student_progress_summary AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.cohort_year,
    COALESCE(course_data.courses_completed, 0) as courses_completed,
    COALESCE(course_data.total_credits, 0) as total_credits,
    COALESCE(req_data.total_requirements, 0) as total_requirements,
    COALESCE(req_data.satisfied_requirements, 0) as satisfied_requirements,
    ROUND(COALESCE(req_data.satisfied_requirements, 0) * 100.0 / NULLIF(req_data.total_requirements, 0), 2) as completion_percentage
FROM students s
LEFT JOIN (
    SELECT 
        sc.student_id,
        COUNT(DISTINCT sc.course_code) as courses_completed,
        SUM(c.credits) as total_credits
    FROM student_courses sc
    JOIN courses c ON sc.course_code = c.course_code
    WHERE sc.status = 'completed'
    GROUP BY sc.student_id
) course_data ON s.student_id = course_data.student_id
LEFT JOIN (
    SELECT 
        sr.student_id,
        COUNT(sr.requirement_id) as total_requirements,
        COUNT(CASE WHEN sr.is_satisfied THEN sr.requirement_id END) as satisfied_requirements
    FROM student_requirements sr
    GROUP BY sr.student_id
) req_data ON s.student_id = req_data.student_id;

CREATE OR REPLACE VIEW course_prerequisites_view AS
SELECT 
    c.course_code,
    c.title,
    c.credits,
    GROUP_CONCAT(DISTINCT CONCAT(p.prereq_course_code, ' (', p.prereq_type, ')') SEPARATOR ', ') as prerequisites
FROM courses c
LEFT JOIN prerequisites p ON c.course_code = p.course_code
GROUP BY c.course_code, c.title, c.credits;

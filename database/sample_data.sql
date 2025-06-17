-- Sample Data for SE Course Planner
-- CS 348 Project - Spring 2025

-- Clear existing data
DELETE FROM student_requirements;
DELETE FROM student_courses;
DELETE FROM requirement_courses;
DELETE FROM prerequisites;
DELETE FROM requirements;
DELETE FROM courses;
DELETE FROM students;
DELETE FROM terms;

-- Insert Terms
INSERT INTO terms (term_code, term_name, year, start_date, end_date) VALUES
('F24', 'Fall 2024', 2024, '2024-09-01', '2024-12-15'),
('W25', 'Winter 2025', 2025, '2025-01-01', '2025-04-15'),
('S25', 'Spring 2025', 2025, '2025-05-01', '2025-08-15'),
('F25', 'Fall 2025', 2025, '2025-09-01', '2025-12-15');

-- Insert Sample Students (SE 2027 cohort)
-- Password for all test users is "password123"
INSERT INTO students (uwid, first_name, last_name, email, password_hash, cohort_year) VALUES
('20012345', 'Alice', 'Johnson', 'alice.johnson@uwaterloo.ca', '$2b$12$CRftzBOLRpbOa6rLNP6kH.Jh9lLOIoVe3xJ.3OAGl82rqKfUgQ6Nu', 2027),
('20012346', 'Bob', 'Smith', 'bob.smith@uwaterloo.ca', '$2b$12$CRftzBOLRpbOa6rLNP6kH.Jh9lLOIoVe3xJ.3OAGl82rqKfUgQ6Nu', 2027),
('20012347', 'Carol', 'Davis', 'carol.davis@uwaterloo.ca', '$2b$12$CRftzBOLRpbOa6rLNP6kH.Jh9lLOIoVe3xJ.3OAGl82rqKfUgQ6Nu', 2027),
('20012348', 'David', 'Wilson', 'david.wilson@uwaterloo.ca', '$2b$12$CRftzBOLRpbOa6rLNP6kH.Jh9lLOIoVe3xJ.3OAGl82rqKfUgQ6Nu', 2027);

-- Insert Core SE Courses
INSERT INTO courses (course_code, title, description, credits, department, course_level) VALUES
-- First Year Core
('SE101', 'Methods of Software Engineering', 'Introduction to software engineering principles', 0.50, 'SE', 100),
('CS135', 'Designing Functional Programs', 'Introduction to programming using functional programming', 0.50, 'CS', 100),
('CS136', 'Elementary Algorithm Design and Data Abstraction', 'Algorithm design and data structures', 0.50, 'CS', 100),
('MATH135', 'Algebra for Honours Mathematics', 'Mathematical reasoning and algebra', 0.50, 'MATH', 100),
('MATH136', 'Linear Algebra 1 for Honours Mathematics', 'Linear algebra fundamentals', 0.50, 'MATH', 100),
('MATH137', 'Calculus 1 for Honours Mathematics', 'Differential calculus', 0.50, 'MATH', 100),
('MATH138', 'Calculus 2 for Honours Mathematics', 'Integral calculus', 0.50, 'MATH', 100),
('PHYS121', 'Mechanics', 'Classical mechanics', 0.50, 'PHYS', 100),
('SE102', 'Seminar', 'Engineering seminar', 0.50, 'SE', 100),
('ECE105', 'Classical Mechanics', 'Engineering mechanics', 0.50, 'ECE', 100),

-- Second Year Core
('SE201', 'Seminar', 'Software engineering seminar', 0.50, 'SE', 200),
('SE212', 'Logic and Computation', 'Mathematical logic and computation', 0.50, 'SE', 200),
('CS240', 'Data Structures and Data Management', 'Advanced data structures', 0.50, 'CS', 200),
('CS241', 'Foundations of Sequential Programs', 'Assembly language and compilers', 0.50, 'CS', 200),
('MATH213', 'Linear Algebra and Differential Equations', 'Linear algebra applications', 0.50, 'MATH', 200),
('STAT206', 'Statistics for Software Engineering', 'Statistical methods', 0.50, 'STAT', 200),

-- Electives
('CS245', 'Logic and Computation', 'Mathematical logic', 0.50, 'CS', 200),
('CS246', 'Object-Oriented Software Development', 'OOP principles', 0.50, 'CS', 200),
('ECE124', 'Digital Circuits and Systems', 'Digital logic design', 0.50, 'ECE', 100),
('ECON101', 'Introduction to Microeconomics', 'Basic microeconomics', 0.50, 'ECON', 100),
('PHIL145', 'Critical Thinking', 'Logic and reasoning', 0.50, 'PHIL', 100);

-- Insert Prerequisites
INSERT INTO prerequisites (course_code, prereq_course_code, prereq_type) VALUES
('CS136', 'CS135', 'prerequisite'),
('MATH136', 'MATH135', 'prerequisite'),
('MATH138', 'MATH137', 'prerequisite'),
('CS240', 'CS136', 'prerequisite'),
('CS241', 'CS136', 'prerequisite'),
('CS246', 'CS136', 'prerequisite'),
('MATH213', 'MATH136', 'prerequisite'),
('MATH213', 'MATH138', 'prerequisite');

-- Insert SE 2027 Requirements
INSERT INTO requirements (requirement_name, category, subcategory, credits_needed, cohort_year, description) VALUES
-- Core Requirements
('SE Core Courses', 'Core', 'Software Engineering', 6.00, 2027, 'Required SE courses'),
('CS Core Courses', 'Core', 'Computer Science', 4.00, 2027, 'Required CS courses'),
('Math Core Courses', 'Core', 'Mathematics', 4.00, 2027, 'Required mathematics courses'),
('Science Requirements', 'Core', 'Science', 1.00, 2027, 'Required science courses'),
('Engineering Requirements', 'Core', 'Engineering', 1.00, 2027, 'Required engineering courses'),

-- Elective Requirements  
('CS Electives', 'Electives', 'Computer Science', 2.00, 2027, 'CS elective courses'),
('Technical Electives', 'Electives', 'Technical', 2.00, 2027, 'Technical elective courses'),
('Non-Technical Electives', 'Electives', 'Non-Technical', 2.50, 2027, 'Non-technical elective courses'),

-- Additional Requirements
('Communication Skills', 'Skills', 'Communication', 1.00, 2027, 'Communication and writing skills'),
('Work Experience', 'Experience', 'Co-op', 0.00, 2027, 'Work term requirements');

-- Map courses to requirements
INSERT INTO requirement_courses (requirement_id, course_code, is_required) VALUES
-- SE Core
(1, 'SE101', TRUE),
(1, 'SE102', TRUE), 
(1, 'SE201', TRUE),
(1, 'SE212', TRUE),

-- CS Core
(2, 'CS135', TRUE),
(2, 'CS136', TRUE),
(2, 'CS240', TRUE),
(2, 'CS241', TRUE),

-- Math Core
(3, 'MATH135', TRUE),
(3, 'MATH136', TRUE),
(3, 'MATH137', TRUE),
(3, 'MATH138', TRUE),
(3, 'MATH213', TRUE),
(3, 'STAT206', TRUE),

-- Science
(4, 'PHYS121', TRUE),

-- Engineering
(5, 'ECE105', TRUE),

-- CS Electives
(6, 'CS245', FALSE),
(6, 'CS246', FALSE),

-- Technical Electives
(7, 'ECE124', FALSE),

-- Non-Technical Electives
(8, 'ECON101', FALSE),
(8, 'PHIL145', FALSE);

-- Insert sample student course enrollments
INSERT INTO student_courses (student_id, course_code, term_code, year, status, grade, completion_date) VALUES
-- Alice Johnson (student_id: 1) - Strong student
(1, 'SE101', 'F24', 2024, 'completed', 95.0, '2024-12-15'),
(1, 'CS135', 'F24', 2024, 'completed', 90.0, '2024-12-15'),
(1, 'MATH135', 'F24', 2024, 'completed', 87.0, '2024-12-15'),
(1, 'MATH137', 'F24', 2024, 'completed', 83.0, '2024-12-15'),
(1, 'PHYS121', 'F24', 2024, 'completed', 80.0, '2024-12-15'),
(1, 'SE102', 'W25', 2025, 'in_progress', 0.0, NULL),
(1, 'CS136', 'W25', 2025, 'in_progress', 0.0, NULL),
(1, 'MATH136', 'W25', 2025, 'in_progress', 0.0, NULL),
(1, 'MATH138', 'W25', 2025, 'in_progress', 0.0, NULL),
(1, 'ECE105', 'W25', 2025, 'in_progress', 0.0, NULL),

-- Bob Smith (student_id: 2) - Average student
(2, 'SE101', 'F24', 2024, 'completed', 78.0, '2024-12-15'),
(2, 'CS135', 'F24', 2024, 'completed', 75.0, '2024-12-15'),
(2, 'MATH135', 'F24', 2024, 'completed', 68.0, '2024-12-15'),
(2, 'MATH137', 'F24', 2024, 'completed', 72.0, '2024-12-15'),
(2, 'PHYS121', 'F24', 2024, 'completed', 65.0, '2024-12-15'),
(2, 'SE102', 'W25', 2025, 'enrolled', 0.0, NULL),
(2, 'CS136', 'W25', 2025, 'enrolled', 0.0, NULL),
(2, 'MATH136', 'W25', 2025, 'enrolled', 0.0, NULL),
(2, 'MATH138', 'W25', 2025, 'enrolled', 0.0, NULL),

-- Carol Davis (student_id: 3) - New student
(3, 'SE101', 'W25', 2025, 'enrolled', 0.0, NULL),
(3, 'CS135', 'W25', 2025, 'enrolled', 0.0, NULL),
(3, 'MATH135', 'W25', 2025, 'enrolled', 0.0, NULL),
(3, 'MATH137', 'W25', 2025, 'enrolled', 0.0, NULL);

-- Initialize student requirements tracking
INSERT INTO student_requirements (student_id, requirement_id, credits_completed, is_satisfied)
SELECT s.student_id, r.requirement_id, 0.00, FALSE
FROM students s
CROSS JOIN requirements r
WHERE r.cohort_year = s.cohort_year;

-- Update student requirements based on completed courses
-- This would normally be handled by triggers, but we'll update manually for sample data
UPDATE student_requirements sr
SET sr.credits_completed = (
    SELECT COALESCE(SUM(c.credits), 0)
    FROM student_courses sc
    INNER JOIN courses c ON sc.course_code = c.course_code
    INNER JOIN requirement_courses rc ON c.course_code = rc.course_code
    WHERE sc.student_id = sr.student_id 
      AND rc.requirement_id = sr.requirement_id
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
    INNER JOIN requirement_courses rc ON c.course_code = rc.course_code
    INNER JOIN requirements r ON rc.requirement_id = r.requirement_id
    WHERE sc.student_id = sr.student_id 
      AND rc.requirement_id = sr.requirement_id
      AND sc.status = 'completed'
      AND sc.grade >= 50
    GROUP BY r.requirement_id
);

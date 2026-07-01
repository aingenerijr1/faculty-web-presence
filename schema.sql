-- Module 6 Assignment Faculty Web Page schema.sql | Adrian Diaz | Andrew Ingeneri 

-- Defining Tables (3NF) 

-- DEPARTMENTS TABLE (Lookup table for each academic branch)
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    office_building VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- FACULTY TABLE (Core Entity)
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    office_location VARCHAR(50) NOT NULL,
    biography TEXT,
    research_interests TEXT,
    profile_image_url VARCHAR(255) DEFAULT 'https://via.placeholder.com/150',
    department_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_faculty_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) 
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- COURSES TABLE (Catalog of available courses)
CREATE TABLE courses (
    course_code VARCHAR(15) PRIMARY KEY, -- (such as 'COP4504')
    course_name VARCHAR(100) NOT NULL,
    credit_hours INT DEFAULT 3
) ENGINE=InnoDB;

-- FACULTY_COURSES TABLE (Junction table resolving Many-to-Many teaching schedules)
-- *Uses surrogate assignment_id + semester_taught to allow repeated teaching*
CREATE TABLE faculty_courses (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id INT NOT NULL,
    course_code VARCHAR(15) NOT NULL,
    semester_taught VARCHAR(30) NOT NULL, -- e.g., 'Fall 2026'
    CONSTRAINT fk_fc_faculty 
        FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_fc_course 
        FOREIGN KEY (course_code) 
        REFERENCES courses(course_code) 
        ON DELETE CASCADE,
    CONSTRAINT uq_instructor_course_sem 
        UNIQUE KEY (faculty_id, course_code, semester_taught)
) ENGINE=InnoDB;

-- PUBLICATIONS TABLE (Optional database design to test deletion)
CREATE TABLE publications (
    pub_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    publish_year INT NOT NULL,
    article_url VARCHAR(255),
    CONSTRAINT fk_pub_faculty 
        FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) 
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- Seed Testing Data (For testing so 'READ' operations work instantly)

-- Seed Departments
INSERT INTO departments (department_name, office_building) VALUES 
('College of Computer & Information Technology', 'UP Building'),
('Department of Natural Sciences', 'SC Building');

-- Seed Faculty 
INSERT INTO faculty (first_name, last_name, title, email, phone, office_location, biography, research_interests, department_id) 
VALUES 
('John', 'Doe', 'Senior Professor of Computer Science', 'jdoe@spc.edu', '555-0101', 'UP-337', 
 'Dr. Doe has been teaching full-stack web architectures for 15 years. Passionate about semantic HTML and backend optimization.', 
 'Relational Database Integrity, Asynchronous JavaScript, Web UI Accessibility', 1),

('Sarah', 'Jenkins', 'Associate Professor of Data Science', 'sjenkins@spc.edu', '555-0188', 'UP-340', 
 'Specializes in predictive modeling and Python frameworks.', 
 'Neural Networks, Big Data Ethics', 1);

-- Seed Courses
INSERT INTO courses (course_code, course_name, credit_hours) VALUES 
('COP4504', 'Advanced Web App Development', 3),
('TST101', 'Backend Database Testing', 3),
('CIS3360', 'Principles of Information Security', 3);

-- Seed Teaching Assignments
INSERT INTO faculty_courses (faculty_id, course_code, semester_taught) VALUES 
(1, 'COP4504', 'Summer 2026'),
(1, 'TST101', 'Fall 2026'),
(2, 'CIS3360', 'Fall 2026');

-- Seed Publications
INSERT INTO publications (faculty_id, title, publish_year, article_url) VALUES 
(1, 'Mitigating SQL Injection via Parameterized Node.js Drivers', 2025, 'https://doi.org/10.1000/xyz123'),
(1, 'The Death of the Browsewrap Agreement in UI UX', 2024, 'https://doi.org/10.1000/abc456');
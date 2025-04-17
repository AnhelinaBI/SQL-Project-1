-- 1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.

SELECT 
    YEAR(s.from_date) AS report_year,
    ROUND(AVG(s.salary), 2) AS 'average salary'
FROM
    employees.salaries AS s
GROUP BY 1
HAVING report_year BETWEEN MIN(report_year) AND 2005
ORDER BY report_year;

-- 2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників
SELECT 
    dept_name, AVG(salary) AS average_salary
FROM
    salaries
        JOIN
    dept_emp ON dept_emp.emp_no = salaries.emp_no
        AND dept_emp.to_date > CURDATE()
        JOIN
    departments ON dept_emp.dept_no = departments.dept_no
WHERE
    salaries.to_date > CURDATE()
GROUP BY dept_name;


-- 3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік
SELECT 
    dept_name,
    YEAR(salaries.from_date) AS report_year,
    AVG(salary) AS average_salary
FROM
    salaries
        JOIN
    dept_emp ON dept_emp.emp_no = salaries.emp_no
        JOIN
    departments ON dept_emp.dept_no = departments.dept_no
GROUP BY dept_name , report_year;

-- 4. Покажіть відділи в яких зараз працює більше 15000 співробітників.

SELECT 
    dept_name, COUNT(emp_no) AS employee_count
FROM
    dept_emp
        JOIN
    departments ON departments.dept_no = dept_emp.dept_no
WHERE
    to_date > CURDATE()
GROUP BY dept_name
HAVING COUNT(emp_no) > 15000;

-- 5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище

SELECT 
    dm.emp_no, d.dept_name, e.hire_date, e.last_name
FROM
    employees.employees AS e
        INNER JOIN
    employees.dept_manager AS dm ON (e.emp_no = dm.emp_no)
        AND (CURRENT_DATE() BETWEEN dm.from_date AND dm.to_date)
        INNER JOIN
    employees.departments AS d ON (dm.dept_no = d.dept_no)
ORDER BY TIMESTAMPDIFF(DAY,
    e.hire_date,
    CURRENT_DATE()) DESC
LIMIT 1;

-- 6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.

WITH tabl1 AS (
    SELECT 
          dept_no, AVG(salary) AS avg_dept_salary 
	FROM 
        salaries
    JOIN 
        dept_emp ON salaries.emp_no = dept_emp.emp_no AND dept_emp.to_date > CURDATE()
    WHERE 
         salaries.to_date > CURDATE()
    GROUP BY dept_no
)
SELECT 
      salaries.emp_no, ROUND(ABS(salary - avg_dept_salary)) AS diff 
FROM 
      salaries
JOIN 
      dept_emp ON dept_emp.emp_no = salaries.emp_no AND dept_emp.to_date > CURDATE()
JOIN 
      tabl1 ON dept_emp.dept_no = tabl1.dept_no
WHERE 
     salaries.to_date > CURDATE()
ORDER BY diff DESC
LIMIT 10;


-- 7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу

WITH tab1 AS(
SELECT *,
        ROW_NUMBER() OVER (PARTITION BY dept_no ORDER BY from_date) AS 'num' 
    FROM 
        dept_manager)
	  
SELECT 
    dept_name, 
    CONCAT(first_name, ' ', last_name) AS 'first name & last_name', 
    hire_date, 
    tab1.from_date FROM tab1
JOIN 
          departments ON departments.dept_no = tab1.dept_no
	  JOIN 
		 employees ON employees.emp_no = tab1.emp_no
WHERE num = 2
;

-- Дизайн бази даних:

-- 1. Створіть базу даних для управління курсами. База має включати наступні таблиці:

-- - students: student_no, teacher_no, course_no, student_name, email, birth_date.

-- - teachers: teacher_no, teacher_name, phone_no

-- - courses: course_no, course_name, start_date, end_date
 
START TRANSACTION;
DROP DATABASE IF EXISTS step_project;
CREATE DATABASE IF NOT EXISTS step_project;
USE step_project;

CREATE TABLE IF NOT EXISTS teachers (
    teacher_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(255),
    phone_no VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS courses (
    course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255),
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS students (
    student_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_no INT,
    course_no INT,
    student_name VARCHAR(255),
    email VARCHAR(255),
    birth_date DATE,
    FOREIGN KEY (teacher_no) REFERENCES teachers(teacher_no),
    FOREIGN KEY (course_no) REFERENCES courses(course_no)
);

-- 2. Додайте будь-які данні (7-10 рядків) в кожну таблицю.

INSERT INTO teachers (teacher_name, phone_no) VALUES
('John Doe', '123-456-7890'),
('Jack Nick', '153-456-6590'),
('Dick Duck', '153-456-6590'),
('Dave Dillan', '753-456-6590'),
('Karoll Salt', '653-856-6490'),
('Kylie Janner', '153-456-6320'),
('Jane Smith', '387-754-3210');

INSERT INTO courses (course_name, start_date, end_date) VALUES
('Mathematics', '2024-03-01', '2024-06-30'),
('Philosophy', '2024-03-21', '2024-06-20'),
('Physics', '2024-03-21', '2024-06-18'),
('Chemistry', '2024-03-21', '2024-06-30'),
('History', '2024-03-15', '2024-06-15');

INSERT INTO students (teacher_no, course_no, student_name, email, birth_date) VALUES
(1, 1, 'Isabella Johnson', 'isabella@example.com', '2002-05-10'),
(7, 2, 'William Smith', 'william@example.com', '2000-09-20'),
(4, 1, 'Sophia Brown', 'sophia@example.com', '2001-07-15'),
(2, 2, 'Jackson Davis', 'jackson@example.com', '1999-03-25'),
(5, 2, 'Charlotte Wilson', 'charlotte@example.com', '2000-11-28'),
(2, 2, 'Alexander Taylor', 'alexander@example.com', '2002-04-18'),
(6, 1, 'Mia Martinez', 'mia@example.com', '1998-12-02'),
(7, 1, 'Ethan Anderson', 'ethan@example.com', '2001-06-05'),
(6, 2, 'Amelia Thomas', 'amelia@example.com', '2003-01-15'),
(5, 2, 'Lucas Wilson', 'lucas@example.com', '2002-09-10');

COMMIT;   

-- 3. По кожному викладачу покажіть кількість студентів з якими він працював

SELECT 
    students.teacher_no, teacher_name, COUNT(student_no)
FROM
    students
        JOIN
    teachers ON students.teacher_no = teachers.teacher_no
GROUP BY students.teacher_no
;

-- 4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки)
INSERT INTO step_project.students (teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no, course_no, student_name, email, birth_date
FROM step_project.students
LIMIT 3;

-- 5. Напишіть запит який виведе дублюючі рядки в таблиці students
SELECT 
    teacher_no, 
    course_no, 
    student_name, 
    email, 
    birth_date, 
    COUNT(teacher_no) AS duplicate_count
FROM 
    students
GROUP BY 
    teacher_no, 
    course_no, 
    student_name, 
    email, 
    birth_date
HAVING 
    COUNT(teacher_no) > 1;
    

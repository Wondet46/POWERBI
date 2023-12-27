-- Create a new database named 'myhr'
CREATE DATABASE myhr;

-- Use the 'myhr' database
USE myhr;

-- Check the current structure of the 'hr' table
DESCRIBE hr;

-- Rename the 'id' column to 'emp_id'
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Check the updated structure
DESCRIBE hr;

-- Update the 'birthdate' column based on specified conditions
-- Convert date formats to 'YYYY-MM-DD' and handle cases where 'emp_id' is not NULL
SET SQL_SAFE_UPDATES = 0;

-- Update 'birthdate'
UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END
WHERE emp_id IS NOT NULL;

-- Update 'hire_date' using similar logic
UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END
WHERE emp_id IS NOT NULL;

-- Reset SQL_SAFE_UPDATES to 1 (enabled)
SET SQL_SAFE_UPDATES = 1;

-- Check the 'birthdate' column after the update
SELECT * FROM hr;

-- Alter the data type of the 'birthdate' column to 'DATE'
ALTER TABLE hr
CHANGE COLUMN hire_date hire_date DATE NULL;

-- Check the final structure of the 'hr' table
DESCRIBE hr;

-- Update the 'termdate' column
-- Convert 'termdate' to DATE format
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

-- Update the 'termdate' column to correct invalid date values
-- Set 'termdate' to NULL for invalid date values
UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- Alter the data type of the 'termdate' column to 'DATE'
ALTER TABLE hr
MODIFY COLUMN termdate DATE NULL;

-- Select 'emp_id' and 'termdate' from hr
SELECT emp_id, termdate FROM hr;

-- Add the 'age' column
ALTER TABLE hr ADD COLUMN age INT(2);

-- Update the 'age' column based on 'birthdate'
UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

-- Select 'birthdate' and 'age' from hr
SELECT birthdate, age FROM hr;

-- Select the youngest and oldest age
SELECT MIN(age) AS youngest, MAX(age) AS oldest FROM hr;

-- Count the number of employees with age less than 18
SELECT COUNT(*) FROM hr WHERE age < 18;

-- Delete rows where age is less than 18
DELETE FROM hr
WHERE age < 18;

-- Select 'gender' and count from hr where 'termdate' is null (assuming you want null values)
SELECT gender, COUNT(*) AS count 
FROM hr
WHERE age >= 18 and termdate IS NULL GROUP BY gender;

-- Select 'race' and count from hr where 'termdate' is null
SELECT race, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL GROUP BY race
ORDER BY count(*) DESC;

-- Select the youngest and oldest age from hr
SELECT 
  min(age) AS Youngest,
  max(age) AS oldest
FROM hr;

-- Select age groups and count from hr
SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+'
  END AS age_group,gender,
  COUNT(*) AS count
FROM hr
WHERE age >= 18 and termdate IS NULL
GROUP BY age_group,gender
ORDER BY age_group,gender;

SELECT 
  CASE 
    WHEN location = 'Headquarters' THEN 'Headquarters'
    WHEN location = 'Remote' THEN 'Remote'
  END AS location,
    COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location 
ORDER BY location,  count;

-- Calculate the average length of employment for terminated employees
-- Rounded to the nearest whole number (years)
SELECT 
  ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 0) AS avg_length_employment
FROM hr
WHERE termdate <= CURDATE() AND termdate IS NOT NULL;

-- Count employees by department and gender where termdate is null
SELECT 
  department,
  gender,
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- Count employees by job title where termdate is null
SELECT 
  jobtitle,
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle;

-- Calculate termination rate by department
-- Including total employee count and terminated employee count
SELECT 
  department,
  total_count,
  terminated_count,
  terminated_count / total_count AS termination_rate
FROM (
  SELECT 
    department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
  FROM hr
  WHERE age >= 18
  GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;


SELECT location_city, 
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_city
ORDER BY count desc;

SELECT location_state,
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count desc;

-- Calculate net change and net change percentage of hires and terminations per year
SELECT 
  year,                              -- Select the year
  hires,                             -- Select the count of hires
  terminations,                      -- Select the count of terminations
  hires = terminations AS net_change,                           -- Check if hires are equal to terminations
  ROUND((hires - terminations) / hires * 100, 2) AS net_change_percent -- Calculate net change percentage
FROM (
  SELECT 
    YEAR(hire_date) AS year,                               -- Extract the year from hire_date
    COUNT(*) AS hires,                                     -- Count the number of hires
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations -- Count the number of terminations
  FROM hr
  WHERE age >= 18
  GROUP BY YEAR(hire_date)                                -- Group by year
) AS subquery
ORDER BY year ASC; 

-- Calculate average tenure distribution in years by department
SELECT 
  department,
  ROUND(AVG(DATEDIFF(CURDATE(), hire_date) / 365), 0) AS avg_tenure_years
FROM hr
WHERE termdate <= CURDATE() AND termdate IS NOT NULL AND age >= 18
GROUP BY department
ORDER BY avg_tenure_years;
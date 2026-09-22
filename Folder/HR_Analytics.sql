-- 1. find the average monthly income for each department, ordered from highest to lowest average income

SELECT 
    j.department, 
    ROUND(AVG(c.monthly_income), 2) AS avg_monthly_income
FROM Job_Details j
JOIN Compensation AS c ON j.emp_id = c.emp_id
GROUP BY j.department
ORDER BY avg_monthly_income DESC;

-- 2. Find the average job satisfaction and environment satisfaction grouped by over_time status.

SELECT 
    j.over_time,
    ROUND(AVG(js.job_satisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(js.environment_satisfaction), 2) AS avg_env_satisfaction,
    COUNT(j.emp_id) AS total_employees
FROM Job_Details j
JOIN Job_Satisfaction js ON j.emp_id = js.emp_id
GROUP BY j.over_time; 

-- 3. Identifying Stagnant Careers (No Promotion in 5+ Years)

SELECT 
    emp_id, 
    department, 
    job_role, 
    years_at_company, 
    years_since_last_promotion
FROM Job_Details
WHERE years_since_last_promotion >= 5 
  AND years_at_company > 7
ORDER BY years_at_company DESC;

-- 4. Find the average age, total working years, and headcount for each education_field.

SELECT 
    education_field,
    COUNT(emp_id) AS total_headcount,
    ROUND(AVG(age), 1) AS average_age,
    ROUND(AVG(total_working_years), 1) AS avg_working_years
FROM Employees
GROUP BY education_field
ORDER BY total_headcount DESC;

-- 5. Find the average number of training sessions attended (training_times_last_year) grouped by performance_rating.

SELECT 
    performance_rating,
    ROUND(AVG(training_times_last_year), 2) AS avg_trainings_attended,
    COUNT(emp_id) AS total_employees
FROM Job_Satisfaction
GROUP BY performance_rating
ORDER BY performance_rating DESC;
 
-- 6. Retrieve the employee ID, job role, monthly income, and marital status for these high-earning employees.
SELECT 
    e.emp_id, 
    j.job_role, 
    c.monthly_income, 
    e.marital_status
FROM Employees e
JOIN Compensation c ON e.emp_id = c.emp_id
JOIN Job_details j ON e.emp_id = j.emp_id
WHERE j.job_role IN ('Sales Executive', 'Research Scientist') 
  AND c.monthly_income > 10000;
  
-- 7. Group employees by their performance rating and calculate the average percent_salary_hike and employee count.

SELECT 
    js.performance_rating,
    ROUND(AVG(c.percent_salary_hike), 2) AS avg_salary_hike,
    COUNT(js.emp_id) AS employee_count
FROM Job_Satisfaction js
JOIN Compensation c ON js.emp_id = c.emp_id
GROUP BY js.performance_rating
ORDER BY js.performance_rating DESC;   

-- 8. Retrieve employee details for individuals where work_life_balance = 1, business_travel = 'Travel_Frequently', and attrition = 'No'.2

SELECT 
    e.emp_id, 
    j.department, 
    j.job_role, 
    j.business_travel, 
    js.work_life_balance
FROM Employees e
JOIN Job_details j ON e.emp_id = j.emp_id
JOIN Job_Satisfaction js ON e.emp_id = js.emp_id
WHERE js.work_life_balance = 1 
  AND j.business_travel = 'Travel_Frequently'
  AND e.attrition = 'No';
  
 -- 9. salary category based on monthly_income and counts how many employees fall into each tier.
 
 SELECT 
    CASE 
        WHEN monthly_income < 3000 THEN 'Low Income'
        WHEN monthly_income BETWEEN 3000 AND 7000 THEN 'Mid Income'
        WHEN monthly_income BETWEEN 7001 AND 15000 THEN 'High Income'
        ELSE 'Executive Tier'
    END AS income_tier,
    COUNT(emp_id) AS employee_count,
    ROUND(AVG(monthly_income), 2) AS avg_tier_income
FROM Compensation
GROUP BY income_tier
ORDER BY avg_tier_income ASC;

-- 10. List employee ID, age, num_companies_worked, and stock_option_level.

SELECT 
    e.emp_id, 
    e.age, 
    e.num_companies_worked, 
    c.stock_option_level
FROM Employees e
JOIN Compensation c ON e.emp_id = c.emp_id
WHERE e.num_companies_worked >= 4 
  AND c.stock_option_level = 0
ORDER BY e.num_companies_worked DESC;

-- 11. filter employees whose job satisfaction equals 4 and whose department is 'Research & Development'.

SELECT 
    e.emp_id, 
    j.department, 
    j.job_role, 
    js.job_satisfaction
FROM Employees e
JOIN Job_details j ON e.emp_id = j.emp_id
JOIN Job_Satisfaction js ON e.emp_id = js.emp_id
WHERE js.job_satisfaction = 4 
  AND j.department = 'Research & Development';
  
-- 12. List employee ID, years with current manager, relationship satisfaction, and job role.

SELECT 
    j.emp_id, 
    j.job_role, 
    j.years_with_curr_manager, 
    js.relationship_satisfaction
FROM Job_details j
JOIN Job_Satisfaction js ON j.emp_id = js.emp_id
WHERE j.years_with_curr_manager >= 5 
  AND js.relationship_satisfaction = 1
ORDER BY j.years_with_curr_manager DESC;

-- 13. Calculate the total number of employees, total attrition count, and the attrition rate percentage for each department.

SELECT 
    j.department,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.attrition_count) AS total_attrition,
    ROUND((SUM(e.attrition_count) * 100.0) / COUNT(e.emp_id), 2) AS attrition_rate_pct
FROM Employees e
JOIN Job_details j ON e.emp_id = j.emp_id
GROUP BY j.department
ORDER BY attrition_rate_pct DESC;

-- 14. List the employee ID, department, and monthly income for employees who outearn their department's average income using a correlated subquery.

SELECT 
    c1.emp_id, 
    j1.department, 
    c1.monthly_income
FROM Compensation c1
JOIN Job_details j1 ON c1.emp_id = j1.emp_id
WHERE c1.monthly_income > (
    SELECT AVG(c2.monthly_income)
    FROM Compensation c2
    JOIN Job_details j2 ON c2.emp_id = j2.emp_id
    WHERE j2.department = j1.department
);

-- 15. Rank employees by their monthly income within each job role using DENSE_RANK() and filter for the top 3 earners per role.

SELECT emp_id, job_role, monthly_income, income_rank
FROM (
    SELECT 
        c.emp_id,
        j.job_role,
        c.monthly_income,
        DENSE_RANK() OVER (PARTITION BY j.job_role ORDER BY c.monthly_income DESC) AS income_rank
    FROM Compensation c
    JOIN Job_details j ON c.emp_id = j.emp_id
) ranked_employees
WHERE income_rank <= 3;

-- 16. Calculate the average distance from home for employees who left (attrition = 'Yes') versus those who stayed, grouped by department.

SELECT 
    j.department,
    e.attrition,
    ROUND(AVG(e.distance_from_home), 2) AS avg_distance_from_home,
    COUNT(e.emp_id) AS employee_count
FROM Employees e
JOIN Job_details j ON e.emp_id = j.emp_id
GROUP BY j.department, e.attrition
ORDER BY j.department, e.attrition;

-- 17. summary table combining headcount, average salary, average age, and average job satisfaction per department.

SELECT 
    j.department,
    COUNT(DISTINCT e.emp_id) AS total_headcount,
    ROUND(AVG(c.monthly_income), 2) AS avg_monthly_income,
    ROUND(AVG(e.age), 1) AS avg_age,
    ROUND(AVG(js.job_satisfaction), 2) AS avg_job_satisfaction,
    SUM(e.attrition_count) AS total_attrition
FROM Employees e
JOIN Compensation c ON e.emp_id = c.emp_id
JOIN Job_details j ON e.emp_id = j.emp_id
JOIN Job_Satisfaction js ON e.emp_id = js.emp_id
GROUP BY j.department
ORDER BY total_headcount DESC;
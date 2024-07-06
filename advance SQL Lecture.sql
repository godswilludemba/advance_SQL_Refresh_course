-- intermed
-- Joins

Select * 
FROM employee_demographics;

select *
from employee_salary;

Select * 
FROM employee_demographics
inner join employee_salary
	on employee_demographics.employee_id = employee_salary.employee_id
;

-- outer joins

-- left join
Select * 
FROM employee_demographics
left join employee_salary
	on employee_demographics.employee_id = employee_salary.employee_id
;

-- right join
Select * 
FROM employee_demographics
right join employee_salary
	on employee_demographics.employee_id  = employee_salary.employee_id
;

-- self join
Select * 
FROM employee_salary emp1
join employee_salary emp2
	on emp1.employee_id + 1 = emp2.employee_id
;

-- joining multiple table
Select * 
FROM employee_demographics as del
inner join employee_salary as sal
	on del.employee_id = sal.employee_id
		inner join parks_departments as pd
			on sal.dept_id = pd.department_id
;

select *
from parks_departments;

-- unions
-- it allows us to combine rows together where as join allows to combine column
-- this is an exaple of a bad data
select age, gender
from employee_demographics
union
select first_name, last_name
from employee_salary;

-- Distinct union
-- this seives the data using the uniqueness associated with the data eg in two tables it automatically drops any name appearing 
-- in both table using aonly one of the names EG

select first_name, last_name
from employee_demographics
union DISTINCT
select first_name, last_name
from employee_salary;

-- UNION ALL WILL OUTPUT ALL THE DATA WITH OUT REMOVING OR DROPING ANY OF THE DUPLICATES

SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary;

-- use case DROP OLD MAN AND HIGHLY PAID
SELECT first_name, last_name, 'Old Man' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid' AS Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name
;

-- string function

SELECT LENGTH('skyful');

SELECT first_name, LENGTH(first_name)
FROM employee_demographics
ORDER BY 2;

SELECT upper(
'SKY');

SELECT LOWER('FATHER');
SELECT UPPER('FATHER');


-- TRIM 
-- Trim will emove the white spaces at the left or right side of the data

SELECT TRIM('   YES  ');

-- TRIM USE CASE TO SELECT INITIALS OR BIRTH MONTH
SELECT first_name,
LEFT(first_name, 4),
RIGHT(first_name, 4),
SUBSTRING(first_name,3,3),
birth_date,
SUBSTRING(birth_date,6,2) AS birth_month
FROM employee_demographics;

-- replace
SELECT first_name, REPLACE(first_name, 'a', 'z')
FROM employee_demographics;

-- LOCATE
SELECT LOCATE('S', 'Godswill');

SELECT first_name, LOCATE('an',first_name)
FROM employee_demographics;

-- CONCATNATION
SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS FULL_NAME
FROM employee_demographics;

-- CASE STATEMENT
-- THis allowa you to put a logic in to your statement  

SELECT 
first_name,
last_name,
age,
CASE 
	WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN 'On Death Door'
END AS Age_Bracket
FROM employee_demographics;    

-- USE CASE
-- < 50000 = 5%
-- > 50000 = 7%
-- in finance dept = 10% bonus

SELECT 
first_name,
last_name,
salary,
CASE 
	WHEN salary <= 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS New_Salary,
CASE
	WHEN dept_id = 6 THEN salary * .10
END AS Bonus
FROM employee_salary;    

-- SUBQUERY
-- This is basially a query in another query

SELECT *
FROM employee_demographics
WHERE employee_id IN(
	SELECT employee_id
    FROM employee_salary
    WHERE dept_id =1
    );
    
-- window function
    -- this allows us to look at things in partition 
    -- first let us compare it with group by function
SELECT gender, avg(SALARY) AS AVG_Salary    
FROM employee_demographics AS Demo
Join employee_salary AS Sal
ON Demo.employee_id = Sal.employee_id
GROUP BY gender
;

-- window function proper
SELECT gender, avg(salary)  OVER(partition by gender) 
FROM employee_demographics AS Demo
Join employee_salary AS Sal
ON Demo.employee_id = Sal.employee_id
;

-- window function is great expecially for flexibility and when we want to add some things to the querry eg
SELECT Demo.first_name,Demo.last_name,gender, avg(salary) OVER(partition by gender) 
FROM employee_demographics  Demo
Join employee_salary Sal
ON Demo.employee_id = Sal.employee_id
;

-- with window function we can add or calculate a rolling total
SELECT Demo.first_name,Demo.last_name,gender, salary,
SUM(salary) OVER(partition by gender ORDER BY Demo.employee_id) AS Rolling_Total 
FROM employee_demographics  Demo
Join employee_salary Sal
ON Demo.employee_id = Sal.employee_id
;

-- we can perform Row_number, Rank and Dense Rank
SELECT Demo.employee_id, Demo.first_name,Demo.last_name,gender,salary,
ROW_NUMBER() OVER(partition by gender ORDER BY salary DESC) AS Row_Num,
RANK() OVER(partition by gender ORDER BY salary DESC) AS Rank_Num,
DENSE_RANK() OVER(partition by gender ORDER BY salary DESC) AS Dense_rank_num
FROM employee_demographics  Demo
Join employee_salary Sal
ON Demo.employee_id = Sal.employee_id
;
 
 -- advance
 -- CTE (Common Table Expression)
 -- this is a sort of expression that can be use imediatly after it has been created
 
 WITH CTE_EXAMPLE AS
 (
 SELECT gender, avg(salary) avg_sal, max(salary) max_sal,min(salary) min_sal,count(salary) count_sal
 FROM employee_demographics Demo
 JOIN employee_salary Sal
 ON Demo.employee_id =Sal.employee_id
 GROUP  BY gender
 )
 SELECT *
 FROM CTE_EXAMPLE
 ;
 
 
-- Temporary Table
-- this is used in storing intermediate result for temporary queries
-- NOT THAT TEMP_tables last as long you remain active on the work bench.
 
 select *
 FROM employee_salary;
 
 CREATE TEMPORARY TABLE salary_over_50k
 SELECT *
 FROM employee_salary
 WHERE salary >= 50000;
 
  SELECT *
 FROM salary_over_50k;
 
 -- STORED PROCEDURES
-- this a way to store your sql code for reusability

CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE SALARY >= 50000
;  
 -- Make a call
CALL large_salaries();  

CALL new_procedure();  

-- parametters
-- parameters are variabless that a passed as an input in to you stored procedure

DELIMITER $$
CREATE PROCEDURE large_salaries2(employee_id_params INT)
BEGIN
	SELECT salary
	FROM employee_salary
	WHERE employee_id = employee_id_params
;  
END $$
DELIMITER ;
 -- Make a call
CALL large_salaries2(1);  

-- triggers and events
-- a trigger is a block of code that kicks of when an event takes place on a specific table

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics(employee_id, first_name, last_name)
    VALUE(NEW.employee_id, NEW.first_name, New.last_name);
END $$
DELIMITER ;    

INSERT INTO employee_salary(employee_id, first_name, last_name,
 occupation, salary, dept_id)
VALUE(13, 'test-anchor', 'akpan','cleanner', 209000, null); 

-- event
 
-- 2 задача на CASE
Select 
    count(job_id),
    CASE
        WHEN salary_year_avg BETWEEN 0 and 85000 THEN 'LOW SALARY'
        WHEN salary_year_avg BETWEEN 85001 and 120000 THEN 'MEDIUM SALARY'
        ELSE 'HIGH SALARY'
    END AS categories_of_salary
from 
    job_postings_fact
Where 
    salary_year_avg IS NOT NULL
    and 
    job_title_short = 'Data Analyst'
GROUP BY
categories_of_salary    
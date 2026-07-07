-- 2 задача на EXTRACT
Select
    avg(salary_year_avg),
    EXTRACT(quarter from job_posted_date) as quarter_date
from 
    job_postings_fact
WHERE
    EXTRACT(YEAR from job_posted_date) = '2023'
and
    job_work_from_home = 'true'
group BY
    quarter_date
ORDER BY
    quarter_date ASC
-- 3 задача на EXTRACT
SELECT
    count(job_title_short) as job_count,
    EXTRACT(ISODOW from job_posted_date) as day_of_week
from 
    job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
and 
    salary_year_avg >= 100000
GROUP BY
    day_of_week
ORDER BY
    job_count desc
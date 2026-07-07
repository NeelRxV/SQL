-- 1 задача на CASE
SELECT
count(job_id),
    CASE
        WHEN job_work_from_home = true THEN 'REMOTE'
        ELSE 'NOT REMOTE'
    END AS remote_vacancies
from job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    remote_vacancies
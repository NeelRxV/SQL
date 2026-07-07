-- 1 задача на EXTRACT
Select 
    job_title_short,
    count(job_title_short) as count_of_jobs,
    EXTRACT(MONTH from job_posted_date) as month
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR from job_posted_date) = 2023
    and
        (job_title_short = 'Data Analyst'
        or
        job_title_short = 'Data Scientist')
group BY
MONTH,
job_title_short
order BY
month asc
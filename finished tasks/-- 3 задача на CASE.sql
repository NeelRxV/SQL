-- 3 задача на CASE
SELECT
    c.name,
    COUNT(j.company_id) as numbers_of_vacancies,
    CASE
        WHEN COUNT(j.company_id) <= 2 THEN 'SMALL COMPANY'
        WHEN COUNT(j.company_id) BETWEEN 3 AND 9 THEN 'MEDIUM COMPANY'
        WHEN COUNT(j.company_id) >= 10 THEN 'BIG COMPANY'
    END AS scale_companies
FROM job_postings_fact j
LEFT JOIN company_dim c
ON j.company_id = c.company_id
WHERE
    j.job_title_short = 'Data Analyst'
GROUP BY
    j.company_id,
    c.name
ORDER BY
numbers_of_vacancies DESC

With skills_demand as(
    SELECT
        skills_dim.skills,
        skills_dim.skill_id,
        count(skills_job_dim.job_id) as demand_count
    from job_postings_fact
    INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim on skills_dim.skill_id = skills_job_dim.skill_id
    WHERE
    job_title_short = 'Data Analyst'
    and job_work_from_home = TRUE
    and salary_year_avg IS NOT NULL
    group BY
        skills_dim.skill_id
),  avg_salary as(
        SELECT
        skills_dim.skill_id,
        round(avg(salary_year_avg),0) as average_salary
    from job_postings_fact
    INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim on skills_dim.skill_id = skills_job_dim.skill_id
    WHERE
    job_title_short = 'Data Analyst'
    and salary_year_avg IS NOT NULL
    and job_work_from_home = TRUE
    group BY
        skills_dim.skill_id
)

Select 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary.average_salary
from 
    skills_demand
inner join avg_salary on skills_demand.skill_id = avg_salary.skill_id
WHERE
    demand_count > 10
ORDER BY
    average_salary desc,
    demand_count desc
limit 25
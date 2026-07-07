# Introduction
Explore the data analytics job market through real-world SQL queries. This project highlights 💰 high-paying data analyst positions, 🚀 the most valuable skills, and 📊 how demand aligns with salary.

SQL Queries? Check them out in: [project_sql folder](/project_sql/)
# Background
Breaking into data analytics can be challenging without understanding what employers actually value. This project analyzes job market data to uncover high-paying opportunities, the most requested skills, and trends that can help guide career decisions.

### Main questions addressed in this analysis:
1. Which data analyst jobs offer the highest salaries?
2. What skills are needed to qualify for these roles?
3. Which skills are most requested by employers?
4. Which skills are associated with higher pay?
5. Which skills are worth learning to maximize career opportunities?
# Tools I Used
The following tools were used throughout this project:

- **SQL** – Used to query, filter, and analyze the dataset.
- **PostgreSQL** – Database system used to store and manage the job posting data.
- **Visual Studio Code** – Development environment for writing and testing SQL queries.
- **Git & GitHub** – Used for version control, project organization, and sharing the completed analysis.
# The Analysis
Each query for the project was aimed to investigate specific aspects of the data analyst job market
Here's how i did this:
### 1.Top paying Data Analyst Jobs
To identify the highest-paying opportunities in the field, I filtered Data Analyst postings by average yearly salary, focusing specifically on remote roles. This query surfaces the top 10 best-paying remote positions, giving a quick view into where the market pays the most for this role.
```sql
Select
    job_id,
    job_title,
    company_dim.name as company_name,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
from job_postings_fact
left JOIN company_dim on job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
ORDER BY
salary_year_avg DESC
limit 10
```
**Insights:**
- Top 10 results skew senior - Director, Principal, Associate Director - because pay scales with scope of responsibility, not the literal "Data Analyst" label.
- Mantys ($650k) sits almost double the next entry (Meta, $336.5k), likely due to bonuses or equity folded into the yearly average rather than base pay alone.
- Every listing is remote and full-time, showing that top pay and location flexibility aren't a trade-off here - companies compete for scarce talent wherever it sits.
### 2. Skills Required for Top Paying Data Analyst Jobs
Building on the top 10 highest-paying remote roles, this query joins in the required skills for each posting. The goal is to see what skill combinations these top-paying employers actually demand, rather than just what they pay.

```sql
With top_paying_jobs AS(
    Select
        job_id,
        job_title,
        company_dim.name as company_name,
        salary_year_avg
    from job_postings_fact
    left JOIN company_dim on job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY
    salary_year_avg DESC
    limit 10
)
Select 
    top_paying_jobs.*,
    skills
from top_paying_jobs
INNER JOIN skills_job_dim on top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_dim.skill_id = skills_job_dim.skill_id
ORDER BY
    salary_year_avg DESC
```
### 3. Top demanded skills for Data Analyst
This query shifts focus from top-paying jobs specifically to the broader Data Analyst market as a whole. By counting how often each skill appears across all postings, it surfaces what employers ask for most often - a proxy for baseline market demand rather than premium pay.

```sql
SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5
```
### 4. Top paying skills for Data Analyst
This query explores which skills are associated with higher salaries in Data Analyst roles. By calculating the average salary for each skill across job postings, it identifies the technologies and competencies that appear most valuable from a compensation perspective.
```sql
SELECT
    skills,
    round(avg(salary_year_avg),0) as average_salary
from job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_dim.skill_id = skills_job_dim.skill_id
WHERE
job_title_short = 'Data Analyst'
and salary_year_avg IS NOT NULL
group BY
    skills
ORDER BY
average_salary desc
limit 25
```
Core insights:
1) high pay here doesn't come from "analysis skill" - it comes from scope creep. Most of these tools (Terraform, Ansible, Kafka, GitLab, VMware) are DevOps/data-engineering tools, not analyst tools. Employers labeling these roles "Data Analyst" are really hiring one person to do analyst + engineer work - pay reflects that combined scope, not the tools themselves.
2) Secondary driver - ML/AI blur: PyTorch, TensorFlow, Keras, Hugging Face (~120-155k) show analysts increasingly expected to build models, not just report on data - driven by AI adoption pressure outpacing separate ML hiring.
3) Outliers = scarcity, not value: SVN (400k) and Solidity (179k) are niche/legacy skills with few practitioners - small sample sizes and scarcity premium, not causal value from the skill itself. Same logic likely applies to dplyr (R persists in pharma/biostat niches with high switching costs).
4) Notable absence: SQL, Excel, Tableau - the actual core analyst skills - don't appear. They're table stakes, not differentiators, so they don't show up as "top paying."
### Optimal skills for Data Analysts
This query focuses on finding the most valuable skills by analyzing both demand and salary levels. By filtering for remote Data Analyst roles and comparing skill frequency with average salary, it identifies skills that are not only widely requested but also associated with higher compensation.
```sql

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
```
# What I Learned

# Conclusions
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
**Insights**:

1) high pay here doesn't come from "analysis skill" - it comes from scope creep. Most of these tools (Terraform, Ansible, Kafka, GitLab, VMware) are DevOps/data-engineering tools, not analyst tools. Employers labeling these roles "Data Analyst" are really hiring one person to do analyst + engineer work - pay reflects that combined scope, not the tools themselves.
2) Secondary driver - ML/AI blur: PyTorch, TensorFlow, Keras, Hugging Face (~120-155k) show analysts increasingly expected to build models, not just report on data - driven by AI adoption pressure outpacing separate ML hiring.
3) Outliers = scarcity, not value: SVN (400k) and Solidity (179k) are niche/legacy skills with few practitioners - small sample sizes and scarcity premium, not causal value from the skill itself. Same logic likely applies to dplyr (R persists in pharma/biostat niches with high switching costs).
4) Notable absence: SQL, Excel, Tableau - the actual core analyst skills - don't appear. They're table stakes, not differentiators, so they don't show up as "top paying."
### 5. Optimal Skills for Data Analysts
This query merges demand and pay into a single view by joining a `skills_demand` CTE (count of remote postings requiring each skill) with an `avg_salary` CTE (average salary tied to each skill), filtered to skills appearing in more than 10 postings. The intent is to find skills that are simultaneously well-paid and reasonably in-demand, rather than optimizing for either metric alone.

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

**Insights:**
- Pay and demand move in opposite directions at the extremes. The highest-paid skills - Go ($115k), Confluence ($114k), Hadoop ($113k), Snowflake ($113k) - all sit at low demand counts (11–37), while the most in-demand skills — Python (236 postings), Tableau (230), R (148) - average only ~$99–101k. This is a scarcity effect: fewer analysts hold niche/infrastructure skills, so employers pay a premium to secure them; ubiquitous skills are commoditized precisely because most analysts already have them, which caps their marginal value.
- Cloud and big-data skills (Snowflake, Azure, BigQuery, AWS) cluster at the top of the pay range together, which points to a causal driver behind the scarcity premium: these tools require infrastructure-level knowledge beyond core analytics, so they signal a broader technical skillset employers can't easily source from a pure "Data Analyst" candidate pool.
- Python and R, despite topping demand, land in the lower half of this list. This suggests they function as baseline/gatekeeping skills rather than differentiators - necessary to qualify for a role, but not sufficient to command top pay on their own.
# What I Learned

This project was my first real test of turning raw SQL knowledge into an actual analytical workflow, and it pushed me to move well beyond simple SELECT statements:

- **Joins (LEFT JOIN, INNER JOIN):** Learned to combine `job_postings_fact` with dimension tables (`company_dim`, `skills_dim`, `skills_job_dim`) to attach readable context (company names, skill names) to raw fact-table IDs.
- **CTEs (WITH):** Used common table expressions to break complex logic into readable steps, first isolating top paying jobs, then joining skills onto them, and later building two separate CTEs (demand and average salary) to merge into one final view.
- **Aggregate functions (COUNT, AVG, ROUND):** Applied these to turn row-level job postings into market-level metrics, counting how often a skill appears and calculating its average associated salary.
- **GROUP BY logic:** Understood that aggregation only makes sense once data is grouped by the right entity, in this case by skill, not by job posting.
- **Filtering (WHERE, IS NOT NULL, multiple AND conditions):** Learned to filter out incomplete data (missing salaries) before aggregating, since including NULLs would silently skew averages.
- **Sorting and limiting (ORDER BY, LIMIT):** Used these to surface only the most relevant rows (top 10, top 25) instead of dumping the entire result set.
- **Combining CTEs via INNER JOIN:** The final query in this project required joining two independently built CTEs on a shared key, which was the most demanding step conceptually, since it required thinking about the data in two separate aggregated shapes before merging them.

Beyond syntax, the biggest shift was learning to read query results causally rather than just descriptively, asking not just "what does this number say" but "why would the market produce this pattern."

# Conclusions

This analysis suggests that pay in the Data Analyst market is not driven by the "Data Analyst" title itself, but by scope and scarcity layered on top of it. The highest paying postings are, in practice, senior or hybrid engineering roles wearing an analyst label, which explains why DevOps and ML tools outearn traditional analyst tools. Core skills like SQL, Excel, and Tableau remain the most in demand because they are the baseline requirement to even qualify for a role, not because they command a premium, since nearly every analyst already has them. The scarcer, more infrastructure heavy skills (Snowflake, Azure, BigQuery, Go) pay more precisely because fewer analysts hold them, making them a differentiator rather than a gatekeeping requirement.

The practical takeaway is that maximizing career value as a Data Analyst means treating core tools as a mandatory foundation, then deliberately layering in one or two scarce, higher scope skills (cloud platforms, or lightweight ML exposure) to move from being interchangeable to being the person a company specifically pays more to keep.
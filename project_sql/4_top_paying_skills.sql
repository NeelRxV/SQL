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
/*
Core insight: high pay here doesn't come from "analysis skill" — it comes from scope creep. Most of these tools (Terraform, Ansible, Kafka, GitLab, VMware) are DevOps/data-engineering tools, not analyst tools. Employers labeling these roles "Data Analyst" are really hiring one person to do analyst + engineer work — pay reflects that combined scope, not the tools themselves.
Secondary driver — ML/AI blur: PyTorch, TensorFlow, Keras, Hugging Face (~120-155k) show analysts increasingly expected to build models, not just report on data — driven by AI adoption pressure outpacing separate ML hiring.
Outliers = scarcity, not value: SVN (400k) and Solidity (179k) are niche/legacy skills with few practitioners — small sample sizes and scarcity premium, not causal value from the skill itself. Same logic likely applies to dplyr (R persists in pharma/biostat niches with high switching costs).
Notable absence: SQL, Excel, Tableau — the actual core analyst skills — don't appear. They're table stakes, not differentiators, so they don't show up as "top paying."
*/
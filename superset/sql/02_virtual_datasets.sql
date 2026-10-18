-- Superset virtual datasets (SQL Lab > Save as dataset). RLS clauses are added to the dataset,
-- so each dataset must expose domain_code. Assumes fact tables loaded from the project's CSVs
-- with snake_case names; adjust to your schema.

-- Alarms
SELECT a.*, c.domain_code
FROM fact_alarm a
JOIN dim_category c ON c.category_key = a.category_key;

-- Incidents
SELECT i.*, c.domain_code
FROM fact_incident i
JOIN dim_category c ON c.category_key = i.category_key;

-- Example domain fact (repeat the pattern for each fact table)
SELECT f.*, c.domain_code
FROM fact_irrigation f
JOIN dim_category c ON c.category_key = f.category_key;

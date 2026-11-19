-- Read-only daily incident counts grouped by category.
WITH category_daily AS (
  SELECT
    category_id,
    date_trunc('day', created_at)::date AS report_date,
    COUNT(*)::BIGINT AS incident_count
  FROM public.incidents
  GROUP BY category_id, date_trunc('day', created_at)::date
)
SELECT
  department.department_name,
  category.category_name,
  category_daily.report_date,
  category_daily.incident_count
FROM category_daily
JOIN public.categories category USING (category_id)
JOIN public.departments department USING (department_id)
ORDER BY category_daily.report_date DESC, department.department_name, category.category_name;

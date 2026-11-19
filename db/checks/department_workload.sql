-- Read-only analytics including departments with zero incidents.
WITH workload AS (
  SELECT department_id, department_name, total_incidents, open_incidents, resolved_incidents
  FROM public.department_incident_summary
)
SELECT *, round(100.0 * resolved_incidents / NULLIF(total_incidents, 0), 2) AS resolution_percent
FROM workload
ORDER BY open_incidents DESC, department_name;

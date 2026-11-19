-- Read-only workload report. Officers with no open assignments remain visible.
SELECT
  officer.user_id AS officer_id,
  officer.full_name,
  department.department_name,
  COUNT(incident.incident_id) FILTER (
    WHERE incident.status IN ('pending', 'assigned', 'in_progress')
  )::BIGINT AS open_assignments,
  COUNT(incident.incident_id)::BIGINT AS total_assignments
FROM public.users officer
LEFT JOIN public.departments department
  ON department.department_id = officer.department_id
LEFT JOIN public.assignments assignment
  ON assignment.officer_id = officer.user_id
LEFT JOIN public.incidents incident
  ON incident.incident_id = assignment.incident_id
WHERE officer.role = 'officer'
GROUP BY officer.user_id, officer.full_name, department.department_name
ORDER BY open_assignments DESC, officer.full_name;

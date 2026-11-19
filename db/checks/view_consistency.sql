-- Report any discrepancies between the summary view and correlated counts.
SELECT s.department_id, s.department_name
FROM public.department_incident_summary s
WHERE s.total_incidents <> (
  SELECT count(*) FROM public.incidents i JOIN public.categories c USING(category_id)
  WHERE c.department_id=s.department_id
) OR s.open_incidents <> (
  SELECT count(*) FROM public.incidents i JOIN public.categories c USING(category_id)
  WHERE c.department_id=s.department_id AND i.status NOT IN ('resolved','rejected')
) OR s.resolved_incidents <> (
  SELECT count(*) FROM public.incidents i JOIN public.categories c USING(category_id)
  WHERE c.department_id=s.department_id AND i.status='resolved'
);
-- An empty result means the view agrees with the independent counts.

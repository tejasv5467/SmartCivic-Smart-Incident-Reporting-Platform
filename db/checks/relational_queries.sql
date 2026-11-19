-- Join incidents to their classification and department.
SELECT i.incident_id, i.title, c.category_name, d.department_name
FROM public.incidents i JOIN public.categories c USING (category_id)
JOIN public.departments d USING (department_id);
-- Correlated subquery: departments with at least one incident.
SELECT d.department_name FROM public.departments d
WHERE EXISTS (SELECT 1 FROM public.categories c JOIN public.incidents i USING (category_id)
WHERE c.department_id = d.department_id);
-- Uncorrelated subquery: incidents belonging to Public Works.
SELECT incident_id, title FROM public.incidents
WHERE category_id IN (SELECT c.category_id FROM public.categories c
JOIN public.departments d USING (department_id) WHERE d.department_name = 'Public Works');

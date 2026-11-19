-- Detect assignments inconsistent with application officer/department rules.
SELECT a.assignment_id,a.incident_id,a.officer_id,u.role,u.is_active,
       u.department_id AS officer_department,c.department_id AS incident_department
FROM public.assignments a JOIN public.users u ON u.user_id=a.officer_id
JOIN public.incidents i ON i.incident_id=a.incident_id
JOIN public.categories c ON c.category_id=i.category_id
WHERE u.role <> 'officer' OR u.department_id IS DISTINCT FROM c.department_id
ORDER BY a.assignment_id;

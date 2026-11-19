-- Avoid selecting authentication credentials in audit reports.
SELECT i.incident_id, i.title, h.old_status, h.new_status,
       u.full_name AS changed_by, h.remarks, h.changed_at
FROM public.status_history h
JOIN public.incidents i ON i.incident_id = h.incident_id
LEFT JOIN public.users u ON u.user_id = h.changed_by
ORDER BY h.changed_at DESC, h.history_id DESC;

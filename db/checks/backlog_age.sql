-- Read-only open incident backlog age report.
SELECT
  incident_id,
  title,
  status,
  priority,
  created_at,
  CURRENT_TIMESTAMP - created_at AS age,
  GREATEST(
    FLOOR(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at)) / 86400),
    0
  )::BIGINT AS age_days
FROM public.incidents
WHERE status IN ('pending', 'assigned', 'in_progress')
ORDER BY created_at ASC, incident_id;

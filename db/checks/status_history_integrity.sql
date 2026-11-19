-- Compare latest recorded status with current state.
SELECT i.incident_id,i.status,h.new_status AS latest_history_status
FROM public.incidents i
LEFT JOIN LATERAL (
  SELECT new_status FROM public.status_history
  WHERE incident_id=i.incident_id ORDER BY changed_at DESC,history_id DESC LIMIT 1
) h ON true
WHERE i.status IS DISTINCT FROM h.new_status;

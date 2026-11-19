-- EXPLAIN only: no data modification and no execution of the SELECT.
EXPLAIN SELECT incident_id,title FROM public.incidents WHERE status='pending' ORDER BY created_at DESC;
EXPLAIN SELECT incident_id,title FROM public.incidents WHERE search_vector @@ plainto_tsquery('english','pothole');
EXPLAIN SELECT incident_id FROM public.assignments WHERE officer_id=1;
-- Small tables may favor sequential scans; that is not an index failure.

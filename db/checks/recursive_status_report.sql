-- Recursive CTE exercise: enumerate the ordered history for every incident.
WITH RECURSIVE ordered AS (
  SELECT incident_id, history_id, old_status, new_status, changed_at,
         row_number() OVER (PARTITION BY incident_id ORDER BY changed_at,history_id) AS seq
  FROM public.status_history
), timeline AS (
  SELECT incident_id,history_id,new_status,seq,ARRAY[new_status::text] AS path
  FROM ordered WHERE seq=1
  UNION ALL
  SELECT o.incident_id,o.history_id,o.new_status,o.seq,t.path || o.new_status::text
  FROM timeline t JOIN ordered o ON o.incident_id=t.incident_id AND o.seq=t.seq+1
)
SELECT DISTINCT ON (incident_id) incident_id,path FROM timeline ORDER BY incident_id,seq DESC;

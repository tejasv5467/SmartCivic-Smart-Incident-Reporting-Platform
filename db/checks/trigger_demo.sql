-- Run through psql against a development database with at least one incident.
-- PostgreSQL rolls back the demonstration change; Qdrant is not modified.
BEGIN;
SELECT incident_id, title, search_vector, updated_at
FROM public.incidents WHERE incident_id = (SELECT min(incident_id) FROM public.incidents);
UPDATE public.incidents SET title = 'Temporary database trigger demonstration'
WHERE incident_id = (SELECT min(incident_id) FROM public.incidents)
RETURNING incident_id, title, search_vector, updated_at;
ROLLBACK;

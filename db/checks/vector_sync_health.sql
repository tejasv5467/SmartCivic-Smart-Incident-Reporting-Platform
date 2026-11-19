-- SQL synchronization state, not proof that points currently exist in Qdrant.
SELECT i.incident_id, i.title, s.indexed_at, s.updated_at, s.last_error
FROM public.incidents i
LEFT JOIN public.incident_vector_sync s ON s.incident_id = i.incident_id
WHERE s.indexed_at IS NULL OR s.last_error IS NOT NULL
ORDER BY i.incident_id;

-- Show the lexical search path independently of Qdrant similarity search.
SELECT incident_id, title, status,
       ts_rank(search_vector, plainto_tsquery('english', 'pothole')) AS rank
FROM public.incidents
WHERE search_vector @@ plainto_tsquery('english', 'pothole')
ORDER BY rank DESC, incident_id;

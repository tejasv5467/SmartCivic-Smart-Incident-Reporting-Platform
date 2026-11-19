-- Read-only per-incident feedback statistics; average stays NULL with no ratings.
SELECT
  incident.incident_id,
  incident.title,
  COUNT(feedback.feedback_id)::BIGINT AS feedback_count,
  CASE
    WHEN COUNT(feedback.feedback_id) = 0 THEN NULL
    ELSE ROUND(AVG(feedback.rating)::NUMERIC, 2)
  END AS average_rating
FROM public.incidents incident
LEFT JOIN public.feedback feedback
  ON feedback.incident_id = incident.incident_id
GROUP BY incident.incident_id, incident.title
ORDER BY incident.incident_id;

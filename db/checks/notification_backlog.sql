-- Read-only summary without displaying private complaint text.
SELECT recipient_id, type, count(*) AS total,
       count(*) FILTER (WHERE read_at IS NULL) AS unread,
       min(created_at) FILTER (WHERE read_at IS NULL) AS oldest_unread
FROM public.notifications
GROUP BY recipient_id,type ORDER BY unread DESC,recipient_id;

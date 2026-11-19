BEGIN;

CREATE OR REPLACE PROCEDURE public.set_incident_priority(
  p_incident_id BIGINT,
  p_priority TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_incident_id IS NULL OR p_incident_id < 1 THEN
    RAISE EXCEPTION 'Incident ID must be a positive integer.'
      USING ERRCODE = '22023';
  END IF;

  IF p_priority IS NULL OR p_priority NOT IN ('low', 'medium', 'high', 'critical') THEN
    RAISE EXCEPTION 'Priority must be low, medium, high, or critical.'
      USING ERRCODE = '22023';
  END IF;

  UPDATE public.incidents
  SET priority = p_priority,
      updated_at = CURRENT_TIMESTAMP
  WHERE incident_id = p_incident_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Incident % was not found.', p_incident_id
      USING ERRCODE = 'P0002';
  END IF;
END;
$$;

COMMIT;

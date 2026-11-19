-- Run only on a disposable development database with migration 010 applied.
-- The test changes an existing incident inside a transaction and rolls back.
BEGIN;

DO $$
DECLARE
  target_id BIGINT;
  expected_priority TEXT;
  actual_priority TEXT;
BEGIN
  SELECT incident_id INTO target_id
  FROM public.incidents
  ORDER BY incident_id
  LIMIT 1;

  IF target_id IS NULL THEN
    RAISE EXCEPTION 'Create a disposable incident before running this check.';
  END IF;

  expected_priority := 'high';
  CALL public.set_incident_priority(target_id, expected_priority);
  SELECT priority INTO actual_priority
  FROM public.incidents
  WHERE incident_id = target_id;
  IF actual_priority IS DISTINCT FROM expected_priority THEN
    RAISE EXCEPTION 'Valid priority update was not applied.';
  END IF;

  BEGIN
    CALL public.set_incident_priority(target_id, 'urgent');
    RAISE EXCEPTION 'Invalid priority unexpectedly succeeded.' USING ERRCODE = 'P0001';
  EXCEPTION
    WHEN invalid_parameter_value THEN NULL;
  END;

  BEGIN
    CALL public.set_incident_priority(0, 'low');
    RAISE EXCEPTION 'Invalid incident ID unexpectedly succeeded.' USING ERRCODE = 'P0001';
  EXCEPTION
    WHEN invalid_parameter_value THEN NULL;
  END;

  BEGIN
    CALL public.set_incident_priority(9223372036854775807, 'low');
    RAISE EXCEPTION 'Missing incident unexpectedly succeeded.' USING ERRCODE = 'P0001';
  EXCEPTION
    WHEN no_data_found THEN NULL;
  END;
END;
$$;

ROLLBACK;

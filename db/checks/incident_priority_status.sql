BEGIN;
DO $$
DECLARE dep bigint; cat bigint; resident bigint; inc bigint;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('Status test ' || txid_current()) RETURNING department_id INTO dep;
  INSERT INTO public.categories(category_name,department_id) VALUES ('Status category ' || txid_current(),dep) RETURNING category_id INTO cat;
  INSERT INTO public.users(full_name) VALUES ('Test resident') RETURNING user_id INTO resident;
  INSERT INTO public.incidents(title,description,location,category_id,reported_by) VALUES ('Status test','Temporary','Test',cat,resident) RETURNING incident_id INTO inc;
  BEGIN
    UPDATE public.incidents SET priority='invalid' WHERE incident_id=inc;
    RAISE EXCEPTION 'Expected invalid priority rejection';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'PASS: priority domain'; END;
  BEGIN
    UPDATE public.incidents SET status='invalid' WHERE incident_id=inc;
    RAISE EXCEPTION 'Expected invalid status rejection';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'PASS: status domain'; END;
END $$;
ROLLBACK;

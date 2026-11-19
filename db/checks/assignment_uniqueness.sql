BEGIN;
DO $$
DECLARE dep bigint; cat bigint; officer bigint; admin bigint; inc bigint;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('Assignment test ' || txid_current()) RETURNING department_id INTO dep;
  INSERT INTO public.categories(category_name,department_id) VALUES ('Assignment category ' || txid_current(),dep) RETURNING category_id INTO cat;
  INSERT INTO public.users(full_name,role,department_id) VALUES ('Test officer','officer',dep) RETURNING user_id INTO officer;
  INSERT INTO public.users(full_name,role) VALUES ('Test administrator','admin') RETURNING user_id INTO admin;
  INSERT INTO public.incidents(title,description,location,category_id,reported_by) VALUES ('Assignment test','Temporary','Test',cat,admin) RETURNING incident_id INTO inc;
  INSERT INTO public.assignments(incident_id,officer_id,assigned_by) VALUES (inc,officer,admin);
  BEGIN
    INSERT INTO public.assignments(incident_id,officer_id,assigned_by) VALUES (inc,officer,admin);
    RAISE EXCEPTION 'Expected duplicate assignment rejection';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'PASS: duplicate assignment rejected';
  END;
END $$;
ROLLBACK;

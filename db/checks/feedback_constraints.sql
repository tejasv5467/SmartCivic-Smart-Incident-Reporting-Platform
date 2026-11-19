BEGIN;
DO $$
DECLARE dep bigint; cat bigint; resident bigint; inc bigint;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('Feedback test ' || txid_current()) RETURNING department_id INTO dep;
  INSERT INTO public.categories(category_name,department_id) VALUES ('Feedback category ' || txid_current(),dep) RETURNING category_id INTO cat;
  INSERT INTO public.users(full_name) VALUES ('Demo reviewer') RETURNING user_id INTO resident;
  INSERT INTO public.incidents(title,description,location,category_id,reported_by,status) VALUES ('Feedback test','Temporary','Test',cat,resident,'resolved') RETURNING incident_id INTO inc;
  BEGIN
    INSERT INTO public.feedback(incident_id,submitted_by,rating) VALUES (inc,resident,6);
    RAISE EXCEPTION 'Expected invalid rating rejection';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'PASS: rating range';
  END;
  INSERT INTO public.feedback(incident_id,submitted_by,rating) VALUES (inc,resident,5);
  BEGIN
    INSERT INTO public.feedback(incident_id,submitted_by,rating) VALUES (inc,resident,4);
    RAISE EXCEPTION 'Expected duplicate feedback rejection';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'PASS: one feedback per incident and user';
  END;
END $$;
ROLLBACK;

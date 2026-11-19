BEGIN;
DO $$
DECLARE dep bigint; cat bigint; resident bigint; row_data public.incidents%ROWTYPE;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('Defaults test ' || txid_current()) RETURNING department_id INTO dep;
  INSERT INTO public.categories(category_name,department_id) VALUES ('Defaults category ' || txid_current(),dep) RETURNING category_id INTO cat;
  INSERT INTO public.users(full_name) VALUES ('Demo resident') RETURNING user_id INTO resident;
  INSERT INTO public.incidents(title,description,location,category_id,reported_by) VALUES ('Pothole test','Temporary','Test',cat,resident) RETURNING * INTO row_data;
  IF row_data.priority IS DISTINCT FROM 'medium' OR row_data.status IS DISTINCT FROM 'pending' OR row_data.created_at IS NULL THEN
    RAISE EXCEPTION 'Incident defaults incorrect';
  END IF;
  IF row_data.search_vector IS NULL OR NOT (row_data.search_vector @@ plainto_tsquery('english','pothole')) THEN
    RAISE EXCEPTION 'Insert trigger did not populate search vector';
  END IF;
  RAISE NOTICE 'PASS: incident defaults and INSERT trigger';
END $$;
ROLLBACK;

-- Development only. Assert referential integrity and roll back.
BEGIN;
DO $$
DECLARE dep_id bigint; cat_id bigint; resident_id bigint; inc_id bigint;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('FK test ' || txid_current()) RETURNING department_id INTO dep_id;
  INSERT INTO public.categories(category_name,department_id) VALUES ('FK category ' || txid_current(),dep_id) RETURNING category_id INTO cat_id;
  INSERT INTO public.users(full_name) VALUES ('FK resident') RETURNING user_id INTO resident_id;
  INSERT INTO public.incidents(title,description,category_id,reported_by,location)
  VALUES ('FK test','Temporary',cat_id,resident_id,'Test location') RETURNING incident_id INTO inc_id;
  BEGIN
    DELETE FROM public.categories WHERE category_id=cat_id;
    RAISE EXCEPTION 'Expected restrict violation';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: referenced category protected';
  END;
  INSERT INTO public.incident_vector_sync(incident_id) VALUES (inc_id) ON CONFLICT DO NOTHING;
  DELETE FROM public.incidents WHERE incident_id=inc_id;
  IF EXISTS (SELECT 1 FROM public.incident_vector_sync WHERE incident_id=inc_id) THEN
    RAISE EXCEPTION 'Expected vector sync cascade';
  END IF;
  RAISE NOTICE 'PASS: vector synchronization row cascades';
END $$;
ROLLBACK;

BEGIN;
DO $$
DECLARE dep bigint;
BEGIN
  INSERT INTO public.departments(department_name) VALUES ('Manager test ' || txid_current()) RETURNING department_id INTO dep;
  INSERT INTO public.users(full_name,department_id,role,is_manager) VALUES ('First manager',dep,'officer',true);
  INSERT INTO public.users(full_name,department_id,role,is_manager) VALUES ('Ordinary officer',dep,'officer',false);
  BEGIN
    INSERT INTO public.users(full_name,department_id,role,is_manager) VALUES ('Second manager',dep,'officer',true);
    RAISE EXCEPTION 'Expected manager uniqueness violation';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'PASS: one officer manager per department';
  END;
END $$;
ROLLBACK;

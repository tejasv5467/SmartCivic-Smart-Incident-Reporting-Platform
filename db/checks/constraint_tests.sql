-- Run on a development database. Expected failures are caught and asserted.
BEGIN;
DO $$
DECLARE demo_name text := 'Constraint demo ' || txid_current();
BEGIN
  INSERT INTO public.departments (department_name) VALUES (demo_name);
  BEGIN
    INSERT INTO public.departments (department_name) VALUES (demo_name);
    RAISE EXCEPTION 'Expected unique violation';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: department name uniqueness';
  END;
  BEGIN
    INSERT INTO public.users (full_name, role) VALUES ('Demo user', 'invalid');
    RAISE EXCEPTION 'Expected check violation';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: role check';
  END;
  BEGIN
    INSERT INTO public.departments (department_name) VALUES (NULL);
    RAISE EXCEPTION 'Expected not-null violation';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'PASS: mandatory department name';
  END;
END;
$$;
ROLLBACK;

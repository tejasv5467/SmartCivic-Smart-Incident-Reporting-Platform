-- Development only: use placeholder hashes, never real credentials.
BEGIN;
DO $$
DECLARE acct bigint; local_email text := 'dbtest-' || txid_current() || '@example.invalid';
BEGIN
  INSERT INTO public.auth_accounts(full_name,email,password_hash) VALUES ('Demo account',local_email,'test-only') RETURNING account_id INTO acct;
  BEGIN
    INSERT INTO public.auth_accounts(full_name,email,password_hash) VALUES ('Duplicate',local_email,'test-only');
    RAISE EXCEPTION 'Expected duplicate email rejection';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'PASS: email uniqueness'; END;
  INSERT INTO public.users(full_name,auth_account_id) VALUES ('Demo profile',acct);
  BEGIN
    INSERT INTO public.users(full_name,auth_account_id) VALUES ('Duplicate profile',acct);
    RAISE EXCEPTION 'Expected duplicate profile rejection';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'PASS: one profile per account'; END;
  DELETE FROM public.auth_accounts WHERE account_id=acct;
  IF EXISTS (SELECT 1 FROM public.users WHERE auth_account_id=acct) THEN
    RAISE EXCEPTION 'Expected account reference to be cleared';
  END IF;
  RAISE NOTICE 'PASS: account removal clears profile reference';
END $$;
ROLLBACK;

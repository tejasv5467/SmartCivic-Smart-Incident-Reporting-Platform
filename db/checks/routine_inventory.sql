SELECT p.proname, CASE p.prokind WHEN 'p' THEN 'procedure' ELSE 'function' END AS kind, pg_get_function_identity_arguments(p.oid) AS arguments
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prokind IN ('p','f')
ORDER BY kind, p.proname;
SELECT event_object_table, trigger_name, action_timing, event_manipulation, action_statement
FROM information_schema.triggers WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name, event_manipulation;

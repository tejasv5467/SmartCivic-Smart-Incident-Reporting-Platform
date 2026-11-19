-- Report application roles separately from PostgreSQL roles and grants.
SELECT role, count(*) AS users, count(*) FILTER (WHERE is_active) AS active_users
FROM public.users GROUP BY role ORDER BY role;
SELECT rolname, rolsuper, rolcanlogin FROM pg_roles ORDER BY rolname;
SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants
WHERE table_schema = 'public' ORDER BY grantee, table_name, privilege_type;

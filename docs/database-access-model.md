# Authorization boundaries

SmartCivic stores application role values (resident, officer, admin) in PostgreSQL and uses signed sessions and server-side checks to authorize requests. A CHECK constraint on the role column is not equivalent to PostgreSQL GRANT or row-level security.

Inspect the actual PostgreSQL role and grants using db/checks/roles.sql. Do not claim database-level RBAC or RLS without verifying the deployment. The application connection role and migration owner should be considered separately; a least-privilege deployment must account for runtime schema initialization in lib/db.ts.

Test with separate browser sessions and confirm access to data, not merely visibility of navigation links. Never expose DATABASE_URL, SESSION_SECRET, QDRANT_API_KEY or password hashes in screenshots or commits.

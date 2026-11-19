# Database verification scripts

Run these scripts from the repository root using a development database with migrations applied.

```sh
psql -d smartcivic -v ON_ERROR_STOP=1 -f db/checks/schema_inventory.sql
```

Replace the filename to run another check.

| Script | Purpose |
| --- | --- |
| schema_inventory.sql | Columns, constraints and indexes |
| routine_inventory.sql | Functions, procedures and triggers |
| roles.sql | Application roles and SQL privileges |
| department_workload.sql | Analytical CTE |
| relational_queries.sql | Joins and subqueries |
| incident_audit.sql | History and actors |
| full_text_search.sql | PostgreSQL lexical search |
| vector_sync_health.sql | Missing or failed synchronization records |
| trigger_demo.sql | Observe the trigger then roll back |
| crud_demo.sql | Insert, read, update and delete a demo row |
| constraint_tests.sql | Assert expected constraint failures |

The three write demonstrations use transactions and roll back data changes. Identity sequences can still advance. Run against a development database, not production. A direct SQL text update does not synchronously update Qdrant; use the application for real incident edits.

These are verification scripts, not evidence of successful execution on a particular machine. Review their output locally.

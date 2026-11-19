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

## Additional integration checks

Run on a disposable development database with all migrations applied and `ON_ERROR_STOP=1`.

| Script | Purpose |
| --- | --- |
| foreign_key_tests.sql | Restrict and cascade assertions |
| assignment_uniqueness.sql | Duplicate assignment rejection |
| manager_uniqueness.sql | Partial unique index behavior |
| feedback_constraints.sql | Rating and duplicate feedback checks |
| incident_defaults.sql | Initial values and insert trigger |
| auth_constraints.sql | Account uniqueness and optional relationship |
| incident_priority_status.sql | Priority and status CHECK constraints |
| notification_backlog.sql | Unread notification counts |
| assignment_integrity.sql | Officer department consistency |
| status_history_integrity.sql | Latest history versus current status |
| query_plans.sql | EXPLAIN examples |
| view_consistency.sql | Independent summary count comparison |
| recursive_status_report.sql | Recursive CTE timeline |
| priority_procedure.sql | Valid and invalid priority updates inside a rolled-back transaction |
| category_trends.sql | Daily incident counts grouped by category |
| backlog_age.sql | Age of open incidents |
| officer_workload.sql | Open workload per officer, including officers with zero assignments |
| feedback_statistics.sql | Feedback counts and averages with NULL for no ratings |

See also [vector lifecycle](../../docs/vector-lifecycle.md), [backup and restore](../../docs/database-backup.md), and [authorization boundaries](../../docs/database-access-model.md). These are checks to execute, not claimed passing test results.

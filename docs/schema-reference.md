# Schema reference

The ordered SQL migrations in `db/migrations/` are the source of truth for the relational schema. Run `db/checks/schema_inventory.sql` and `db/checks/routine_inventory.sql` against the intended database before documenting a deployment. Application roles stored in `users.role` are separate from PostgreSQL users, grants, and row-level security; see [database access boundaries](./database-access-model.md).

## Main entities

| Table | Purpose | Key relationships |
| --- | --- | --- |
| `auth_accounts` | Login email, password hash, and account metadata. | One optional `users` profile per account through a unique `users.auth_account_id`. |
| `users` | Resident, officer, and administrator profiles. | Optional department; referenced by reports, assignments, history, complaints, feedback, and notifications. |
| `departments` | Operational departments. | Has categories and users. |
| `categories` | Report categories. | Each category belongs to one department. |
| `incidents` | Civic reports, lifecycle state, priority, and search vector. | Belongs to one category and reporting user. |
| `assignments` | Officer assignments. | Links an incident, officer, and assigning administrator; `(incident_id, officer_id)` is unique. |
| `status_history` | Status audit trail. | Belongs to an incident; records the actor when available. |
| `feedback` | Resident rating and comment for a resolved report. | References one incident and one submitting user; one submission per user per incident. |
| `complaints` | Resident escalation about a report. | References one incident and one submitting user. |
| `notifications` | Feedback and complaint alerts. | References the relevant feedback or complaint and intended user. |
| `incident_vector_sync` | SQL-side status/error record for Qdrant indexing. | One synchronization row per incident. |

## Integrity notes

- Incident status is constrained to `pending`, `assigned`, `in_progress`, `resolved`, or `rejected`; priority is constrained to `low`, `medium`, `high`, or `critical`.
- Incident title, description, category, reporter, and location are required. The route handlers also validate user input and enforce ownership and role rules.
- Deleting an incident cascades its assignments, status history, feedback, complaint, notifications, and vector-sync row where defined by the migrations. The application also attempts to delete its Qdrant point.
- Departments and categories use restrictive foreign keys where deletion would invalidate existing incident history.
- No database-level row security or role grants are implied by the application role column. Verify actual deployment grants with `db/checks/roles.sql`.

This reference is derived from migrations 001-009 and reviewed against the project report's entity and relationship descriptions. A fresh schema-only dump and live grant inventory were not available in this environment; verify those against a disposable migrated database before treating them as deployment evidence.

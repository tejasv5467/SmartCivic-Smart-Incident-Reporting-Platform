# API reference

All API routes are Next.js route handlers under `/api`. Authenticated routes use the HTTP-only `smartcivic_session` cookie. Requests with JSON bodies should send `Content-Type: application/json`.

## Routes

| Method and route | Access | Purpose |
| --- | --- | --- |
| `POST /api/auth/signup` | Public | Create a resident account. |
| `POST /api/auth/login` | Public | Sign in to the selected resident, officer, or admin portal. |
| `POST /api/auth/logout` | Public | Expire the session cookie. |
| `GET /api/auth/me` | Any signed-in role | Return the current account and role. |
| `GET /api/incidents` | Any signed-in role | List incidents scoped to the resident, officer/manager, or admin. Optional `search` query supports PostgreSQL text search. |
| `POST /api/incidents` | Resident | Create a report. |
| `PATCH /api/incidents` | Resident | Edit an owned report before work starts. |
| `DELETE /api/incidents?id={id}` | Resident | Delete an owned pending or assigned report. |
| `GET /api/incidents/search?q={text}` | Any signed-in role | Search similar incidents within the caller's authorized scope. |
| `PATCH /api/incidents/status?id={id}` | Admin or authorized officer | Change an incident status. Officers may update only assigned work or work in their department as a manager, and can move it from `assigned` to `in_progress` and then `resolved`. |
| `POST /api/assignments` | Admin | Assign one or more eligible officers to a pending incident. |
| `GET /api/categories` | Any signed-in role | List active categories. |
| `POST /api/categories` | Admin | Create a category. |
| `GET /api/departments` | Admin | List departments. |
| `POST`, `PATCH`, `DELETE /api/departments` | Admin | Manage departments and their categories. |
| `GET`, `POST`, `PATCH`, `DELETE /api/officers` | Admin | List and manage officer profiles. |
| `GET /api/activity-history` | Any signed-in role | Return activity history scoped to the caller. |
| `GET`, `POST /api/complaints` | Any signed-in role for reads; resident for submit | Read eligible complaint data or create a resident complaint. |
| `GET`, `POST /api/feedback` | Any signed-in role for reads; resident for submit | Read eligible feedback data or submit feedback for a resolved report. |
| `GET`, `PATCH /api/notifications` | Admin or authorized officer | List alerts or mark an alert read. |
| `GET /api/db-test` | Admin | Check the configured database connection. |

Route authorization is enforced by the server. Hiding a control in the UI is not an access check. Role scope for incident search is applied before vector lookup, and returned vector IDs are joined back to the authorized PostgreSQL records.

## Request examples

Create a report:

~~~http
POST /api/incidents
Content-Type: application/json
Cookie: smartcivic_session=...

{
  "title": "Pothole near bus stop",
  "description": "A deep pothole collects water after rain.",
  "location": "Main Road, Ward 4",
  "category_id": 1,
  "priority": "medium"
}
~~~

Assign eligible officers:

~~~http
POST /api/assignments
Content-Type: application/json
Cookie: smartcivic_session=...

{
  "incident_id": 12,
  "officer_ids": [4, 7]
}
~~~

Update status:

~~~http
PATCH /api/incidents/status?id=12
Content-Type: application/json
Cookie: smartcivic_session=...

{ "status": "in_progress" }
~~~

## Response shapes

Successful list response:

~~~json
{
  "success": true,
  "count": 1,
  "incidents": [{ "incident_id": 12, "title": "Pothole near bus stop", "status": "assigned" }]
}
~~~

Validation or authorization error:

~~~json
{ "success": false, "message": "A valid incident ID is required." }
~~~

Common status codes are `200` for reads and updates, `201` for report creation, `400` for invalid input, `401` for a missing or expired session, `403` for a role or ownership restriction, `404` for an unavailable scoped record, `409` for a conflicting state, and `503` when Qdrant-backed search is unavailable. Exact response fields vary by route; callers should check both the HTTP status and the `success` field.

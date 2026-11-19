# Manual integration test plan

Use a development database, Qdrant and separate browser sessions for resident, officer and administrator. Use dummy credentials and incident data.

| Scenario | Expected behavior |
| --- | --- |
| Register resident | Account and resident profile created |
| Administrator login | Administrator portal accessible |
| Officer login | Officer portal accessible |
| Create incident | Pending incident and initial history stored |
| Assign eligible officer | Assignment and status history created atomically |
| Assign twice | Second request rejected |
| Officer from another department updates incident | Request rejected |
| Update assigned incident | Status and audit history agree |
| Resolve incident | Resident can see resolution |
| Similarity search | Only authorized incidents appear |
| Edit a pending report | Search point updated through application |
| Delete a pending report | SQL record removed; verify Qdrant point separately |
| Submit complaint | Relevant recipient receives notification |
| Qdrant temporarily unavailable | Verify SQL record retention and subsequent indexing recovery |
| Blank or whitespace-only report fields | API rejects the request and the form displays a useful message |
| Duplicate report submission | A pending request disables the submit button and the server stores one report |
| Resident report filters | Search, status, and priority filters combine; reset restores the full list |
| Resident ownership | A second resident cannot read, edit, or delete another resident's report |
| Admin queue filters | Search, status, and priority filters combine; reset restores the active queue |
| Officer status transition | An officer can advance assigned work and cannot skip or reverse workflow states |
| Assignment rollback | Force a status-history insert failure in a disposable database; confirm the assignment and incident status both roll back |
| Protected API routes | Resident, admin, and officer sessions receive only their permitted data and actions |
| Invalid login | Wrong password and unknown account both return the same credential error |
| Logout | Sign out, then confirm protected APIs reject the expired session |
| Fresh migration setup | Apply migrations 001-010 to an empty disposable database and run the SQL checks |
| Feedback summary | Incidents without ratings show a NULL average and a zero feedback count |

Record actual results and timestamps when running each test. Do not interpret a similarity score as accuracy. The table is a test plan, not a report of passed tests.

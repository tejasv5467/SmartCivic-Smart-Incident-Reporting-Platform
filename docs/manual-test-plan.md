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

Record actual results and timestamps when running each test. Do not interpret a similarity score as accuracy. The table is a test plan, not a report of passed tests.

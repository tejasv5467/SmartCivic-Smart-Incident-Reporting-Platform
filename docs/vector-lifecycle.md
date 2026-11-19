# Vector lifecycle verification

Use a disposable development incident and the application UI. PostgreSQL is the authoritative store, while the Qdrant collection uses the incident ID as its point ID. Do not manually insert or delete points for genuine reports.

The application provisions `smartcivic_incidents` with 384-dimensional vectors and cosine distance (`lib/incident-embeddings.ts`, `lib/qdrant.ts`).

1. Create a pending report. Record its numeric incident ID.
2. Check the matching SQL synchronization record.
3. Retrieve the point through local Qdrant (`GET /collections/smartcivic_incidents/points/{id}`).
4. Edit the pending report in the civic portal, changing its title substantially. Retrieve the point again and compare the vectors.
5. Delete the test report before assignment. Verify that the SQL incident, synchronization row and Qdrant point are absent.
6. Repeat with Qdrant temporarily unavailable only in a disposable environment. Record the `last_error` and confirm the SQL report remains saved.
7. Restore Qdrant, then run a similar-incident search within that report's authorized scope. Confirm a missing point or a sync row with a recorded error is retried and its `indexed_at` is refreshed.
8. Confirm that an officer can see only assigned incidents (or department incidents for a manager) and that a resident sees only their own incidents in similarity results.

A synchronization row alone does not prove the Qdrant point is present or current. A cosine similarity score is not a classification accuracy metric. The embedding is a deterministic 384-dimensional feature hash, not a pretrained neural model.

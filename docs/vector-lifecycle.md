# Vector lifecycle verification

Use a disposable development incident and the application UI. PostgreSQL is the authoritative store, while the Qdrant collection uses the incident ID as its point ID. Do not manually insert or delete points for genuine reports.

1. Create a pending report. Record its numeric incident ID.
2. Check the matching SQL synchronization record.
3. Retrieve the point through local Qdrant (`GET /collections/smartcivic_incidents/points/{id}`).
4. Edit the pending report in the civic portal, changing its title substantially. Retrieve the point again and compare the vectors.
5. Delete the test report before assignment. Verify that the SQL incident, synchronization row and Qdrant point are absent.
6. Repeat with Qdrant temporarily unavailable only in a disposable environment. Record any indexing failure and verify what the application actually recovers after restart.

A synchronization row alone does not prove the Qdrant point is present or current. A cosine similarity score is not a classification accuracy metric. The embedding is a deterministic 384-dimensional feature hash, not a pretrained neural model.

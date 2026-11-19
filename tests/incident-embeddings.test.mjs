import assert from "node:assert/strict";
import test from "node:test";
import {
  embedIncidentText,
  INCIDENT_EMBEDDING_DIMENSIONS,
} from "../lib/incident-embeddings.ts";
import {
  getOfficerStatusOptions,
  isAllowedOfficerStatusTransition,
} from "../lib/incident-status.ts";

test("incident embeddings are deterministic and normalized", () => {
  const input = "Pothole near bus stop, water collects after rain";
  const first = embedIncidentText(input);
  const second = embedIncidentText(input);

  assert.deepEqual(first, second);
  assert.equal(first.length, INCIDENT_EMBEDDING_DIMENSIONS);
  assert.ok(first.every(Number.isFinite));
  assert.ok(Math.abs(Math.hypot(...first) - 1) < 1e-12);
});

test("empty and one-character-only text produce a finite zero vector", () => {
  for (const input of ["", "   ", "! ? .", "a 1"]) {
    const vector = embedIncidentText(input);
    assert.equal(vector.length, INCIDENT_EMBEDDING_DIMENSIONS);
    assert.ok(vector.every((value) => value === 0 && Number.isFinite(value)));
  }
});

test("officer status changes follow the assigned-to-progress-to-resolved path", () => {
  assert.equal(isAllowedOfficerStatusTransition("assigned", "in_progress"), true);
  assert.equal(isAllowedOfficerStatusTransition("in_progress", "resolved"), true);
  assert.equal(isAllowedOfficerStatusTransition("pending", "resolved"), false);
  assert.equal(isAllowedOfficerStatusTransition("in_progress", "assigned"), false);
  assert.equal(isAllowedOfficerStatusTransition("resolved", "in_progress"), false);
  assert.deepEqual(getOfficerStatusOptions("assigned"), ["assigned", "in_progress"]);
});

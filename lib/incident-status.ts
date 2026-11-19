export const INCIDENT_STATUSES = [
  "pending",
  "assigned",
  "in_progress",
  "resolved",
  "rejected",
] as const;

const officerTransitions: Record<string, readonly string[]> = {
  pending: [],
  assigned: ["in_progress"],
  in_progress: ["resolved"],
  resolved: [],
  rejected: [],
};

export function isAllowedOfficerStatusTransition(from: string, to: string) {
  return officerTransitions[from]?.includes(to) ?? false;
}

export function getOfficerStatusOptions(currentStatus: string) {
  return [currentStatus, ...(officerTransitions[currentStatus] ?? [])];
}

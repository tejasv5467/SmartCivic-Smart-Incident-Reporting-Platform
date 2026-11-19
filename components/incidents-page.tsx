"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import NotificationsPanel from "@/components/notifications-panel";
import IncidentSearch from "@/components/incident-search";

type Officer = {
  user_id: number;
  full_name: string;
  department_id: number | string;
  department_name: string;
  is_active: boolean;
};

type Incident = {
  incident_id: number;
  title: string;
  description?: string;
  category_name?: string;
  department_id?: number | string;
  department_name?: string;
  location?: string;
  priority?: string;
  status: string;
  is_assigned?: boolean;
  assigned_officers?: string[];
  reported_by?: string;
  created_at?: string;
};

export default function IncidentsClientPage() {
  const router = useRouter();
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchFilter, setSearchFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [priorityFilter, setPriorityFilter] = useState("all");
  const [officerIds, setOfficerIds] = useState<string[]>([]);
  const [officers, setOfficers] = useState<Officer[]>([]);
  const [selectedIncident, setSelectedIncident] = useState("");
  const [assignMessage, setAssignMessage] = useState("");
  const [assignError, setAssignError] = useState(false);
  const [assigning, setAssigning] = useState(false);
  const [updatingIncidentId, setUpdatingIncidentId] = useState<number | null>(null);

  useEffect(() => {
    async function loadOfficers() {
      try {
        const response = await fetch("/api/officers");
        if (response.status === 401) {
          router.replace("/admin/login");
          return;
        }
        const data = await response.json();

        if (!response.ok || !data.success) {
          throw new Error(data.message || "Failed to load officers.");
        }

        setOfficers(data.officers);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to load officers.");
      }
    }

    loadOfficers();
  }, [router]);

  async function assignOfficer() {
    if (!selectedIncident || officerIds.length === 0) {
      setAssignError(true);
      setAssignMessage("Select a pending incident and at least one officer.");
      return;
    }
    const incidentIdToAssign = Number(selectedIncident);
    const chosenOfficers = officers.filter((officer) =>
      officerIds.includes(String(officer.user_id))
    );

    try {
      setAssigning(true);
      setAssignError(false);
      setAssignMessage("Assigning officer...");

      const response = await fetch("/api/assignments", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          incident_id: incidentIdToAssign,
          officer_ids: officerIds.map(Number),
        }),
      });

      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(data.message || "Assignment failed.");
      }

      // Immediately clear selection and update local incident state
      // so the newly assigned incident immediately vanishes from the dropdown
      setSelectedIncident("");
      setOfficerIds([]);
      setAssignMessage(
        `Successfully assigned #${incidentIdToAssign} to ${chosenOfficers
          .map((officer) => officer.full_name)
          .join(", ")}.`
      );

      setIncidents((current) =>
        current.map((inc) =>
          inc.incident_id === incidentIdToAssign
            ? {
                ...inc,
                status: "assigned",
                is_assigned: true,
                assigned_officers: chosenOfficers.map((officer) => officer.full_name),
              }
            : inc
        )
      );

      const refresh = await fetch("/api/incidents");
      const refreshedData = await refresh.json();

      if (refresh.ok && refreshedData.success) {
        setIncidents(refreshedData.incidents);
      }
    } catch (err) {
      setAssignError(true);
      const details = err instanceof Error ? err.message : "";
      setAssignMessage(
        details === "Failed to fetch"
          ? "Could not contact the server. Check your connection and try again."
          : details
            ? `Assignment failed: ${details}`
            : "Assignment failed. Check your connection and try again."
      );
    } finally {
      setAssigning(false);
    }
  }

  async function updateIncidentStatus(incidentId: number, status: string) {
    setUpdatingIncidentId(incidentId);
    setAssignError(false);
    setAssignMessage("");

    try {
      const response = await fetch(`/api/incidents/status?id=${incidentId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status }),
      });
      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(data.message || "Unable to update incident status.");
      }

      // If resolved or rejected, filter out; otherwise update status
      setIncidents((current) =>
        status === "resolved" || status === "rejected"
          ? current.filter((incident) => incident.incident_id !== incidentId)
          : current.map((incident) =>
              incident.incident_id === incidentId
                ? { ...incident, status }
                : incident
            )
      );

      if (
        (status === "resolved" || status === "rejected") &&
        selectedIncident === String(incidentId)
      ) {
        setSelectedIncident("");
        setOfficerIds([]);
      }

      setAssignMessage(`Incident #${incidentId} marked ${status.replace("_", " ")}.`);
    } catch (err) {
      setAssignError(true);
      setAssignMessage(
        err instanceof Error ? err.message : "Unable to update incident status."
      );
    } finally {
      setUpdatingIncidentId(null);
    }
  }

  useEffect(() => {
    let sessionExpired = false;

    async function loadIncidents() {
      if (sessionExpired) return;

      try {
        const incidentsResponse = await fetch("/api/incidents", {
          cache: "no-store",
        });
        if (incidentsResponse.status === 401) {
          sessionExpired = true;
          if (refreshTimer !== undefined) window.clearInterval(refreshTimer);
          router.replace("/admin/login");
          return;
        }
        const incidentsData = await incidentsResponse.json();

        if (!incidentsResponse.ok || !incidentsData.success) {
          throw new Error(incidentsData.message || "Failed to load incidents.");
        }

        setIncidents(incidentsData.incidents);
        setError("");
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Something went wrong."
        );
      } finally {
        setLoading(false);
      }
    }

    void loadIncidents();
    const refreshTimer = window.setInterval(() => void loadIncidents(), 10000);
    return () => {
      window.clearInterval(refreshTimer);
    };
  }, [router]);

  async function retryPortalData() {
    setLoading(true);
    setError("");
    try {
      const [incidentsResponse, officersResponse] = await Promise.all([
        fetch("/api/incidents", { cache: "no-store" }),
        fetch("/api/officers", { cache: "no-store" }),
      ]);
      if (incidentsResponse.status === 401 || officersResponse.status === 401) {
        router.replace("/admin/login");
        return;
      }
      const [incidentsData, officersData] = await Promise.all([
        incidentsResponse.json(),
        officersResponse.json(),
      ]);
      if (!incidentsResponse.ok || !incidentsData.success) {
        throw new Error(incidentsData.message || "Failed to load incidents.");
      }
      if (!officersResponse.ok || !officersData.success) {
        throw new Error(officersData.message || "Failed to load officers.");
      }
      setIncidents(incidentsData.incidents);
      setOfficers(officersData.officers);
    } catch (retryError) {
      setError(
        retryError instanceof Error
          ? retryError.message
          : "Unable to reload the admin portal."
      );
    } finally {
      setLoading(false);
    }
  }

  // Strictly filter only pending AND unassigned incidents.
  // Assigned, in_progress, resolved, and rejected incidents are excluded from assignment choice.
  const pendingIncidents = incidents.filter(
    (incident) =>
      incident.status?.toLowerCase().trim() === "pending" &&
      !incident.is_assigned
  );

  const selectedIncidentRecord = pendingIncidents.find(
    (incident) => String(incident.incident_id) === selectedIncident
  );

  const availableOfficers = selectedIncidentRecord
    ? officers.filter(
        (officer) =>
          officer.is_active &&
          String(officer.department_id) ===
            String(selectedIncidentRecord.department_id)
      )
    : [];

  const filteredIncidents = incidents.filter((incident) => {
    const query = searchFilter.trim().toLowerCase();
    const matchesSearch =
      !query ||
      [
        incident.title,
        incident.location,
        incident.category_name,
        incident.department_name,
        incident.reported_by,
        ...(incident.assigned_officers ?? []),
        String(incident.incident_id),
      ].some((value) => value?.toLowerCase().includes(query));
    return (
      matchesSearch &&
      (statusFilter === "all" || incident.status === statusFilter) &&
      (priorityFilter === "all" || incident.priority === priorityFilter)
    );
  });

  return (
    <main className="min-h-screen bg-gray-100 p-6 text-gray-900 md:p-10">
      <div className="mx-auto max-w-7xl">
        <div className="mb-8">
          <h1 className="text-3xl font-bold">Incident Management</h1>
          <p className="mt-2 text-gray-600">
            View, track, and assign reported civic incidents to field officers.
          </p>
        </div>

        <NotificationsPanel />
        <IncidentSearch />

        {/* Assign Incident Section */}
        <div className="mb-6 rounded-xl border bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold">Assign Incident to Officer</h2>
              <p className="mt-1 text-sm text-gray-600">
                Select one or more active officers for an unassigned pending incident. Other statuses are excluded.
              </p>
            </div>
            <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-semibold text-blue-800">
              {pendingIncidents.length} pending to assign
            </span>
          </div>

          <div className="mt-4 grid gap-4 md:grid-cols-3">
            <div>
              <label className="mb-2 block text-sm font-medium">
                Select Pending Incident
              </label>
              <select
                value={selectedIncidentRecord ? selectedIncident : ""}
                onChange={(e) => {
                  const incidentId = e.target.value;
                  setSelectedIncident(incidentId);
                  setOfficerIds([]);
                }}
                className="w-full rounded-lg border p-3 bg-white"
              >
                <option value="">
                  {pendingIncidents.length === 0
                    ? "No pending unassigned incidents"
                    : "Choose an incident"}
                </option>
                {pendingIncidents.map((incident) => (
                  <option
                    key={incident.incident_id}
                    value={incident.incident_id}
                  >
                    #{incident.incident_id} — {incident.title} ({incident.department_name || "Department"})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="mb-2 block text-sm font-medium">
                Select Officers (choose one or more)
              </label>
              <div
                className="max-h-44 space-y-2 overflow-y-auto rounded-lg border p-3"
                aria-disabled={!selectedIncidentRecord}
              >
                {!selectedIncidentRecord ? (
                  <p className="text-sm text-gray-500">Choose an incident first.</p>
                ) : availableOfficers.length === 0 ? (
                  <p className="text-sm text-gray-500">No officers in this department.</p>
                ) : (
                  availableOfficers.map((officer) => (
                    <label key={officer.user_id} className="flex items-center gap-2 text-sm">
                      <input
                        type="checkbox"
                        checked={officerIds.includes(String(officer.user_id))}
                        onChange={(event) =>
                          setOfficerIds((current) =>
                            event.target.checked
                              ? [...current, String(officer.user_id)]
                              : current.filter((id) => id !== String(officer.user_id))
                          )
                        }
                      />
                      <span>{officer.full_name} — {officer.department_name}</span>
                    </label>
                  ))
                )}
              </div>
            </div>

            <div className="flex items-end">
              <button
                onClick={assignOfficer}
                disabled={
                  loading || assigning || !selectedIncidentRecord || !officerIds.length
                }
                className="w-full rounded-lg bg-blue-600 px-4 py-3 font-medium text-white hover:bg-blue-700 disabled:opacity-50 transition"
              >
                {assigning ? "Assigning..." : `Assign selected officers (${officerIds.length})`}
              </button>
            </div>
          </div>

          {assignMessage && (
            <p
              className={`mt-4 rounded-lg border p-2.5 text-sm font-medium ${
                assignError
                  ? "border-red-200 bg-red-50 text-red-700"
                  : "border-blue-200 bg-blue-50 text-blue-700"
              }`}
              role={assignError ? "alert" : "status"}
            >
              {assignMessage}
            </p>
          )}
        </div>

        <div className="mb-6 rounded-xl border bg-white p-5 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500">Active incidents needing attention</p>
            <p className="mt-1 text-3xl font-bold">{incidents.length}</p>
          </div>
          <Link
            href="/admin/feedback"
            className="rounded-lg bg-gray-50 border px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100"
          >
            View Citizen Feedback & Complaints →
          </Link>
        </div>

        {loading ? (
          <p>Loading incidents...</p>
        ) : error ? (
          <div className="rounded-lg bg-red-50 p-4 text-red-700" role="alert">
            <p>Error: {error}</p>
            <button
              type="button"
              className="mt-2 rounded border border-red-300 px-3 py-1"
              onClick={() => void retryPortalData()}
            >
              Try again
            </button>
          </div>
        ) : incidents.length === 0 ? (
          <p className="rounded-lg bg-white p-6 text-gray-600">
            No active incidents found.
          </p>
        ) : (
          <>
          <section className="mb-4 flex flex-col gap-3 rounded-xl border bg-white p-4 shadow-sm sm:flex-row">
            <label className="sr-only" htmlFor="admin-incident-search">Search active incidents</label>
            <input
              id="admin-incident-search"
              type="search"
              value={searchFilter}
              onChange={(event) => setSearchFilter(event.target.value)}
              placeholder="Search title, category, location, officer..."
              className="min-w-0 flex-1 rounded-lg border px-3 py-2"
            />
            <label className="sr-only" htmlFor="admin-incident-status">Filter by status</label>
            <select
              id="admin-incident-status"
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value)}
              className="rounded-lg border bg-white px-3 py-2"
            >
              <option value="all">All statuses</option>
              <option value="pending">Pending</option>
              <option value="assigned">Assigned</option>
              <option value="in_progress">In progress</option>
            </select>
            <label className="sr-only" htmlFor="admin-incident-priority">Filter by priority</label>
            <select
              id="admin-incident-priority"
              value={priorityFilter}
              onChange={(event) => setPriorityFilter(event.target.value)}
              className="rounded-lg border bg-white px-3 py-2"
            >
              <option value="all">All priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
            {(searchFilter || statusFilter !== "all" || priorityFilter !== "all") && (
              <button
                type="button"
                className="rounded-lg border px-3 py-2 text-sm"
                onClick={() => {
                  setSearchFilter("");
                  setStatusFilter("all");
                  setPriorityFilter("all");
                }}
              >
                Reset filters
              </button>
            )}
          </section>
          {filteredIncidents.length === 0 ? (
            <p className="rounded-lg bg-white p-6 text-gray-600" role="status">
              No active incidents match these filters. Reset the filters to see the full queue.
            </p>
          ) : (
          <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
            <table className="incident-data-table w-full text-left text-sm">
              <thead className="bg-gray-50 text-gray-600">
                <tr>
                  <th className="p-4">ID</th>
                  <th className="p-4">Incident</th>
                  <th className="p-4">Category</th>
                  <th className="p-4">Department</th>
                  <th className="p-4">Assigned officers</th>
                  <th className="p-4">Location</th>
                  <th className="p-4">Priority</th>
                  <th className="p-4">Status</th>
                  <th className="p-4">Update status</th>
                </tr>
              </thead>
              <tbody>
                {filteredIncidents.map((incident) => (
                  <tr
                    key={incident.incident_id}
                    className="border-t hover:bg-gray-50"
                  >
                    <td className="p-4">{incident.incident_id}</td>
                    <td className="p-4 font-medium">{incident.title}</td>
                    <td className="p-4">
                      {incident.category_name || "—"}
                    </td>
                    <td className="p-4">
                      {incident.department_name || "—"}
                    </td>
                    <td className="p-4">
                      {incident.assigned_officers?.length
                        ? incident.assigned_officers.join(", ")
                        : "Unassigned"}
                    </td>
                    <td className="p-4">{incident.location || "—"}</td>
                    <td className="p-4 capitalize">
                      {incident.priority || "—"}
                    </td>
                    <td className="p-4">
                      <span className={`rounded-full px-3 py-1 text-xs font-medium capitalize ${
                        incident.status === "pending"
                          ? "bg-amber-100 text-amber-800"
                          : incident.status === "assigned"
                            ? "bg-blue-100 text-blue-800"
                            : incident.status === "in_progress"
                              ? "bg-purple-100 text-purple-800"
                              : "bg-gray-100 text-gray-800"
                      }`}>
                        {incident.status.replace("_", " ")}
                      </span>
                    </td>
                    <td className="p-4">
                      <select
                        aria-label={`Update status for incident ${incident.incident_id}`}
                        value={incident.status}
                        disabled={updatingIncidentId === incident.incident_id}
                        onChange={(event) =>
                          void updateIncidentStatus(
                            incident.incident_id,
                            event.target.value
                          )
                        }
                        className="rounded-lg border p-2 bg-white"
                      >
                        <option value="pending">Pending</option>
                        <option value="assigned">Assigned</option>
                        <option value="in_progress">In progress</option>
                        <option value="resolved">Resolved</option>
                        <option value="rejected">Rejected</option>
                      </select>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          )}
          </>
        )}
      </div>
    </main>
  );
}

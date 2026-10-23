#!/usr/bin/env python3
"""Print a readable summary of an OpenLane final_summary_report.csv.

Usage:
  python3 scripts/summarize_run.py [path/to/final_summary_report.csv]
"""
import csv
import sys

DEFAULT = "designs/traffic_controller/runs/10-10_08-33/reports/final_summary_report.csv"
p = sys.argv[1] if len(sys.argv) > 1 else DEFAULT

with open(p, newline="") as f:
    r = next(csv.DictReader(f))

items = [
    ("Flow status", r["flow_status"]),
    ("Total runtime", r["total_runtime"]),
    ("Standard-cell count", r["cell_count"]),
    ("TritonRoute violations", r["tritonRoute_violations"]),
    ("Magic violations", r["Magic_violations"]),
    ("Antenna violations", r["antenna_violations"]),
    ("LVS total errors", r["lvs_total_errors"]),
    ("Routed wire length (report units)", r["wire_length"]),
    ("Vias", r["vias"]),
    ("Configured clock period", r["CLOCK_PERIOD"] + " ns"),
    ("Suggested clock frequency", r["suggested_clock_frequency"] + " MHz"),
]

print("\n=== TRAFFIC CONTROLLER - OPENLANE RUN SUMMARY ===\n")
for k, v in items:
    print(f"{k:<34} {v}")
print("\nSource: OpenLane final_summary_report.csv")

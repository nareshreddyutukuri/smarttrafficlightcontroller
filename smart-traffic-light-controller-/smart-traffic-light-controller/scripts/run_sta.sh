#!/usr/bin/env bash
# Run the simplified OpenSTA analysis from the OpenLane working directory.
set -euo pipefail
: "${PDK_ROOT:?Set PDK_ROOT (e.g. ~/Desktop/work/tools/openlane_working_dir/pdks)}"
sta -no_splash -exit "$(dirname "$0")/../sta/traffic_controller_sta.tcl" | tee sta_report.txt

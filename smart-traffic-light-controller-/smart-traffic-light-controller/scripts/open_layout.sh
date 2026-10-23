#!/usr/bin/env bash
# Open the final GDS in Magic (as in the layout screenshots).
set -euo pipefail
: "${PDK_ROOT:?Set PDK_ROOT}"
RUN=${1:-10-10_08-33}
magic -T "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.tech" -d XR \
  "designs/traffic_controller/runs/$RUN/results/magic/traffic_controller.gds"

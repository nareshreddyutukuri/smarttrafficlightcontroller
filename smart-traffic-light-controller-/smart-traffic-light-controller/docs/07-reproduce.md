# Reproducing the results

> Commands marked **(evidence)** are visible in the screenshots. Commands marked **(verified)** were run for this repo on the
> provided source. Commands marked **(typical)** are standard forms of the same step; adjust file names to your layout.

## Environment

- Ubuntu VM in VirtualBox (`vsdworkshop_pd`), user `vsduser`
- OpenLane v0.21 working directory: `~/Desktop/work/tools/openlane_working_dir/openlane` (evidence)
- Tools: Icarus Verilog (needs `-g2012` for `$fatal`), GTKWave, Yosys / OpenROAD / TritonRoute / Magic / KLayout (inside the
  OpenLane container), OpenSTA (`sta`, on the host)
- PDK: SKY130A, library `sky130_fd_sc_hd`

## 1. RTL simulation (verified)

From the repository root:

```bash
iverilog -g2012 -o sim rtl/traffic_controller.v tb/traffic_controller_tb.v
vvp sim                                   # writes traffic_controller.vcd, ends at 380 ns
gtkwave traffic_controller.vcd            # interactive view
python3 scripts/plot_waveform.py traffic_controller.vcd docs/images/14-generated-waveform-provided-tb.png
```

## 2. Prepare the OpenLane design directory (typical)

```bash
mkdir -p designs/traffic_controller/src
cp rtl/traffic_controller.v designs/traffic_controller/src/
cp openlane/config.json designs/traffic_controller/config.json     # your real config, see openlane/README.md
```

## 3. RTL-to-GDS with OpenLane (typical)

```bash
cd ~/Desktop/work/tools/openlane_working_dir/openlane
make mount                                  # enter the OpenLane container
./flow.tcl -design traffic_controller       # run directory: runs/<timestamp>
```

Evidence: container path `/openLANE_flow/designs/traffic_controller/runs/10-10_08-33`, up to step 42, 0h2m3s runtime,
`[SUCCESS]: Flow Completed Without Fatal Errors.`

Useful artifacts in the run directory:

| Path | Content |
|---|---|
| `results/synthesis/` | Mapped netlist |
| `results/routing/traffic_controller.spef` | Post-route parasitics (used by STA, evidence) |
| `results/magic/traffic_controller.gds` | Final GDS (evidence) |
| `results/klayout/` | KLayout-streamed layout (evidence: directory visible) |
| `reports/magic/39-magic.drc` | Magic DRC report (evidence) |
| `reports/routing/41-antenna.rpt` | Antenna report (evidence) |
| `results/lvs/traffic_controller.lvs_parsed.lef.log` | LVS log (evidence) |
| `reports/final_summary_report.csv` | Summary metrics (evidence) |

## 4. Summarise the run (evidence)

```bash
python3 scripts/summarize_run.py designs/traffic_controller/runs/<run>/reports/final_summary_report.csv
```

## 5. Gate-level simulation

The run on screen is `vvp designs/traffic_controller/traffic_controller_gls` (evidence). Use the self-counting testbench
(the one that prints the `PASS:` lines), **not** `tb/traffic_controller_tb.v`: the provided testbench overrides module
parameters with `#( ... )`, which cannot be applied to a synthesised netlist, and the netlist always uses the parameter
values it was synthesised with. The compile step is typically:

```bash
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#0 -o designs/traffic_controller/traffic_controller_gls \
  $PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v \
  $PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v \
  designs/traffic_controller/runs/<run>/results/synthesis/traffic_controller.synthesis.v \
  tb/traffic_controller_gls_tb.v
vvp designs/traffic_controller/traffic_controller_gls
```

## 6. Static timing analysis (evidence: script content)

```bash
export PDK_ROOT=~/Desktop/work/tools/openlane_working_dir/pdks
sta -no_splash -exit sta/traffic_controller_sta.tcl      # or ./scripts/run_sta.sh
```

## 7. View the layout (evidence)

```bash
./scripts/open_layout.sh <run>
# equivalent to:
magic -T "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.tech" -d XR \
  designs/traffic_controller/runs/<run>/results/magic/traffic_controller.gds
```

See [06-drc-investigation](06-drc-investigation.md) for the open `DRC=491` question.

## 8. Yosys comparison used for the consistency check (verified)

```bash
yosys -p "read_verilog rtl/traffic_controller.v; hierarchy -check -top traffic_controller; proc; flatten; opt; check; stat"
```

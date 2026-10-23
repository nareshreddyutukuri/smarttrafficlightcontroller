# Evidence index

Every result in this repository traces back to one of these 13 screenshots (plus one generated plot, #14), all taken on an Ubuntu VM
(VirtualBox, `vsdworkshop_pd`) running OpenLane v0.21 with the SKY130A PDK. The OpenLane run directory is
`designs/traffic_controller/runs/10-10_08-33` (a run started on 10 Oct, 08:33). The screenshots were captured on 18 Oct 2026.

| # | Image | What it shows | Used in |
|---|---|---|---|
| 01 | `01-rtl-simulation-waveform.png` | GTKWave view of `traffic_controller.vcd`, 0-930 ns, all ports | [02-verification](02-verification.md) |
| 02 | `02-gate-level-simulation-pass.png` | `vvp` run of the gate-level simulation: 6 PASS lines, 90 safety checks | [02-verification](02-verification.md) |
| 03 | `03-yosys-synthesis-statistics.png` | Yosys check pass and generic cell statistics (44 cells) | [03-synthesis](03-synthesis.md) |
| 04 | `04-openlane-flow-completion-summary.png` | End of the OpenLane log: Magic DRC, LVS, antenna summaries, flow success | [04-physical-design](04-physical-design.md) |
| 05 | `05-openlane-final-summary-csv.png` | Python read-out of `final_summary_report.csv` | [04-physical-design](04-physical-design.md) |
| 06 | `06-routed-metal-segments.png` | Routed-DEF metal segment plot by layer | [04-physical-design](04-physical-design.md) |
| 07 | `07-opensta-constraints-script.png` | OpenSTA command script (liberty, SPEF, clock, I/O delays) | [05-timing-analysis](05-timing-analysis.md) |
| 08 | `08-opensta-setup-paths.png` | `report_checks -path_delay max` summary (20 endpoints) | [05-timing-analysis](05-timing-analysis.md) |
| 09 | `09-opensta-setup-and-hold-paths.png` | Setup and hold path summaries side by side | [05-timing-analysis](05-timing-analysis.md) |
| 10 | `10-magic-layout-drc-counter.png` | Magic window showing the GDS with `DRC=491` | [06-drc-investigation](06-drc-investigation.md) |
| 11 | `11-magic-layout-drc-counter-zoom.png` | Same layout, zoomed, cell labels visible | [06-drc-investigation](06-drc-investigation.md) |
| 12 | `12-magic-session-in-vm.png` | Magic launch from the VM terminal, DRC CIF style loading | [06-drc-investigation](06-drc-investigation.md) |
| 13 | `13-magic-gds-read-console.png` | Magic console: "already existed before reading GDS" warnings | [06-drc-investigation](06-drc-investigation.md) |
| 14 | `14-generated-waveform-provided-tb.png` | **Generated** (not a screenshot): waveform of `tb/traffic_controller_tb.v` on `rtl/traffic_controller.v`, produced by `scripts/plot_waveform.py` | [02-verification](02-verification.md) |

Numbers marked "approx." in the docs are read off a screenshot (for example waveform edges) and are not
tool-reported values.

**Source consistency.** The screenshots come from a run whose synthesised RTL and testbench differ from the files now in `rtl/`
and `tb/` (see [03-synthesis](03-synthesis.md) and [02-verification](02-verification.md)). Re-running the flow on the final RTL will
bring the evidence and the source into line.

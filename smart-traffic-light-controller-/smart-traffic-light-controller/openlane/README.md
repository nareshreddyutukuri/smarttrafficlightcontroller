# openlane/

`config.json.example` is a **minimal template**, not a copy of the configuration used for the recorded run.
Only the design name, the clock port and `CLOCK_PERIOD = 20` ns are confirmed by the evidence
(`CLOCK_PERIOD` appears as `20 ns` in `final_summary_report.csv`). Replace it with the real
`config.json` (including floorplan / placement settings) from `designs/traffic_controller/` and commit it as `config.json`.

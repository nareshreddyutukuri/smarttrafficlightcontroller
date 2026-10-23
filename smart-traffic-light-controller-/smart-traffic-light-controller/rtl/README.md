# rtl/

`traffic_controller.v` is the design source exactly as written (top module `traffic_controller`).

- 9-state FSM, 4-bit state, 16-bit phase timer, 1-bit `ped_pending`, **asynchronous active-high reset**
- Phase durations are parameters (in clock cycles): `NS_GREEN_TIME=10`, `NS_YELLOW_TIME=3`, `EW_GREEN_TIME=10`,
  `EW_YELLOW_TIME=3`, `ALL_RED_TIME=2`, `PED_WALK_TIME=5`
- Outputs are decoded combinationally from the state

Compile check (Icarus Verilog 12): clean. The only message is the "no explicit time unit" notice because the file has no
`` `timescale``. State table, diagram and design review: [docs/01-design-overview.md](../docs/01-design-overview.md).

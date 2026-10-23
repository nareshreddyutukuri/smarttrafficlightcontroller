# tb/

`traffic_controller_tb.v` is the testbench exactly as written.

What it does:

- Instantiates the DUT with **shortened** parameters (`5 / 2 / 5 / 2 / 1 / 3` cycles) and a 10 ns clock
- Stimulus: reset 20 ns, run 100 ns, `ped_request` for 10 ns (at 120 ns), run 100 ns, `emergency_request` for 50 ns
  (230-280 ns), run 100 ns, finish at 380 ns
- Self-checks on every clock after reset: no simultaneous NS/EW green, and `ped_walk` only while both roads are red
  (`$fatal` on violation)
- Dumps `traffic_controller.vcd`

Run it (needs SystemVerilog for `$fatal`):

```bash
iverilog -g2012 -o sim rtl/traffic_controller.v tb/traffic_controller_tb.v
vvp sim
```

Verified output:

```
Reset released at 20000 ns
Pedestrian request sent at 130000 ns
Pedestrian crossing active at 195000 ns   (also 205000 and 215000)
Emergency request asserted at 230000 ns
Emergency request removed at 280000 ns
Testbench completed.
```

The numbers are picosecond values labelled "ns": `%0t` prints in the simulator precision (1 ps). Add
`$timeformat(-9, 0, " ns", 0);` at the start of the initial block to print real nanoseconds.

> **Not the testbench behind the screenshots.** The gate-level run in `docs/images/02-gate-level-simulation-pass.png`
> prints six `PASS:` lines and "90 checks", and the GTKWave capture contains a `checks` signal. This testbench has
> neither, and its parameter overrides cannot be applied to a synthesized netlist. A second, self-counting testbench was
> therefore used for those results. Add it to this folder (for example `traffic_controller_gls_tb.v`) so the repo
> contains everything needed to reproduce the evidence. See [docs/02-verification.md](../docs/02-verification.md).

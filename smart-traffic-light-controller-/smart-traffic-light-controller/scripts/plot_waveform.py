#!/usr/bin/env python3
"""Plot the traffic_controller testbench VCD as a clean waveform image and print the phase timeline.

Usage:
  python3 scripts/plot_waveform.py traffic_controller.vcd docs/images/14-generated-waveform-provided-tb.png
Requires matplotlib.
"""
import re
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

SIGNALS = ["clk", "rst", "ped_request", "emergency_request",
           "ns_red", "ns_yellow", "ns_green",
           "ew_red", "ew_yellow", "ew_green",
           "ped_walk", "ped_dont_walk"]


def parse_vcd(path):
    ids, scale, t, changes = {}, 1e-12, 0, {}
    unit = {"s": 1.0, "ms": 1e-3, "us": 1e-6, "ns": 1e-9, "ps": 1e-12, "fs": 1e-15}
    with open(path) as f:
        text = f.read()
    m = re.search(r"\$timescale\s+(\d+)\s*(\w+)\s+\$end", text)
    if m:
        scale = int(m.group(1)) * unit[m.group(2)]
    scope = []
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("$scope"):
            scope.append(line.split()[2])
        elif line.startswith("$upscope"):
            scope.pop()
        elif line.startswith("$var"):
            p = line.split()
            if len(scope) == 1 and len(p) >= 5 and p[4] in SIGNALS:  # top-level testbench signals only
                ids.setdefault(p[3], p[4])
        elif line.startswith("#"):
            t = int(line[1:])
        elif line and line[0] in "01xXzZ" and line[1:] in ids:
            changes.setdefault(ids[line[1:]], []).append((t * scale * 1e9, line[0]))
    return changes


def main(vcd, out):
    ch = parse_vcd(vcd)
    end = max(t for v in ch.values() for t, _ in v)
    fig, axes = plt.subplots(len(SIGNALS), 1, figsize=(12, 6.2), sharex=True)
    colors = {"red": "#d23f45", "yellow": "#d9a100", "green": "#1e8e5a"}
    for ax, name in zip(axes, SIGNALS):
        pts = ch.get(name, [])
        xs, ys = [], []
        for i, (t, v) in enumerate(pts):
            val = 1 if v == "1" else 0
            if xs:
                xs.append(t); ys.append(ys[-1])
            xs.append(t); ys.append(val)
        xs.append(end); ys.append(ys[-1])
        c = next((v for k, v in colors.items() if k in name), "#2f7db5")
        ax.step(xs, ys, where="post", color=c, lw=1.4)
        ax.set_ylim(-0.2, 1.3)
        ax.set_yticks([])
        ax.set_ylabel(name, rotation=0, ha="right", va="center", fontsize=8)
        for s in ("top", "right"):
            ax.spines[s].set_visible(False)
    axes[-1].set_xlabel("time (ns)")
    fig.suptitle("traffic_controller_tb: waveform generated from traffic_controller.vcd", fontsize=10)
    fig.tight_layout()
    fig.savefig(out, dpi=130)

    # phase timeline derived from the output signals, sampled at every change
    times = sorted({t for v in ch.values() for t, _ in v})
    def val(name, t):
        cur = "0"
        for tt, v in ch.get(name, []):
            if tt <= t:
                cur = v
            else:
                break
        return cur
    def phase(t):
        if val("ped_walk", t) == "1": return "PED WALK"
        for d in ("ns", "ew"):
            for c in ("green", "yellow"):
                if val(f"{d}_{c}", t) == "1": return f"{d.upper()} {c}"
        return "ALL RED"
    prev, start = None, 0
    print("phase timeline (ns):")
    for t in times + [end]:
        p = phase(t)
        if p != prev:
            if prev is not None:
                print(f"  {start:7.1f} - {t:7.1f}  {prev}")
            prev, start = p, t


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])

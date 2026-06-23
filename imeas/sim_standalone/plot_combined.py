#!/usr/bin/env python3
"""Combined plots for the IMEAS filter-chain scenario sweep."""
import argparse, csv, math
from collections import defaultdict
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def load(path):
    data = defaultdict(lambda: ([], []))
    with open(path) as fh:
        r = csv.DictReader(fh)
        for row in r:
            f = float(row["freq_hz"]); g = float(row["gain_db"])
            data[row["config"]][0].append(f)
            data[row["config"]][1].append(g)
    for k in data:
        fr = np.array(data[k][0]); gn = np.array(data[k][1])
        idx = np.argsort(fr)
        data[k] = (fr[idx], gn[idx])
    return data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True)
    ap.add_argument("--outdir", required=True)
    ap.add_argument("--fdec", type=float, required=True)
    args = ap.parse_args()
    d = load(args.csv)

    titles = {
        "none": "no filter (all bypass)",
        "hpf": "HPF only (~38 Hz)",
        "notch": "Notch only (50 Hz)",
        "lpf": "LPF only (125/250 Hz)",
        "hpf_notch": "HPF + Notch",
        "hpf_lpf": "HPF + LPF",
        "notch_lpf": "Notch + LPF",
        "all": "HPF + Notch + LPF",
    }

    # ---- single-filter overlay ----
    fig, ax = plt.subplots(figsize=(10, 6))
    for cfg, color in [("none", "k"), ("hpf", "tab:green"),
                       ("notch", "tab:orange"), ("lpf", "tab:blue")]:
        if cfg in d:
            fr, gn = d[cfg]
            ax.semilogx(fr, gn, "o-", ms=3, color=color, label=titles[cfg])
    ax.axhline(0, color="gray", lw=0.6)
    ax.set_title("IMEAS filter chain - individual filters (measured from RTL)")
    ax.set_xlabel("Frequency (Hz)"); ax.set_ylabel("Gain  filtered/sinc (dB)")
    ax.set_ylim(-90, 10); ax.grid(True, which="both", alpha=0.3); ax.legend()
    fig.tight_layout(); fig.savefig(f"{args.outdir}/combined_single.png", dpi=120)

    # ---- combinations overlay ----
    fig, ax = plt.subplots(figsize=(10, 6))
    for cfg, color in [("hpf_notch", "tab:purple"), ("hpf_lpf", "tab:cyan"),
                       ("notch_lpf", "tab:olive"), ("all", "tab:red")]:
        if cfg in d:
            fr, gn = d[cfg]
            ax.semilogx(fr, gn, "o-", ms=3, color=color, label=titles[cfg])
    ax.axhline(0, color="gray", lw=0.6)
    ax.set_title("IMEAS filter chain - filter combinations (measured from RTL)")
    ax.set_xlabel("Frequency (Hz)"); ax.set_ylabel("Gain  filtered/sinc (dB)")
    ax.set_ylim(-90, 10); ax.grid(True, which="both", alpha=0.3); ax.legend()
    fig.tight_layout(); fig.savefig(f"{args.outdir}/combined_combo.png", dpi=120)

    # ---- "all filters" band shape, highlighting band-pass-with-notch ----
    if "all" in d:
        fig, ax = plt.subplots(figsize=(10, 6))
        fr, gn = d["all"]
        ax.semilogx(fr, gn, "o-", ms=3, color="tab:red", label="HPF+Notch+LPF")
        ax.axhline(0, color="gray", lw=0.6)
        ax.axvline(50, color="orange", ls="--", lw=1, label="50 Hz notch")
        ax.axvline(38, color="green", ls=":", lw=1, label="~38 Hz HPF cutoff")
        ax.axvline(125, color="blue", ls=":", lw=1, label="125 Hz LPF cutoff")
        ax.set_title("All filters: 38-125 Hz band-pass with 50 Hz notch")
        ax.set_xlabel("Frequency (Hz)"); ax.set_ylabel("Gain (dB)")
        ax.set_ylim(-90, 10); ax.grid(True, which="both", alpha=0.3); ax.legend()
        fig.tight_layout(); fig.savefig(f"{args.outdir}/all_filters_band.png", dpi=120)

    print("combined plots written to", args.outdir)


if __name__ == "__main__":
    main()

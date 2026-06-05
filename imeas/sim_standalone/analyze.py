#!/usr/bin/env python3
"""Analyze tb_filter_chain output: compute the sinc->filter chain transfer
function from the captured decimated samples.

out.txt columns: idx  sinc(CIC-only)  filtered(after HPF/Notch/LPF)

The decimated 'sinc' stream is the input to the HPF/Notch/LPF chain and the
'filtered' stream is its output, so the chain magnitude response at each input
tone is  20*log10(|FFT(filtered)| / |FFT(sinc)|).
"""
import argparse, math, sys
import numpy as np


def read_out(path):
    idx, sinc, filt = [], [], []
    with open(path) as fh:
        for line in fh:
            p = line.split()
            if len(p) != 3:
                continue
            idx.append(int(p[0])); sinc.append(int(p[1])); filt.append(int(p[2]))
    return np.array(sinc, float), np.array(filt, float)


def read_tones(path):
    fs = []
    with open(path) as fh:
        for line in fh:
            p = line.split()
            if len(p) >= 1 and p[0]:
                try:
                    fs.append(float(p[0]))
                except ValueError:
                    pass
    return sorted(set(fs))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--tones", required=True)
    ap.add_argument("--fdec", type=float, required=True)
    ap.add_argument("--nfft", type=int, default=2048)
    ap.add_argument("--drop", type=int, default=400, help="settling samples to discard")
    ap.add_argument("--label", default="")
    ap.add_argument("--plot", default="", help="png path for transfer-function plot")
    ap.add_argument("--csv", default="", help="csv path to append gain table")
    args = ap.parse_args()

    sinc, filt = read_out(args.out)
    tones = read_tones(args.tones)
    binhz = args.fdec/args.nfft

    if len(sinc) < args.drop + args.nfft:
        sys.stderr.write(f"ERROR: only {len(sinc)} samples, need {args.drop+args.nfft}\n")
        sys.exit(2)

    s = sinc[args.drop:args.drop+args.nfft]
    f = filt[args.drop:args.drop+args.nfft]
    s = s - np.mean(s)
    f = f - np.mean(f)

    S = np.fft.rfft(s)
    F = np.fft.rfft(f)
    freqs = np.fft.rfftfreq(args.nfft, d=1.0/args.fdec)

    print(f"\n=== {args.label} ===")
    print(f"{'f(Hz)':>10} {'sinc(dBFS)':>11} {'filt(dBFS)':>11} {'gain(dB)':>10}")
    rows = []
    fs_full = 2**23
    for tf in tones:
        k = int(round(tf/binhz))
        if k < 1 or k >= len(freqs):
            continue
        smag = abs(S[k]) * 2 / args.nfft
        fmag = abs(F[k]) * 2 / args.nfft
        sdb = 20*math.log10(smag/fs_full + 1e-300)
        fdb = 20*math.log10(fmag/fs_full + 1e-300)
        gain = 20*math.log10((fmag + 1e-9)/(smag + 1e-9))
        print(f"{tf:10.2f} {sdb:11.2f} {fdb:11.2f} {gain:10.2f}")
        rows.append((tf, sdb, fdb, gain))

    if args.csv:
        with open(args.csv, "a") as ch:
            for tf, sdb, fdb, gain in rows:
                ch.write(f"{args.label},{tf:.3f},{sdb:.3f},{fdb:.3f},{gain:.3f}\n")

    if args.plot:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        fr = [r[0] for r in rows]
        gn = [r[3] for r in rows]
        fig, ax = plt.subplots(2, 1, figsize=(9, 7))
        ax[0].plot(fr, gn, "o-", color="tab:blue")
        ax[0].axhline(0, color="k", lw=0.6)
        ax[0].set_title(f"Chain magnitude response (filtered/sinc): {args.label}")
        ax[0].set_xlabel("Frequency (Hz)"); ax[0].set_ylabel("Gain (dB)")
        ax[0].grid(True, alpha=0.3)
        # spectra
        sspec = 20*np.log10(np.abs(S)*2/args.nfft/fs_full + 1e-12)
        fspec = 20*np.log10(np.abs(F)*2/args.nfft/fs_full + 1e-12)
        ax[1].plot(freqs, sspec, color="tab:gray", lw=0.8, label="sinc/CIC input")
        ax[1].plot(freqs, fspec, color="tab:red", lw=0.9, label="filtered output")
        ax[1].set_title("Spectra")
        ax[1].set_xlabel("Frequency (Hz)"); ax[1].set_ylabel("dBFS")
        ax[1].set_ylim(-160, 0)
        ax[1].grid(True, alpha=0.3); ax[1].legend(loc="upper right")
        fig.tight_layout()
        fig.savefig(args.plot, dpi=110)
        sys.stderr.write(f"wrote plot {args.plot}\n")


if __name__ == "__main__":
    main()

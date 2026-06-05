#!/usr/bin/env python3
"""Headline plot: input vs filtered spectra for the 4-tone bitstream test.

Shows that the sinc(CIC) output (the decimated bitstream) contains all 4 tones,
and the HPF+Notch+LPF output keeps only the in-band 80 Hz tone while removing
the 10 Hz (HPF), 50 Hz (Notch) and 300 Hz (LPF) tones.
"""
import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def spec(path, col, nfft, drop, fdec):
    d = np.loadtxt(path)
    x = d[drop:drop+nfft, col].astype(float)
    x = x - np.mean(x)
    X = np.fft.rfft(x * np.hanning(len(x)))
    f = np.fft.rfftfreq(nfft, d=1.0/fdec)
    mag = 20*np.log10(np.abs(X)*2/nfft/(2**23) + 1e-12)
    return f, mag


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--none", required=True)
    ap.add_argument("--all", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--fdec", type=float, default=1000.0)
    ap.add_argument("--nfft", type=int, default=2048)
    ap.add_argument("--drop", type=int, default=512)
    args = ap.parse_args()

    # column 1 = sinc(CIC) input to the chain (same in both runs); column 2 = filtered
    f, sinc = spec(args.none, 1, args.nfft, args.drop, args.fdec)
    _, filt = spec(args.all,  2, args.nfft, args.drop, args.fdec)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(f, sinc, color="tab:gray", lw=1.1, label="bitstream after sinc/CIC (chain input)")
    ax.plot(f, filt, color="tab:red", lw=1.2, label="after HPF+Notch+LPF (chain output)")
    for fx, txt, c in [(10, "10 Hz\n(HPF stop)", "green"),
                       (50, "50 Hz\n(Notch)", "orange"),
                       (80, "80 Hz\n(pass)", "blue"),
                       (300, "300 Hz\n(LPF stop)", "purple")]:
        ax.axvline(fx, color=c, ls="--", lw=0.8, alpha=0.7)
        ax.text(fx, 4, txt, color=c, ha="center", va="bottom", fontsize=8)
    ax.set_title("IMEAS sinc -> HPF/Notch/LPF: 4-tone bitstream is filtered as designed")
    ax.set_xlabel("Frequency (Hz)"); ax.set_ylabel("Magnitude (dBFS)")
    ax.set_xlim(0, 470); ax.set_ylim(-130, 12)
    ax.grid(True, alpha=0.3); ax.legend(loc="lower left")
    fig.tight_layout(); fig.savefig(args.out, dpi=120)
    print("wrote", args.out)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Generate a tone list (freq amp phase) for tb_filter_chain.sv.

Two modes:
  multitone : many small equal-amplitude tones spanning the band (transfer-fn probe)
  custom    : explicit list of "freq:amp" tones
"""
import argparse, math, random, sys

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="tones.txt")
    ap.add_argument("--mode", choices=["multitone", "custom"], default="multitone")
    ap.add_argument("--fdec", type=float, default=2000.0, help="decimated sample rate Hz")
    ap.add_argument("--ntone", type=int, default=40)
    ap.add_argument("--fmin", type=float, default=10.0)
    ap.add_argument("--fmax", type=float, default=None, help="default 0.47*fdec")
    ap.add_argument("--amp", type=float, default=0.012, help="per-tone amplitude (fullscale frac)")
    ap.add_argument("--nfft", type=int, default=2048, help="fft length used by analyzer")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--custom", default="", help="comma list freq:amp e.g. 60:0.3,300:0.3,820:0.3")
    args = ap.parse_args()

    fmax = args.fmax if args.fmax is not None else 0.47*args.fdec
    random.seed(args.seed)
    tones = []

    if args.mode == "multitone":
        # place tones exactly on FFT bins so they are coherent (no leakage).
        # bin spacing = fdec/nfft
        binhz = args.fdec/args.nfft
        kmin = max(1, int(round(args.fmin/binhz)))
        kmax = int(round(fmax/binhz))
        # spread ntone bins logarithmically, use odd bins to avoid harmonic overlap
        ks = []
        if args.ntone >= (kmax-kmin+1):
            ks = list(range(kmin, kmax+1))
        else:
            for i in range(args.ntone):
                frac = i/(args.ntone-1)
                k = int(round(kmin*((kmax/kmin)**frac)))
                if k not in ks:
                    ks.append(k)
        for k in ks:
            f = k*binhz
            ph = random.uniform(0, 2*math.pi)
            tones.append((f, args.amp, ph))
    else:
        binhz = args.fdec/args.nfft
        for item in args.custom.split(","):
            if not item.strip():
                continue
            fa = item.split(":")
            f = float(fa[0]); a = float(fa[1]) if len(fa) > 1 else 0.3
            # snap to nearest fft bin for coherent capture
            k = max(1, int(round(f/binhz)))
            f = k*binhz
            tones.append((f, a, random.uniform(0, 2*math.pi)))

    with open(args.out, "w") as fh:
        for f, a, p in tones:
            fh.write(f"{f:.6f} {a:.8f} {p:.8f}\n")
    sys.stderr.write(f"wrote {len(tones)} tones to {args.out} (fdec={args.fdec}, binhz={args.fdec/args.nfft:.4f})\n")
    for f, a, p in tones:
        sys.stderr.write(f"  f={f:9.3f}Hz a={a:.5f}\n")

if __name__ == "__main__":
    main()

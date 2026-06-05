#!/usr/bin/env bash
#===============================================================================
# Standalone IMEAS sinc(CIC) + HPF/Notch/LPF filter-chain test runner.
#
# Drives a 1-bit sigma-delta bitstream (multi-tone) into the real RTL and
# verifies the filtering by measuring the chain transfer function for every
# filter-enable combination.
#
# Standard config (Fdec = 1000 Hz):
#   adc_fs = 256000, DR = 5 (OSR = 256)  ->  Fdec = 1000 Hz
#   LPF  : production default coeffs   -> low-pass, Fpass=Fdec/8=125Hz, Fstop=Fdec/4=250Hz
#   Notch: production default coeffs   -> 50 Hz powerline notch
#   HPF  : coeff 0x380000              -> ~38 Hz high-pass (visible cutoff;
#                                          the production default is a ~0.008 Hz
#                                          DC-blocker, too slow to show in sim)
#===============================================================================
set -e
cd "$(dirname "$0")"

ADC_FS=256000
DR=5
FDEC=1000
NFFT=2048
NCAP=2700
DROP=512
HPFC=380000        # HPF coeff giving a visible ~38 Hz cutoff

mkdir -p results
RESCSV=results/transfer.csv
: > "$RESCSV"
echo "config,freq_hz,sinc_dbfs,filt_dbfs,gain_db" > "$RESCSV"

echo "### compiling"
iverilog -g2012 -DFPGA -o tb.vvp -s tb_filter_chain tb_filter_chain.sv -f filelist.f

echo "### generating multitone stimulus (Fdec=$FDEC, nfft=$NFFT)"
python3 gen_tones.py --out results/tones_mt.txt --mode multitone --fdec $FDEC \
        --ntone 44 --fmin 4 --fmax 470 --amp 0.011 --nfft $NFFT >/dev/null 2>&1

# config name : NOTCH_BYP LPF_BYP HPF_BYP
declare -A CFG=(
  [none]="1 1 1"
  [hpf]="1 1 0"
  [notch]="0 1 1"
  [lpf]="1 0 1"
  [hpf_notch]="0 1 0"
  [hpf_lpf]="1 0 0"
  [notch_lpf]="0 0 1"
  [all]="0 0 0"
)

ORDER="none hpf notch lpf hpf_notch hpf_lpf notch_lpf all"

for name in $ORDER; do
  read nb lb hb <<< "${CFG[$name]}"
  echo "### scenario: $name  (notch_byp=$nb lpf_byp=$lb hpf_byp=$hb)"
  vvp tb.vvp +DR=$DR +ADC_FS=$ADC_FS +NOTCH_BYP=$nb +LPF_BYP=$lb +HPF_BYP=$hb \
      +HPF_COEFF=$HPFC +NCAP=$NCAP +TONES=results/tones_mt.txt \
      +OUT=results/out_${name}.txt 2>&1 | grep -E "CONFIG|Captured" || true
  python3 analyze.py --out results/out_${name}.txt --tones results/tones_mt.txt \
      --fdec $FDEC --nfft $NFFT --drop $DROP --label $name --csv "$RESCSV" \
      --plot results/tf_${name}.png > results/report_${name}.txt 2>/dev/null
done

echo "### headline multi-tone test (10Hz HPF-stop, 50Hz notch, 80Hz pass, 300Hz LPF-stop)"
python3 gen_tones.py --out results/tones_head.txt --mode custom --fdec $FDEC \
        --nfft $NFFT --custom "10:0.18,50:0.18,80:0.18,300:0.18" >/dev/null 2>&1
for name in none all; do
  read nb lb hb <<< "${CFG[$name]}"
  vvp tb.vvp +DR=$DR +ADC_FS=$ADC_FS +NOTCH_BYP=$nb +LPF_BYP=$lb +HPF_BYP=$hb \
      +HPF_COEFF=$HPFC +NCAP=$NCAP +TONES=results/tones_head.txt \
      +OUT=results/head_${name}.txt 2>&1 | grep -E "Captured" || true
done

echo "### building combined plots"
python3 plot_combined.py --csv "$RESCSV" --outdir results --fdec $FDEC

echo "### DONE. Results in results/"

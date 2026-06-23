# IMEAS sinc(CIC) + HPF / Notch / LPF standalone testbench

Standalone, simulator-driven test of the IMEAS digital datapath:

```
1-bit SDM bitstream ─▶ imeas (sinc / CIC decimator) ─▶ HPF ─▶ Notch ─▶ LPF ─▶ out
```

It drives the **real RTL** (`imeas/rtl/filter_wrapper.sv` — the per-channel core
that `imeas_wrapper` replicates 16×) with a 1-bit sigma-delta bitstream
generated from a multi-tone analog signal, then captures the decimated output
and measures the chain's magnitude response with an FFT. This proves the sinc
decimator and the HPF/Notch/LPF actually filter the frequencies they are
designed to filter, for every combination of enabled filters.

All filter coefficients are the exact **production defaults** taken from
`spi_slave/rtl/spi_reg.sv` (`coeff_data_def` + the notch/lpf/hpf coefficient
mapping).

## Requirements

* Icarus Verilog (`iverilog`/`vvp`) 12.0+  (event-driven; needed because the
  design has several asynchronous clocks)
* Python 3 with `numpy` and `matplotlib`

## Run everything

```bash
cd imeas/sim_standalone
./run_all.sh
```

This compiles the RTL, runs all 8 filter-enable combinations plus a 4-tone
"headline" test, and writes reports/plots into `results/`.

## Key files

| File | Purpose |
|------|---------|
| `tb_filter_chain.sv` | Testbench: 2nd-order SDM bit generator + DUT + capture |
| `filelist.f`         | RTL file list for the DUT |
| `gen_tones.py`       | Generate the multi-tone / custom stimulus (tones on FFT bins) |
| `analyze.py`         | FFT of captured output, per-tone gain = filtered/sinc (dB) |
| `plot_combined.py`   | Overlay magnitude-response plots across scenarios |
| `plot_headline.py`   | Input-vs-output spectrum for the 4-tone test |
| `run_all.sh`         | One-shot driver for the whole matrix |

## Configuration (plusargs to `vvp tb.vvp`)

| Plusarg | Meaning | Default |
|---------|---------|---------|
| `+DR=<n>` | CIC decimation select, OSR = 2^(DR+3) | 5 (OSR 256) |
| `+ADC_FS=<hz>` | SDM oversample rate used for tone math | 512000 |
| `+NOTCH_BYP=<0/1>` `+LPF_BYP` `+HPF_BYP` | bypass each filter | 1 |
| `+HPF_COEFF=<hex>` | override 24-bit HPF coeff | production default |
| `+DC=<float>` | DC offset added to the SDM input | 0 |
| `+NCAP=<n>` | decimated output samples to capture | 2560 |
| `+TONES=<file>` `+OUT=<file>` | stimulus / dump paths | tones.txt / out.txt |

## Standard test point (`run_all.sh`)

`adc_fs = 256000`, `DR = 5` → **Fdec = 1000 Hz**, so the production coefficients
land at human-readable frequencies:

* **LPF** (default coeffs): low-pass, Fpass = Fdec/8 = 125 Hz, Fstop = Fdec/4 = 250 Hz.
* **Notch** (default coeffs): 50 Hz powerline notch.
* **HPF**: the production default coefficient is a ~0.008 Hz DC-blocker (per
  `imeas/rtl/Filters_manual.txt`) whose rolloff/settling are far too slow to
  show in a tractable simulation. Because the HPF coefficient is runtime
  programmable (SPI-loaded), `run_all.sh` programs `0x380000`, which exercises
  the identical HPF datapath but with a visible ~38 Hz cutoff. Note that stable
  high-pass operation requires an HPF coefficient **below** `0x400000`
  (`0x400000` itself passes DC; values above wind the DF-II state up to
  saturation).

## Measured results (from the RTL)

| Scenario | Behaviour |
|----------|-----------|
| no filter (bypass) | flat 0 dB (filtered == sinc) ✔ |
| LPF only | flat ≤125 Hz, > 70 dB rejection above ~480 Hz ✔ |
| Notch only | −53 dB null at 50 Hz, flat elsewhere ✔ |
| HPF only (`0x380000`) | 20 dB/decade high-pass, ~38 Hz cutoff ✔ |
| HPF+Notch+LPF | 38–125 Hz band-pass with a −62 dB 50 Hz notch ✔ |

4-tone headline test (10 / 50 / 80 / 300 Hz), all filters on:

| Tone | Role | Gain |
|------|------|------|
| 10 Hz | HPF stopband | −13 dB |
| 50 Hz | powerline notch | −57 dB |
| 80 Hz | passband | −0.9 dB |
| 300 Hz | LPF stopband | −91 dB |

## Note on RTL

`filter_wrapper.sv` had its `lpf_coeff_data` / `notch_coeff_data` array ports
declared unsigned while the leaf filter modules declare them `signed`. They were
made `signed` for type consistency (behaviour-neutral — the wrapper only routes
these buses) so the design elaborates under strict tools such as Icarus Verilog.

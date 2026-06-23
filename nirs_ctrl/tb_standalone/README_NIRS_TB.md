# NIRS/PPG controller — standalone testbenches & RTL-vs-README review

This folder contains **self-contained Icarus-Verilog testbenches** for the
NIRS/PPG controller RTL in `nirs_ctrl/rtl`. They were written from scratch to
exercise the features described in the main `README.md` (chapter 12
*"NIRS/PPG CONTROLLER"* and the `NIRS_*` registers in §13.15) and do **not**
depend on any of the UVM / chip-top testbenches already in the repository.

## How to run

```bash
cd nirs_ctrl/tb_standalone
./run_all.sh
```

Each testbench is self-checking and prints `RESULT: PASS` / `RESULT: FAIL`
plus a `checks=… errors=…` summary. Testbenches that compare against the
README also report `README-deviations=N` (documented spec mismatches that are
**not** counted as RTL errors, see below). The runner returns a non-zero exit
code if any testbench fails to build or reports `RESULT: FAIL`.

Tools: `iverilog`/`vvp` (Icarus Verilog 12.0). The clock-gate cell
`common_clock_gate` is compiled with `-DFPGA` so its behavioural model is used.

## Testbench coverage

| Testbench | DUT | What it verifies (README reference) |
|-----------|-----|-------------------------------------|
| `tb_nirs_ppg_subtract_dout` | `nirs_ppg_subtract_dout` | `DOUT = RATIO*DOUTC − DOUTF`; RATIO map 128/64/32/16 + manual (NIRS_CTRL_7/8); moving-average `AVG_SEL` 0,½,¾,15⁄16 (NIRS_CTRL_2) |
| `tb_nirs_ppg_idac_ctrl` | `nirs_ppg_idac_ctrl` | 9-bit IDAC hysteresis loop: ++ above `THRESHOLD_H`, −− below `THRESHOLD_L`, hold in window, forced ++ on `DOUTF==0`/`IDAC_INCREASE`, saturation 0x000/0x1FF, `IDAC_MAX`/`IDAC_MIN` flags, manual mode (NIRS_CTRL_2..6) |
| `tb_nirs_ppg_int` | `nirs_ppg_int` | `NIRS_CTRL_INT` per-source masking, `INT_IO` gate (NIRS_INT_PIN_EN), `INT_LENGTH_SLCT` level vs pulse, interrupt clear |
| `tb_nirs_ppg_pulse_ctrl` | `nirs_ppg_pulse_ctrl` | PERIOD/OTS/RESET/LED_STABLE/LED_OFF duration tables (Tables 12.1.3.x, NIRS_CTRL_0/1); RESET→Td→IPD_SW→LED sequencing (Fig 12.1.3); DUAL/SINGLE/AMBIENT LED flashing (NIRS_CTRL_MODE) |
| `tb_nirs_ppg_ctrl` | `nirs_ppg_ctrl` | coarse/fine measurement FSM, counter enables, DOUTC/DOUTF latch + DOUT_EN, `DATA_READY`, `EN_OFF`, and the four IREF anomaly flags |
| `tb_nirs_ppg_cmd` | `nirs_ppg_cmd` (+clk/gate) | `NIRS_CTRL_CMD` decode HOLD/START/MEAS/STOP, clock gating start/stop/resume, `NIRS_SINGLE` single-shot |
| `tb_nirs_ppg_ctrl_top` | `nirs_ppg_ctrl_top` | **end-to-end**: pulse-gen → FSM → counters → DOUT compute → IDAC loop → interrupt, with a behavioural dual-slope analog model. Checks `DOUT==128*DOUTC−DOUTF`, IDAC auto-increment, manual IDAC |

Current status: **all 7 build and pass** (`errors=0`), with 2 testbenches
reporting documented README deviations described next.

## RTL ↔ README mismatches found

These are **functional differences between the RTL and the README**. The RTL
is internally self-consistent, so the testbenches treat them as documentation
deviations (`README-deviations`) rather than RTL errors — but one side needs to
be corrected.

### 1. `LED_OFF_CTRL` duration table is reversed
*RTL* `nirs_ppg_pulse_ctrl.v` (`t_off_led` mux):

| code | RTL | README NIRS_CTRL_1 (13.15.4) |
|------|-----|------------------------------|
| 0 | **5 µs** | 2 µs |
| 1 | **4 µs** | 3 µs |
| 2 | **3 µs** | 4 µs |
| 3 | **2 µs** | 5 µs |

The mapping is exactly inverted. (`tb_nirs_ppg_pulse_ctrl` reports 4 deviations.)
All other duration tables — PERIOD, OTS/ON_TIME, RESET, LED_STABLE — match the
README exactly.

### 2. IREF-coarse interrupt-enable bits 2/3 are swapped
*RTL* `nirs_ppg_int.v` (`INT_tmp`):

| `NIRS_CTRL_INT` bit | RTL enables | README §13.15.13 |
|---------------------|-------------|------------------|
| bit 2 | `IREF_COARSE_ON_NOT_OFF` | `IREF_COARSE_NOT_ON_EN` |
| bit 3 | `IREF_COARSE_NOT_ON`     | `IREF_COARSE_ON_NOT_OFF_EN` |

The two coarse-flag interrupt enables are swapped relative to the README.
The fine-flag enables (bit 4 = `FINE_NOT_ON`, bit 5 = `FINE_ON_NOT_OFF`) **do**
match. Note also that the RTL's own `NIRS_DEBUG_4` packing
(`nirs_ppg_wrapper.sv`) uses bit 3 = `COARSE_ON_NOT_OFF`, bit 2 =
`COARSE_NOT_ON` — i.e. it agrees with the README and therefore *disagrees with
the interrupt mask*, so this is an internal inconsistency as well.
(`tb_nirs_ppg_int` reports 2 deviations and prints the actual RTL binding.)

### 3. Ambient SINGLE/DUAL description (documentation only)
README §13.15.12 describes the ambient sub-modes under
`NIRS_PGG_LED_SINGLE_EN`, but the text for `SINGLE_EN=0` and `SINGLE_EN=1`
appears swapped relative to the RTL (`nirs_ppg_pulse_ctrl.v` `LED_d` FSM):
the RTL produces the 4-phase `LED0→AMB0→LED1→AMB1` sequence in **DUAL** ambient
mode and the 2-phase `LED0→AMB0` sequence in **SINGLE** ambient mode. The
testbench observes and prints the actual sequence (4-phase confirmed in dual
ambient). This is a wording issue, not an RTL bug.

## Feature comparison vs commercial NIRS/PPG AFEs

Reference parts: TI **AFE4404/AFE4900**, Maxim **MAX86141**, ADI
**ADPD4101/ADPD188**. The ENS2 NIRS controller implements the digital
front-end control found in those devices:

| Capability | Commercial AFEs | ENS2 NIRS RTL | Where |
|------------|-----------------|---------------|-------|
| Multi-channel, multi-LED time-multiplex | yes | **yes** – 8 channels × 2 LEDs | `nirs_ppg_wrapper.sv` (`NO_OF_NIRS=8`) |
| Programmable LED on-time / sample period | yes | **yes** – OTS 1–50 µs, PERIOD 125 µs–22 ms | `nirs_ppg_pulse_ctrl.v` |
| LED settle / off / reset timing | yes | **yes** – LED_STABLE, LED_OFF, RESET, Td | `nirs_ppg_pulse_ctrl.v` |
| PD/SiPM current-mode quantization (ADC) | yes (ΔΣ/SAR) | **yes** – dual-slope coarse+fine counters | `nirs_ppg_ctrl.v`, `nirs_ppg_counter.v` |
| Ambient-light sampling & subtraction | yes | **yes** – ambient LED phases + `RATIO*DOUTC−DOUTF` | `nirs_ppg_subtract_dout.v`, `LED_d` FSM |
| Ambient/offset cancellation DAC w/ auto loop | yes (AFE offset DAC) | **yes** – 9-bit IDAC hysteresis loop w/ H/L thresholds | `nirs_ppg_idac_ctrl.v` |
| Programmable gain / reference scaling | yes (TIA gain) | **partial** – IPDMIRROR_ADJ, IREFC_ADJ, coarse:fine RATIO | wrapper / pulse paths |
| Moving-average / decimation | yes | **partial** – 1/2/4/16 IIR moving average; no FIR/decimator | `nirs_ppg_subtract_dout.v` |
| Chopper stabilization | some | **yes** – CHOPPER_EN, FCHOP_ADJ | wrapper `NIRS_CTRL_ADJ` |
| Data-ready / threshold / fault interrupts | yes | **yes** – DATA_READY, IDAC max/min, IREF anomalies, INT pin | `nirs_ppg_int.v` |
| Clock management / power gating | yes | **yes** – command-driven clock gating | `nirs_ppg_cmd.v`, `nirs_ppg_clk.v` |
| **Internal LED driver** | yes | **no (by design)** – README: *"ENS2 doesn't have internal LED Driver"*; only `LED_ON` timing is generated | — |
| **Result FIFO / buffering** | yes | **no** – results exposed via SPI `NIRS_DOUT`/`NIRS_DEBUG` regs | wrapper |
| On-chip SpO₂/HR/proximity/dark modes | some | **no** | — |
| Programmable multi-stage TIA gain | yes | **no** (only mirror-ratio scaling) | — |

**Summary:** the module covers the core control/measurement functions of a
commercial NIRS/PPG AFE — multi-channel LED sequencing, current-mode dual-slope
acquisition, ambient subtraction, an automatic ambient/offset cancellation DAC
loop, chopping, configurable timing/averaging, and a rich interrupt set. The
notable omissions relative to commercial parts are the **internal LED driver**
(explicitly external for ENS2), a **result FIFO**, and higher-level on-chip
biometric computation — all architectural choices rather than defects.

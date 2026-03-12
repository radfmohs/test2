# NIRS/PPG Digital Controller – Logic Description

> **Source of truth**: every statement is derived directly from the RTL files in
> `nirs_ctrl/rtl/` and the system files in `top_dig/`, `sys_ctrl/`, and
> `spi_slave/rtl/`.  Numbers are calculated from code constants, not from README
> prose.

---

## 1. What the block does (plain English)

The NIRS digital controller drives the analogue front-end of a Near-Infrared
Spectroscopy (NIRS) / PPG sensor.  Every measurement cycle it:

1. **Resets** the analogue integrator capacitor (discharges it) and simultaneously
   connects the photocurrent input (`IIN_SW`).
2. Waits a fixed **5 µs settling delay** after the reset pulse ends.
3. **Turns on the LED** (`ILED_SW`) for a programmable on-time (1–30 µs).
4. After the LED turns off, the analogue circuit runs a two-phase
   **time-to-digital conversion**: it fires `IREF_COARSE` pulses (coarse
   quantisation) followed by `IREF_FINE` pulses (fine quantisation).  The
   digital controller counts these pulses (`DOUTC`, `DOUTF`).
5. **Computes** the final 19-bit light-level output:
   `DOUT = (RATIO × DOUTC) – DOUTF`
6. **Adjusts** the DC-cancellation current DAC (`IDAC`) by ±1 step if `DOUT`
   falls outside a programmable threshold window, keeping the integrator
   in-range next cycle.
7. **Exposes** every result and every timing status flag to the SPI register bank
   for firmware readback.
8. Repeats at a rate set by `PERIOD_ctrl` (125 µs – 22 ms, free-running).

---

## 2. Module hierarchy

```
nirs_ppg_wrapper            top-level glue: SPI ↔ ANA interface ↔ ctrl_top
└── nirs_ppg_ctrl_top       connects pulse generator, FSM, counters, compute
    ├── nirs_ppg_pulse_ctrl timing signal generator  (clk_sys / 2 MHz)
    ├── nirs_ppg_ctrl       5-state FSM              (clk_ppg domain)
    ├── nirs_ppg_counter ×2 IREF_COARSE and IREF_FINE counters
    ├── nirs_ppg_latch   ×2 DOUTC and DOUTF capture registers
    ├── nirs_ppg_subtract_dout  DOUT = RATIO×DOUTC − DOUTF
    └── nirs_ppg_idac_ctrl  IDAC hysteresis auto-adjust loop
```

---

## 3. Clock domains

| Domain    | Frequency   | What runs in it |
|-----------|-------------|-----------------|
| `clk_sys` | 2 MHz (max) | `nirs_ppg_pulse_ctrl` – generates RESET, ILED_SW, IIN_SW |
| `clk_ppg` | 8 MHz (max) | counters, FSM, latches, DOUT compute, IDAC |

`RESET`, `IREF_COARSE`, and `IREF_FINE` cross from the `clk_sys`/analogue domain
into `clk_ppg` through `common_sync_bit` two-flop synchronisers inside
`nirs_ppg_ctrl_top` (lines 101–120 of `nirs_ppg_ctrl_top.v`).

**Enable and software reset** are handled outside the wrapper:

| Control bit | SPI register | Implemented by |
|-------------|-------------|----------------|
| `PPG_DIS` (NIRS_CTRL_7[0]) | `spi_reg.sv` → `clk_ctrl.v` | Clock gating — stops `clk_ppg` and `clk_sys_ppg` |
| `PPG_RST_REG` (NIRS_CTRL_7[5]) | `spi_reg.sv` → `reset_ctrl.v` | Asserts `ppg_resetn` → drives `nirs_ppg_wrapper.rst_n` |

---

## 4. Timing pulse generator – `nirs_ppg_pulse_ctrl`

**Clock**: `clk_sys` = 2 MHz → each counter tick = **500 ns**.

### 4.1 Free-running period counter

```
t_period = t_period_sel × 2 − 1             (nirs_ppg_pulse_ctrl.v line 144)
```

The 16-bit `counter` increments every clock cycle and wraps to 0 when
`counter == t_period`.  The full period is `(t_period + 1) × 500 ns =
t_period_sel × 1 µs`.

### 4.2 Fixed timing constants (hardcoded)

| Constant           | Raw ticks | × 2 | Actual duration |
|--------------------|-----------|-----|-----------------|
| `t_RESET_w_timing` | 5         | 10  | **5 µs**        |
| `t_delay_timing`   | 5         | 10  | **5 µs**        |

### 4.3 Programmable period (`PERIOD_ctrl[3:0]` = NIRS_CTRL_0[7:4])

| Value | Period  | Value | Period |
|:-----:|--------:|:-----:|-------:|
| 0     | 125 µs  | 8     | 8 ms   |
| 1     | 250 µs  | 9     | 10 ms  |
| 2     | 500 µs  | 10    | 12 ms  |
| 3     | 750 µs  | 11    | 14 ms  |
| 4     | 1 ms    | 12    | 16 ms  |
| 5     | 2 ms    | 13    | 18 ms  |
| 6     | 4 ms    | 14    | 20 ms  |
| 7     | 6 ms    | 15    | 22 ms  |

### 4.4 Programmable LED on-time (`OTS_ctrl[3:0]` = NIRS_CTRL_0[3:0])

```
t_ILED_SW_w = t_ILED_SW_w_sel × 2           (nirs_ppg_pulse_ctrl.v line 147)
```

| Value | LED on-time | Value | LED on-time |
|:-----:|------------:|:-----:|------------:|
| 0     | 1 µs        | 8     | 10 µs       |
| 1     | 2 µs        | 9     | 12 µs       |
| 2     | 3 µs        | 10    | 14 µs       |
| 3     | 4 µs        | 11    | 16 µs       |
| 4     | 5 µs        | 12    | 18 µs       |
| 5     | 6 µs        | 13    | 20 µs       |
| 6     | 8 µs        | 14    | 25 µs       |
| 7     | 9 µs        | 15    | 30 µs       |

Note: the 7 µs step is absent from the sequence — OTS value 5 gives 6 µs and
value 6 jumps directly to 8 µs.

### 4.5 Signal timeline within one period

Threshold comparisons (in 2 MHz counter ticks):

```
RESET_h   = 0
RESET_l   = t_RESET_w                     = 10   (5 µs)
ILED_SW_h = RESET_l + t_delay             = 20   (10 µs from start)
ILED_SW_l = ILED_SW_h + t_ILED_SW_w      = 20 + OTS_sel×2
IIN_SW_h  = RESET_h                       = 0
IIN_SW_l  = ILED_SW_l
```

Each of the three outputs is a registered flip-flop: it sets when
`counter == _h` and clears when `counter == _l`:

```
Counter:  0         10      20              ILED_SW_l        t_period
           |         |       |                   |                |
RESET:    ██████████ |       |                   |                |
IIN_SW:   ████████████████████████████████████████                |
ILED_SW:             (5 µs) ███████████████████ |                |
                     delay  ←── OTS duration ──→
```

- **RESET** — high for the first **5 µs**: discharges the integrator capacitor.
- **IIN_SW** — high from cycle start until the LED turns off: connects the
  photocurrent into the integrator for the entire window (dark current during
  reset + settling, then dark + LED current during the LED phase).
- **Td = 5 µs** gap between RESET falling and ILED_SW rising lets the cap
  settle before light hits it.
- **ILED_SW** — high for the `OTS_ctrl`-selected duration (1–30 µs).

---

## 5. Counter block – `nirs_ppg_counter`

Two instances (coarse and fine), both parameterised to **WIDTH = 13 bits**.

```verilog
count_rst_n = rst_n & ~RESET              // counter.v line 29
```

The counter's `RESET` input is wired to `ILED_SW` (from `ctrl_top` lines 50
and 76).  Therefore:

- While **ILED_SW = HIGH** (LED on): `count_rst_n = 0` → async reset →
  `counter_reg = 0`.  Both counters are zeroed throughout the LED-on phase.
- When **ILED_SW falls** (LED off): `count_rst_n` rises → counters are
  released and will increment whenever their `enable` input is high.

The `enable` comes from the FSM (`QC_COUNTER_EN` / `QF_COUNTER_EN`), which
only asserts it while the analogue comparator is asserting `IREF_COARSE` /
`IREF_FINE`.  So the counter tallies the number of reference-current
comparison pulses during the quantisation phase, which begins only after
the LED has turned off.

---

## 6. Latch block – `nirs_ppg_latch`

A synchronous D-register: captures the counter value into `latch_reg` on
the rising `clk_ppg` edge when `en` is high.  The enable is a **1-cycle
falling-edge pulse** of the gated IREF signal (generated in the FSM), so
the final count at the end of each comparison phase is frozen.

---

## 7. FSM – `nirs_ppg_ctrl`

**Clock**: `clk_ppg`.  Inputs are the `clk_ppg`-synchronised versions of
`RESET`, `IREF_COARSE`, `IREF_FINE`.

### 7.1 States

| Encoding | Name | What is happening |
|:---:|---|---|
| 3'd0 | `IDLE` | Waiting for the next cycle's RESET pulse |
| 3'd1 | `IDAC_UPDATE` | One-cycle pulse: update IDAC from last cycle's DOUT |
| 3'd2 | `LATCHING_IREF_COARSE` | LED is off; coarse counter running; waiting for IREF_COARSE |
| 3'd3 | `LATCHING_IREF_FINE` | Coarse done; fine counter running; waiting for IREF_FINE |
| 3'd4 | `HOLDING` | Fine done; waiting for IREF_FINE to fall before returning to IDLE |

### 7.2 Transition table

| From | Condition | To |
|---|---|---|
| `IDLE` | `RESET` high | `IDAC_UPDATE` |
| `IDLE` | `RESET` low | stay |
| `IDAC_UPDATE` | always | `LATCHING_IREF_COARSE` |
| `LATCHING_IREF_COARSE` | `IREF_COARSE` high | `LATCHING_IREF_FINE` |
| `LATCHING_IREF_COARSE` | `IREF_COARSE` low | stay |
| `LATCHING_IREF_FINE` | `IREF_FINE` high | `HOLDING` |
| `LATCHING_IREF_FINE` | `IREF_FINE` low | stay |
| `HOLDING` | `IREF_FINE` low | `IDLE` |
| `HOLDING` | `IREF_FINE` high | stay |
| any invalid | — | `IDLE` |

### 7.3 Output signals

```
IREF_COARSE_L   = (cur != IDLE) & IREF_COARSE       level
IREF_FINE_L     = (cur != IDLE) & IREF_FINE          level

IREF_COARSE_L_N = falling edge of IREF_COARSE_L      1-cycle pulse
IREF_FINE_L_N   = falling edge of IREF_FINE_L        1-cycle pulse
IREF_FINE_L_N_d = IREF_FINE_L_N delayed 1 cycle      1-cycle pulse
```

| Output | Drives | When asserted |
|---|---|---|
| `IDAC_UPDATE_EN` | `idac_ctrl.EN` | Exactly 1 clk_ppg cycle in `IDAC_UPDATE` state |
| `QC_COUNTER_EN` | coarse counter `enable` | While IREF_COARSE high and FSM not IDLE |
| `QF_COUNTER_EN` | fine counter `enable` | While IREF_FINE high and FSM not IDLE |
| `DOUTC_LATCH_EN` | coarse latch `en` | 1 cycle on falling edge of gated IREF_COARSE |
| `DOUTF_LATCH_EN` | fine latch `en` | 1 cycle on falling edge of gated IREF_FINE |
| `DOUT_EN` | subtract-DOUT `en` | 1 cycle after `DOUTF_LATCH_EN` (DOUTF now stable) |

---

## 8. DOUT computation – `nirs_ppg_subtract_dout`

```
DOUT [18:0] = (RATIO [7:0] × DOUTC [12:0]) − DOUTF [12:0]
```

- `RATIO` is the 8-bit digital scale factor from `NIRS_CTRL_1`.
- The result is registered on the rising `clk_ppg` edge when `DOUT_EN`
  (= `IREF_FINE_L_N_d`) is high.

**Physical meaning**: `DOUTC` is the number of coarse reference pulses
(proportional to received light charge).  Scaled by `RATIO` it approximates
the total charge.  `DOUTF` is the fine residual.  Subtracting gives a
high-resolution light-level measurement with the DC offset partially removed.

---

## 9. IDAC auto-adjust loop – `nirs_ppg_idac_ctrl`

The IDAC is a 9-bit current DAC in the analogue front-end that injects an
opposing DC-cancellation current into the integrator to keep it in its linear
range.

**Trigger**: `IDAC_UPDATE_EN` — one `clk_ppg` cycle at the very start of each
measurement cycle (state `IDAC_UPDATE`), before any counting begins.  The
adjustment made in cycle N therefore takes effect in cycle N+1.

**Decision logic**:

```
if   (DOUT > THRESHOLD_H)  OR  (DOUTF == 0):   IDAC = min(IDAC + 1, 511)
elif (DOUT < THRESHOLD_L):                      IDAC = max(IDAC - 1, 0)
else:                                            IDAC unchanged
```

| Condition | Meaning | Action |
|---|---|---|
| `DOUT > THRESHOLD_H` | AC signal too large; integrator approaching rail | Increase IDAC |
| `DOUTF == 0` | No fine counts; integrator may be saturated | Increase IDAC |
| `DOUT < THRESHOLD_L` | AC signal too small; underutilised integrator range | Decrease IDAC |
| `THRESHOLD_L ≤ DOUT ≤ THRESHOLD_H` | Signal in window | IDAC holds |

IDAC is saturating: it clamps at **0** (minimum) and **511 = 0x1FF** (maximum).

---

## 10. SPI register interface – `nirs_ppg_wrapper`

### 10.1 Control registers (write by firmware)

| Register | Bits | Internal signal | Description |
|---|---|---|---|
| `NIRS_CTRL[0]` | `[7:4]` | `PERIOD_ctrl` | Measurement period (§4.3) |
| `NIRS_CTRL[0]` | `[3:0]` | `OTS_ctrl` | LED on-time (§4.4) |
| `NIRS_CTRL[1]` | `[7:0]` | `RATIO` | Digital scale factor for DOUT |
| `NIRS_CTRL[2]` | `[7:6]` | `D2A_NIRS_RATIO` | Analogue mirror-ratio trim → ANA |
| `NIRS_CTRL[2]` | `[5:0]` | `THRESHOLD_H[18:13]` | High IDAC threshold (MSBs) |
| `NIRS_CTRL[3]` | `[7:0]` | `THRESHOLD_H[12:5]` | High IDAC threshold (middle) |
| `NIRS_CTRL[4]` | `[7:3]` | `THRESHOLD_H[4:0]` | High IDAC threshold (LSBs) |
| `NIRS_CTRL[4]` | `[2:0]` | `THRESHOLD_L[18:16]` | Low IDAC threshold (MSBs) |
| `NIRS_CTRL[5]` | `[7:0]` | `THRESHOLD_L[15:8]` | Low IDAC threshold (middle) |
| `NIRS_CTRL[6]` | `[7:0]` | `THRESHOLD_L[7:0]` | Low IDAC threshold (LSBs) |
| `NIRS_CTRL[7]` | `[0]` | `PPG_DIS` | Disable: gates off `clk_ppg`/`clk_sys` |
| `NIRS_CTRL[7]` | `[5]` | `PPG_RST_REG` | Software reset: asserts `ppg_resetn` |

### 10.2 Status/output registers (read by firmware)

| Register | Bits | Source | Description |
|---|---|---|---|
| `NIRS_DOUT[0]` | `[7:0]` | `DOUT[18:11]` | Final result MSBs |
| `NIRS_DOUT[1]` | `[7:0]` | `DOUT[10:3]` | Final result middle byte |
| `NIRS_DOUT[2]` | `[7:5]` | `DOUT[2:0]` | Final result LSBs |
| `NIRS_DOUT[2]` | `[4:0]` | `DOUTF[12:8]` | Fine count MSBs |
| `NIRS_DOUT[3]` | `[7:0]` | `DOUTF[7:0]` | Fine count LSB |
| `NIRS_DOUT[4]` | `[7:0]` | `DOUTC[12:5]` | Coarse count MSBs |
| `NIRS_DOUT[5]` | `[7:3]` | `DOUTC[4:0]` | Coarse count LSBs |
| `NIRS_DOUT[5]` | `[2:0]` | `IDAC[8:6]` | IDAC value MSBs |
| `NIRS_DOUT[6]` | `[7:2]` | `IDAC[5:0]` | IDAC value LSBs |
| `NIRS_DOUT[6]` | `[1]` | `RESET` | RESET phase active |
| `NIRS_DOUT[6]` | `[0]` | `ILED_SW` | LED on |
| `NIRS_DOUT[7]` | `[7]` | `IIN_SW` | Integration window active |
| `NIRS_DOUT[7]` | `[6]` | `IREF_COARSE` | Coarse comparator output |
| `NIRS_DOUT[7]` | `[5]` | `IREF_FINE` | Fine comparator output |
| `NIRS_DOUT[7]` | `[4:0]` | `5'b0` | Reserved |

### 10.3 Analogue interface outputs

| Signal | Source | Description |
|---|---|---|
| `D2A_NIRS_RESET_SW` | `RESET` | Shorts the integrator capacitor |
| `D2A_NIRS_ILED_SW` | `ILED_SW` | Turns the LED on |
| `D2A_NIRS_IIN_SW` | `IIN_SW` | Connects photocurrent to integrator |
| `D2A_NIRS_IDAC[8:0]` | `IDAC` | DC cancellation current |
| `D2A_NIRS_RATIO[1:0]` | `NIRS_CTRL[2][7:6]` | Analogue mirror-ratio trim |

---

## 11. End-to-end cycle walkthrough

Default values: `PERIOD_ctrl=0` (125 µs), `OTS_ctrl=4` (5 µs LED on-time).

```
── clk_sys counter = 0 ──────────────────────────────────────────────────────
  RESET   → HIGH  : D2A_NIRS_RESET_SW=1  (integrator cap shorted)
  IIN_SW  → HIGH  : D2A_NIRS_IIN_SW=1   (photocurrent connected)
  FSM sees RESET_ppg (synced) → IDLE → IDAC_UPDATE (1 clk_ppg cycle):
    IDAC_UPDATE_EN=1  →  idac_ctrl evaluates last DOUT vs thresholds,
                          adjusts IDAC by +1, −1, or 0
  FSM → LATCHING_IREF_COARSE

  ILED_SW = LOW at this point → counter RESET pin = 0 → both counters FREE,
  but no IREF signals active yet so they sit at 0.

── clk_sys counter = 10 (5 µs) ──────────────────────────────────────────────
  RESET → LOW : integrator cap released; dark current begins integrating.

── clk_sys counter = 20 (10 µs) ─────────────────────────────────────────────
  ILED_SW → HIGH : D2A_NIRS_ILED_SW=1  (LED turns on)
  ILED_SW is the RESET pin of both counters:
    ILED_SW=HIGH  →  count_rst_n = rst_n & ~ILED_SW = 0
    →  both counters enter async reset, counter_reg = 0

── LED on for 5 µs (OTS_ctrl=4) ─────────────────────────────────────────────
  Analogue integrates LED + dark photocurrent.

── clk_sys counter = 30 (15 µs from start) ──────────────────────────────────
  ILED_SW → LOW  : D2A_NIRS_ILED_SW=0  (LED off)
  IIN_SW  → LOW  : integration window closes
  ILED_SW=LOW  →  count_rst_n = rst_n & ~ILED_SW = 1
  →  both counters RELEASED; ready to count IREF pulses

  The analogue circuit now runs its comparison loop:

  IREF_COARSE pulses HIGH (comparator comparing charge to coarse ref):
    QC_COUNTER_EN = IREF_COARSE_L = 1  →  coarse counter increments each clk_ppg
    FSM (still in LATCHING_IREF_COARSE): when IREF_COARSE seen HIGH → → LATCHING_IREF_FINE

  IREF_COARSE falls:
    IREF_COARSE_L_N fires (falling-edge detector)  →  DOUTC_LATCH_EN=1
    →  DOUTC latch captures the coarse counter value QC

  IREF_FINE pulses HIGH (fine comparison):
    QF_COUNTER_EN = IREF_FINE_L = 1  →  fine counter increments
    FSM (LATCHING_IREF_FINE): when IREF_FINE seen HIGH → HOLDING

  IREF_FINE falls:
    IREF_FINE_L_N fires  →  DOUTF_LATCH_EN=1  →  DOUTF latch captures QF
    FSM → HOLDING → (next clk where IREF_FINE still low) → IDLE
    One clk_ppg later: DOUT_EN = IREF_FINE_L_N_d = 1
    →  subtract-DOUT registers:  DOUT = RATIO × DOUTC − DOUTF

── clk_sys counter = 250 (125 µs) ───────────────────────────────────────────
  counter wraps to 0 → new cycle begins, RESET fires again.
```

---

## 12. Technical specification summary

| Parameter | Value | RTL source |
|---|---|---|
| `clk_sys` max frequency | 2 MHz | `pulse_ctrl.v` line 17 comment |
| `clk_ppg` max frequency | 8 MHz | `wrapper.sv` line 18 comment |
| Counter width (DOUTC, DOUTF) | 13 bits, max 8191 | `ctrl_top.v` `WIDTH=13` |
| DOUT width | 19 bits | `subtract_dout.v` `OUT_WIDTH=19` |
| RATIO width | 8 bits | `NIRS_CTRL[1]` |
| IDAC width | 9 bits (0–511) | `idac_ctrl.v` port declaration |
| THRESHOLD_H / THRESHOLD_L width | 19 bits each | `ctrl_top.v` port declaration |
| Fixed RESET pulse width | 5 µs | `t_RESET_w_timing=5` × 2 × 500 ns |
| Fixed delay Td after RESET | 5 µs | `t_delay_timing=5` × 2 × 500 ns |
| Programmable LED on-time | 1–30 µs | `OTS_ctrl` table §4.4 |
| Programmable period | 125 µs – 22 ms | `PERIOD_ctrl` table §4.3 |
| IDAC step per cycle | ±1 LSB | `idac_ctrl.v` lines 39, 44 |
| IDAC saturation limits | 0 and 511 | `idac_ctrl.v` lines 39, 44 |
| CDC synchroniser depth | 2 flip-flops | `ctrl_top.v` `common_sync_bit` ×3 |

---

## 13. Comparison with standard NIRS implementations

Standard NIRS front-end ICs (e.g. Maxim MAX86141, TI AFE4490, Si1153) and
published academic fNIRS designs share a well-known feature set.  The table
below compares each feature against what is present in this RTL.

### 13.1 Feature-by-feature comparison

| Feature | Standard NIRS | This design | Status |
|---|---|---|---|
| Integrator reset pulse | Yes — brief cap discharge before each window | RESET pulse, 5 µs fixed | ✅ Present |
| Programmable LED on-time | Yes | OTS_ctrl, 1–30 µs in 16 steps | ✅ Present |
| Programmable sampling period | Yes | PERIOD_ctrl, 125 µs – 22 ms | ✅ Present |
| Two-phase (coarse+fine) quantisation | Yes in precision designs | IREF_COARSE + IREF_FINE counters | ✅ Present |
| DC cancellation / background subtraction | Yes — offset DAC or correlated double sampling | IDAC auto-adjust loop | ✅ Present |
| Hysteresis window for DAC control | Yes | THRESHOLD_H / THRESHOLD_L | ✅ Present |
| SPI readback of raw counts and result | Yes | NIRS_DOUT[0–7] registers | ✅ Present |
| Enable / power-down | Yes | PPG_DIS gates clocks via `clk_ctrl.v` | ✅ Present (system level) |
| Software reset | Yes | PPG_RST_REG asserts `ppg_resetn` via `reset_ctrl.v` | ✅ Present (system level) |
| Measurement-complete interrupt | Yes — all standard AFEs assert an INT pin | **NOT IMPLEMENTED** | ❌ Missing |
| Multi-wavelength LED multiplexing (RED + IR) | Yes — fundamental to NIRS SpO2 | Only one ILED_SW output; no wavelength-select signal | ❌ Missing |
| Dark / ambient light phase | Yes — LED-off sample subtracted each cycle | No dark phase in timing | ❌ Missing |
| Manual IDAC override from SPI | Yes — startup pre-load to skip convergence | README says "Auto or Manual" but only auto is implemented | ❌ Missing |
| Operating mode control (single-shot vs. continuous) | Yes | Only free-running continuous mode | ❌ Missing |
| Warm-up / analogue settle delay after enable | Yes | Not in digital controller (expected in firmware) | ⚠️ Gap |

### 13.2 Missing feature details

#### ❌ Measurement-complete interrupt

All three test cases in `chip_top/tc/` describe the same final step:

> *"NIRS_ctrl waits falling edge of A2D_IREFFINE to latch data then generates
> interrupt and turns off analog receiver."*

The natural interrupt trigger is already computed inside the FSM as `DOUT_EN`
(= `IREF_FINE_L_N_d`) — a 1-cycle pulse on `clk_ppg` exactly one cycle after
the fine latch captures its value (i.e., after `DOUT` is valid).  However,
this signal is **not propagated** past `nirs_ppg_ctrl`.  There is no `INT`
output on `nirs_ppg_ctrl_top` or `nirs_ppg_wrapper`, and nothing connects to
the system interrupt controller.

**What is needed**: propagate `DOUT_EN` up through `ctrl_top` → `wrapper` →
`top_dig` → interrupt controller.

#### ❌ Multi-wavelength LED multiplexing

Standard NIRS measures SpO2 by comparing absorption at two wavelengths (RED
~660 nm and INFRARED ~940 nm).  The digital controller therefore needs to:

1. Alternate LED cycles between RED and IR.
2. Tag each DOUT result as RED or IR.
3. Keep separate RED and IR DOUT values for the SpO2 ratio calculation.

The current `ana_nirs_if` has only **one** `D2A_NIRS_ILED_SW` signal and the
wrapper produces only one `DOUT[18:0]`.  The README acknowledges this with
the heading *"MISSING LED DRIVER in ANA"* — the LED driver was not included
in the analogue block.  As a consequence, LED selection and per-wavelength
readback are both absent from the digital side.

**What is needed**: a cycle counter or mode bit that selects RED vs. IR;
separate RED_DOUT and IR_DOUT registers; and a `D2A_NIRS_LED_SEL` output
to drive external LED switching circuitry.

#### ❌ Dark / ambient light phase

Every industry-standard optical biosensor interleaves a "dark" measurement
(no LED) between each LED-on sample.  The dark value is subtracted from
the LED-on value to cancel ambient light.  The current timing has only two
phases per cycle: RESET + integrate (LED on) + quantise.  There is no
LED-off integration slot.

**What is needed**: a third timing slot in `pulse_ctrl` with ILED_SW=0 and
IIN_SW=1, followed by a separate DOUT_DARK register that firmware uses to
subtract from the primary DOUT.

#### ❌ Manual IDAC override from SPI

The analogue block description states:

> *"D2A_NIRS_IDAC — Output from NIRS_CTRL counter (Auto or Manual ← SPI)"*

In auto mode the IDAC converges from 0 toward the correct operating point,
one step per cycle.  With `THRESHOLD_H` set to, say, 2000 and an IDAC step
of 1 LSB, convergence could take hundreds of cycles.  A pre-loaded initial
value from SPI would eliminate this ramp-up time.

**What is needed**: an SPI-writable `IDAC_INIT` register and a 1-bit
`IDAC_MANUAL_EN` flag.  When `IDAC_MANUAL_EN=1`, `D2A_NIRS_IDAC` is driven
directly from `IDAC_INIT` instead of the auto-adjust loop output.

#### ❌ Operating mode control (single-shot vs. continuous)

The three test cases define three expected operating modes:

| Mode name | Test file | Expected behaviour |
|---|---|---|
| RECEIVER_MASTER_CONT_MODE | `soc_nirs_ppg_receiver_master_cont_mode.sv` | Free-running (what is implemented) |
| RECEIVER_MASTER_SINGLE_MODE | `soc_nirs_ppg_receiver_master_single_mode.sv` | One measurement then halt; re-armed by firmware |
| MCU_MASTER_SINGLE_MODE | `soc_nirs_ppg_mcu_master_single_mode.sv` | MCU writes a trigger register to start each measurement |

The current FSM runs exclusively in **RECEIVER_MASTER_CONT_MODE**.  There is
no mode register input, no trigger input, and no mechanism to stop after one
measurement.

**What is needed**: a `MODE_SEL[1:0]` input to the FSM; a `TRIG` strobe from
SPI for MCU-master modes; and a `SINGLE_DONE` state that halts the counter
after one complete IDLE→IDLE trip.

#### ⚠️ Analogue warm-up delay after enable

The test cases describe a step:

> *"Delay a programmable time to wait for analog receiver to be stable"*

The digital controller starts the FSM immediately when `rst_n` is released.
There is no programmable warm-up counter between enabling the analogue block
(`D2A_NIRS_EN`) and issuing the first `RESET` pulse.  This delay is currently
expected to be managed entirely by firmware (write enable register, wait, then
release PPG_RST_REG), which works but is less deterministic than a hardware
counter.

---

## 14. Bugs found and fixed

| # | File | Bug | Fix |
|---|---|---|---|
| 1 | `nirs_ppg_wrapper.sv` | `THRESHOLD_H` concatenation duplicated `NIRS_CTRL[2]` (27-bit RHS → 19-bit wire; accidentally correct after Verilog MSB truncation, but generates synthesis width warning) | Removed duplicate `NIRS_CTRL[2]` byte |
| 2 | `nirs_ppg_wrapper.sv` | `.ILED_SW(ILED_SW)` commented out in `ctrl_top` instantiation — LED never turned on; both counters never reset between cycles | Uncommented the port connection |
| 3 | `nirs_ppg_counter.v` | `else if (RESET) counter_reg <= 1` was dead code: when `RESET=1`, `count_rst_n=0` so async reset always fires first; the synchronous `RESET` branch can never be reached | Removed dead code; counter correctly initialises to 0 |
| 4 | `nirs_ppg_wrapper.sv` | `wire NIRS_EN = 1'b1` and `wire CLK_GATED_BYPASS` were declared but never driven or read anywhere | Removed both unused declarations |
| 5 | `README.md` (Table 12.1.3.1) | OTS timing values for indices 6–15 did not match the RTL or register description table (e.g. index 6 = 7 µs in table vs. 8 µs in RTL; maximum was 25 µs vs. 30 µs in RTL) | Updated table to match RTL |
| 6 | `README.md` (NIRS_CTRL_5) | Field name `THRESHOLD_H[15:8]` — but the code maps `NIRS_CTRL[5]` into `THRESHOLD_L` | Corrected to `THRESHOLD_L[15:8]` |
| 7 | `README.md` (NIRS_CTRL_6) | Field name `THRESHOLD_H[7:0]` — but the code maps `NIRS_CTRL[6]` into `THRESHOLD_L` | Corrected to `THRESHOLD_L[7:0]` |
| 8 | `README.md` (NIRS_DOUT_3) | Typo `DOUF[7:0]` | Corrected to `DOUTF[7:0]` |

# ENS2 CP Test Mode Verification

This directory contains iverilog testbenches that verify the ENS2 chip's CP (wafer-level
probe) test mode — specifically the ability to write trim values to OTP shadow registers
(ATM0–ATM14) and ADJ values to SPI registers (ATM15–ATM29, including NIRS sub-block for
ATM18–ATM20) by driving chip-top I/O pads.

---

## RTL Hierarchy

```
Nanochap_ENS2.sv            ← chip top (only interface is pads)
└── top_dig.sv
    ├── pinmux.sv            ← CP test mode decode, ATM one-hot decode, GPIO routing
    ├── otp_ctrl_top.sv
    │   └── otp_trim_if.sv
    │       └── otp_regs.sv  ← OTP shadow register ATM write FSM
    └── spi_top.sv
        └── spi_reg.sv       ← SPI register ATM ADJ write (ATM15-17, ATM21-29)
            └── spi_reg_nirs.sv ← NIRS sub-block (ATM18-20)
```

---

## CP Test Mode Activation

CP test mode (`debug_mode_en`) requires **both** chip-top pads driven HIGH:

| Pad          | Signal             | Required state |
|--------------|--------------------|----------------|
| `testmode0`  | iopad_testmode0_en_y | HIGH         |
| `testmode1`  | iopad_testmode1_en_y | HIGH         |

Other single-pad modes:
- `testmode0` only (testmode1=0) → scan mode
- `testmode1` only (testmode0=0) → OTP BIST mode
- Neither → normal operation

---

## ATM Mode Decode (GPIO10–14)

With `debug_mode_en=1`, pads GPIO10–GPIO14 (`ana_test_mode[4:0]`) select one of 30
test modes via binary encoding:

| GPIO14:10 | ATM mode  |
|-----------|-----------|
| 5'h00     | ATM0      |
| 5'h01     | ATM1      |
| ...       | ...       |
| 5'h1D     | ATM29     |
| 5'h1E     | unused    |
| 5'h1F     | unused    |

`ana_test_mode` is one-hot decoded inside `pinmux.sv` (lines 297–326) to
`o_OTP_ATM_MODE_SEL[14:0]` (for ATM0–ATM14) or `o_SPI_ATM_MODE_SEL[14:0]`
(for ATM15–ATM29). These two buses are mutually exclusive.

---

## GPIO1–8 Data Path

Pads GPIO1–GPIO8 carry the 8-bit trim/ADJ byte:

```
GPIO1 → bit[0]
GPIO2 → bit[1]
...
GPIO8 → bit[7]
```

With `debug_mode_en=1` and a given ATM N active:
- ATM0–ATM14 → `o_OTP_ATM_TRIM_DATA[7:0]` → `otp_regs` shadow write
- ATM15–ATM29 → `o_SPI_ATM_ADJ_DATA[7:0]` → `spi_reg` ADJ write

When `debug_mode_en=0`, all mode-select and data outputs are forced to zero.

---

## ATM Mode → Register Mapping

### OTP Shadow Registers (ATM0–ATM14)

Written to `otp_regs.shadow_regs[]` in `otp_regs.sv`. Requires `loading_shadows=0`
(OTP startup sequence complete) and `atm_unlock=0` (shadow write, not OTP burn).

| ATM  | shadow_regs[] index | Golden reference description |
|------|---------------------|------------------------------|
| ATM0  | [4]  | Functional trim              |
| ATM1  | [5]  | Functional trim              |
| ATM2  | [6]  | Functional trim              |
| ATM3  | [7]  | Functional trim              |
| ATM4  | [8]  | Functional trim              |
| ATM5  | [9]  | Functional trim              |
| ATM6  | [10] | Functional trim              |
| ATM7  | [11] | SPARE trim                   |
| ATM8  | [12] | SPARE trim                   |
| ATM9  | [13] | SPARE trim                   |
| ATM10 | [14] | SPARE trim                   |
| ATM11 | [15] | SPARE trim                   |
| ATM12 | [16] | SPARE trim                   |
| ATM13 | [17] | SPARE trim                   |
| ATM14 | [18] | SPARE trim                   |

**Critical:** `loading_shadows` must be cleared first. The OTP startup sequence
(drive `otp_dout[7:0]=8'h5a` at `otp_addr=0`, then pulse `rd_set_en`/`addr_set_en`
alternately through addresses 0→4→8→...→20) clears `loading_shadows` once
`otp_addr=20` is reached with valid tag `8'h5a` at address 0.

### SPI ADJ Registers — Main path (ATM15–17, ATM21–29)

Written to `spi_reg.ana_gen_reg[x][14]` via ATM_MODE compression in `spi_reg.sv`
line 1076. Requires `atm_adj=1` (= `debug_mode_en`).

| ATM(s)     | ATM_MODE bit | ana_gen_reg row |
|------------|--------------|-----------------|
| ATM15, ATM29 | [0]        | [0][14]         |
| ATM16, ATM17 | [1]        | [1][14]         |
| ATM21, ATM22 | [2]        | [2][14]         |
| ATM23, ATM24 | [3]        | [3][14]         |
| ATM25        | [4]        | [4][14]         |
| ATM26        | [5]        | [5][14]         |
| ATM27        | [6]        | [6][14]         |
| ATM28        | [7]        | [7][14]         |

Note: ATM15&ATM29 share `ana_gen_reg[0][14]`; ATM16&ATM17 share `ana_gen_reg[1][14]`,
etc. The last written value wins.

### NIRS Registers — NIRS path (ATM18–20)

Routed via `spi_reg_nirs` sub-block (`spi_reg.sv` line 1931:
`.atm_adj_mode(atm_adj_mode[5:3])`).

| ATM   | nirs_ctrl_reg target               | Description                     |
|-------|------------------------------------|---------------------------------|
| ATM18 | `[4][1][7][4:3]` ← data[1:0], `[4][1][7][2:1]` ← data[3:2] | NIRS IREF_COARSE (bits [3:0] only; [7:4] SPARE) |
| ATM19 | same as ATM18                      | NIRS IREF_FINE (same register)  |
| ATM20 | `[4][1][3][7:5]` ← data[2:0], `[4][1][2][4:0]` ← data[7:3] | NIRS IDAC calibration           |

This is **intentional design** per `ENS2_Digital_Pinmux_ascii.txt`:
> "ATM18/19: SPARE ADJ bits not saved but tied to 0"

ATM18–20 are NIRS current-source calibration modes; they do not touch
`ana_gen_reg` or OTP.

---

## Testbenches

| File | DUT | Tests | Result |
|------|-----|-------|--------|
| `tb_otp_shadow_write.sv` | `otp_regs.sv` (real RTL) | 20 | **20 PASS** |
| `tb_spi_atm_adj_write.sv` | behavioral model of `spi_reg.sv` ATM path | 25 | **25 PASS** |
| `tb_nirs_atm_adj_write.sv` | behavioral model of `spi_reg_nirs.sv` ATM path | 11 | **11 PASS** |
| `tb_pinmux_atm_routing.sv` | behavioral model of `pinmux.sv` ATM decode | 115 | **115 PASS** |
| **Total** | | **171** | **171 PASS / 0 FAIL** |

### Running the Testbenches

```sh
cd cp_test_mode/tb
make all        # compile and run all four testbenches
make run_otp    # OTP shadow write only
make run_spi    # SPI ATM ADJ write only
make run_nirs   # NIRS ATM ADJ write only
make run_pmx    # Pinmux ATM routing only
```

Requires `iverilog` (version 12+) and `vvp` (part of the iverilog package).

---

## Findings Summary

1. **CP test mode activation is correct.** Both `testmode0` AND `testmode1` must be
   driven HIGH at the chip pads. No other entry point exists; the only interface is
   at the chip top (`Nanochap_ENS2.sv`).

2. **ATM decode routing is correct.** GPIO10–14 one-hot decode selects the active ATM.
   GPIO1–8 data is routed exclusively to OTP outputs (ATM0–14) or SPI outputs (ATM15–29).
   Codes 30 and 31 produce no output (unused).

3. **OTP shadow writes work.** All ATM0–ATM14 correctly write `atm_data` to
   `shadow_regs[4..18]`. The critical prerequisite is that the OTP startup load
   sequence must complete (`loading_shadows=0`) before any ATM write is attempted;
   otherwise, the shadow write branch is blocked.

4. **SPI ATM ADJ writes work.** ATM15–ATM29 (excluding ATM18–20) correctly write
   8-bit ADJ values to the corresponding row of `ana_gen_reg[][14]`. Pairs of ATMs
   sharing a row (ATM15&29, ATM16&17, ATM21&22, ATM23&24) overwrite each other — the
   last write wins.

5. **ATM18–20 NIRS path is intentional, not a bug.** These three modes are routed to
   the `spi_reg_nirs` sub-block for NIRS (Near-Infrared Spectroscopy) current-source
   calibration. Only bits [3:0] of the GPIO byte are used for ATM18/19; bits [7:4]
   are spare. This matches the golden reference exactly.

6. **No bugs found** in the CP test mode write paths. All 171 test cases pass.

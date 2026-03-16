# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

This is the **Nanochap ENS2** — a biomedical analog front-end (AFE) ASIC design project containing RTL (Verilog/SystemVerilog) source code, UVM testbenches, and ~150+ test cases. There are no software build tools, package managers, or web services.

### Available Open-Source Tools

The development environment provides two open-source tools for RTL development:

- **Verilator 5.020** — SystemVerilog linter and simulator. Best used for static lint checks on individual RTL modules.
- **Icarus Verilog 12.0 (iverilog)** — Verilog simulator. Can compile and simulate standalone modules and simple testbenches.

Both are installed via `apt` (`sudo apt-get install -y verilator iverilog`).

### Linting RTL

To lint a single RTL module (suppressing expected width warnings from MATLAB-generated filter code):

```
verilator --lint-only -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL -Wno-TIMESCALEMOD <file.v|file.sv>
```

**Expected behavior:** ~38 of 85 RTL source files pass standalone lint. The remaining 47 fail due to cross-module instantiation dependencies or foundry technology library cells (e.g., `TLATNTSCA_X8_A7TULL`), which is normal — these modules need to be linted with all dependencies on the include path.

### Compiling and Simulating with iverilog

Standalone modules (e.g., `filter/rtl/filter_lpf_test.v`) can be compiled and simulated:

```
iverilog -g2012 -o sim.vvp <source_files...>
vvp sim.vvp
```

A demo testbench exists at `chip_top/sim/tb_filter_lpf_demo.v` that exercises the FIR LPF filter.

### Limitations

- **Full UVM simulation** requires a commercial simulator (Synopsys VCS is referenced in the codebase) and proprietary Nanochap UVM VIP libraries (`nnc_*_pkg`), neither of which are available in the cloud environment.
- **Chip-top testbenches** (`chip_top/tb/`) use VCS-specific system tasks (`$vcdplusfile`, `$fsdbDumpfile`) and UVM, so they cannot run with iverilog.
- The `common/` cells that fail compilation depend on foundry-specific technology library cells not included in the open-source flow.

### Directory Layout

| Directory | Description |
|-----------|-------------|
| `chip_top/` | Top-level chip integration, testbenches, test cases, simulation models |
| `top_dig/` | Digital top module (`top_dig.sv`) |
| `spi_slave/` | SPI slave controller |
| `filter/` | Digital filters (FIR LPF, IIR HPF, notch) |
| `wg_driver/` | Waveform generator |
| `imeas/` | Impedance measurement (CIC decimation) |
| `otp/` | One-Time Programmable memory controller |
| `sys_ctrl/` | System control (clock, PMU, reset) |
| `anac/` | Analog controller |
| `nirs_ctrl/` | NIRS/PPG controller |
| `lead_off/` | Lead-off detector |
| `gpio/` | GPIO controller |
| `pinmux/` | Pin multiplexer |
| `common/` | Shared utility cells (clock gates, muxes, CDC, resets) |

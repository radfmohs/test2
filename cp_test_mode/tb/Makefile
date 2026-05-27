# Makefile for CP Test Mode Testbenches
# Usage:
#   make all        — compile and run all testbenches
#   make run_otp    — OTP shadow register ATM write (ATM0-14)
#   make run_spi    — SPI ADJ register ATM write   (ATM15-17, ATM21-29)
#   make run_nirs   — NIRS register ATM write       (ATM18-20)
#   make run_pmx    — Pinmux ATM routing            (all ATM0-29)
#   make clean      — remove compiled binaries

IVERILOG := iverilog -g2012
VVP      := vvp
OTP_RTL  := ../../otp/rtl/otp_regs.sv

SIM_OTP  := /tmp/sim_cp_otp
SIM_SPI  := /tmp/sim_cp_spi
SIM_NIRS := /tmp/sim_cp_nirs
SIM_PMX  := /tmp/sim_cp_pmx

.PHONY: all run_otp run_spi run_nirs run_pmx clean

all: run_otp run_spi run_nirs run_pmx

run_otp: $(SIM_OTP)
	@echo "=== OTP Shadow Write (ATM0-14) ==="
	$(VVP) $(SIM_OTP)

$(SIM_OTP): tb_otp_shadow_write.sv $(OTP_RTL)
	$(IVERILOG) -o $@ $^

run_spi: $(SIM_SPI)
	@echo "=== SPI ATM ADJ Write (ATM15-29) ==="
	$(VVP) $(SIM_SPI)

$(SIM_SPI): tb_spi_atm_adj_write.sv
	$(IVERILOG) -o $@ $<

run_nirs: $(SIM_NIRS)
	@echo "=== NIRS ATM ADJ Write (ATM18-20) ==="
	$(VVP) $(SIM_NIRS)

$(SIM_NIRS): tb_nirs_atm_adj_write.sv
	$(IVERILOG) -o $@ $<

run_pmx: $(SIM_PMX)
	@echo "=== Pinmux ATM Routing (ATM0-29) ==="
	$(VVP) $(SIM_PMX)

$(SIM_PMX): tb_pinmux_atm_routing.sv
	$(IVERILOG) -o $@ $<

clean:
	rm -f $(SIM_OTP) $(SIM_SPI) $(SIM_NIRS) $(SIM_PMX)

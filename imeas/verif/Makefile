# Makefile for CIC comparison testbench (Icarus Verilog)
#
# Usage:
#   make        – compile and run
#   make clean  – remove generated files

SIM     = iverilog
VVP     = vvp
TARGET  = tb_cic_compare
SRCS    = rtl_cic_simple.v dec_cic_simple.v tb_cic_compare.v

.PHONY: all clean

all: $(TARGET)
	$(VVP) $(TARGET)

$(TARGET): $(SRCS)
	$(SIM) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET) *.vcd

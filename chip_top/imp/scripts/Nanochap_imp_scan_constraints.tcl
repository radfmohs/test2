# ------------------------------------------------------------------------------
# Purpose :  Synthesis Script - Constraints
#
# ------------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Case analysis atpg_en to 1
# -----------------------------------------------------------------------------

#scan clock
set scan_clock_period     100.000
set scan_clock_period_jitter  [expr {$scan_clock_period * 0.01}] 
set scan_clock_real_period    [expr {$scan_clock_period - $scan_clock_period_jitter}] 
set scan_clock_real_half_real_period    [expr {$scan_clock_real_period / 2}] 


create_clock -name scan_clk [get_ports IOBUF_PAD[0]] \
-period [expr {${scan_clock_period} - ${scan_clock_period_jitter}}] -waveform {45 65} 
set_clock_uncertainty -setup                   [expr {${setup_margin} + $pre_cts_clock_skew_estimate}]     [get_clocks scan_clk]
set_clock_uncertainty -hold                    [expr {${hold_margin} + $pre_cts_clock_skew_estimate}]      [get_clocks scan_clk]
set_clock_latency $pre_cts_clock_latency_estimate                                                          [get_clocks scan_clk]

set_clock_transition -max 0.8 [get_clocks scan_clk]
set_case_analysis 1 [get_pins u_top_dig/u_pinmux/atpg_en]
set_case_analysis 0 u_top_dig/u_spi_top/iopad_cpol
set_case_analysis 0 u_top_dig/u_spi_top/iopad_cpha
set_case_analysis 1 iopad_testmode0
set_case_analysis 0 iopad_testmode1

# ------------------------------------------------------------------------------
# Scan port input/output delay
# ------------------------------------------------------------------------------
#set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_pins u_top_dig/iopad_resetn_frompad]   -add_delay
#set_input_delay  -clock scan_clk -min 20                                   [get_pins u_top_dig/iopad_resetn_frompad]   -add_delay

set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports CLKSEL]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports CLKSEL]    -add_delay

set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[1]]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports IOBUF_PAD[1]]    -add_delay
set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[3]]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports IOBUF_PAD[3]]    -add_delay
set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[4]]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports IOBUF_PAD[4]]    -add_delay
set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[5]]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports IOBUF_PAD[5]]    -add_delay
set_input_delay  -clock scan_clk -max [expr {0.40 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[6]]    -add_delay
set_input_delay  -clock scan_clk -min 20                                   [get_ports IOBUF_PAD[6]]    -add_delay

set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[7]]    -add_delay
set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[7]]    -add_delay
set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[8]]      -add_delay
set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[8]]      -add_delay
set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[9]]      -add_delay
set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[9]]      -add_delay
set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[10]]      -add_delay
set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[10]]      -add_delay
#set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[11]]      -add_delay
#set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[11]]      -add_delay
#set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[12]]      -add_delay
#set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[12]]      -add_delay
#set_output_delay -clock scan_clk -max [expr {0.20 * ${scan_clock_period}}]  [get_ports IOBUF_PAD[13]]      -add_delay
#set_output_delay -clock scan_clk -min 0                                   [get_ports IOBUF_PAD[13]]      -add_delay

 
 set_false_path -through [get_ports iopad_testmode*]
# set_false_path -through [get_ports IOBUF_PAD[1]]
 set_false_path -through [get_ports IOBUF_PAD[2]];#scan_compression_in pin
# set_disable_timing -from POR -to PPROG [get_cells u_top_dig/otp_ctrl_top_inst/u_EO32X32GCT2Q_H3]
 set_false_path -through [get_pins u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/*]
# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------

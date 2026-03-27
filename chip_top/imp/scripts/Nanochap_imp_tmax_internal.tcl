#set stage postlayout
sh mkdir -p ../reports/atpg_$env(stage)_internal
sh mkdir -p ../data/atpg_patterns_$env(stage)_internal;

read_netlist -lib ../tech/sc7_lib/verilog/sc7_l013_base_rvt.v
read_netlist -lib ../tech/sc7_lib/verilog/sc7_l013_base_rvt_udp.v


read_netlist -lib ../tech/HHG_F013Q7P6_PADLRCMCUDB41K/behaviour_model/PADLRCMCUDB.v -define ATPG_SIM
#read_netlist -lib ../../../../verification/models/analog/ana_top/ENS2_ANA_CHIP.v -define ATPG_SIM
read_netlist -lib ../tech/ana_lib/ENS2_ANA_CHIP.v -define ATPG_SIM

if {$env(stage) == "postscan"} {
	read_netlist ../data/synthesis_postscan/Nanochap_ENS2.dft.v
}
if {$env(stage) == "postlayout"} {
	read_netlist /projects/libs/bms5/digital_work/MS_ENS2_DIG/pnr_30062023_v9_ECO9/Nanochap_ENS2.v
}

set_build -black_box FPFLE032K09DA 

set_rules b12 warning
set_rules b24 warning

add_net_connections TIE1 u_top_dig/u_pinmux/atpg_en  -disconnect
add_net_connections TIE0 u_top_dig/u_pinmux/u_gpio10_pinmux/test0_y  -disconnect
#add_net_connections TIE0 u_dig_top_wrapper/u_dig_top/u_pinmux/u_gpio9_pinmux/test0_y  -disconnect

if {$env(stage) == "postscan"} {
	#add_net_connections TIE1 A2D_Wake_UP_i -disconnect
}
if {$env(stage) == "postlayout"} {
	add_net_connections TIE1 AON_BUF_N_ANA_u_ana_top_A2D_Wake_UP_i -disconnect
}
add_net_connections TIE1 POC -all
set_build -nodelete_unused_gates

set_fault -atpg_effectiveness
set_fault -fault_coverage
run_build_model Nanochap_ENS2

set_drc -allow_unstable_set_resets

#run_drc ../data/synthesis_postscan/Nanochap_ENS2.dft_scan_spf
run_drc ../data/synthesis_postscan/Nanochap_ENS2.dft_scan_spf_internal

set_faults -report uncollapsed
set_faults -summary verbose

remove_faults -all

#source ./scr/list_nofaults
#add_nofaults analogue_model_inst
#add_nofaults dna_dig_top_inst/redundant_inst 

add_faults -all
#

report_faults -uncollapse -summary > ../reports/atpg_$env(stage)_internal/summary
report_faults -uncollapse -class AN > ../reports/atpg_$env(stage)_internal/class_AN
report_faults -uncollapse -class UD > ../reports/atpg_$env(stage)_internal/class_UD
report_faults -uncollapse -class UR > ../reports/atpg_$env(stage)_internal/class_UR
report_violation -all > ../reports/atpg_$env(stage)_internal/violation

#set_atpg -pattern 5

#set_atpg -capture_cycles 4

set_atpg -lete_fastseq
set_atpg -coverage 99.9

set_atpg -abort 100
set_atpg -merge high

run_atpg -auto

#report_faults -class AN -unsuccessfull >  ../reports/atpg_$env(stage)_internal/unsuccessfull
report_scan_chain > ../reports/atpg_$env(stage)_internal/scan_chain
report_scan_cells  -all > ../reports/atpg_$env(stage)_internal/scan_cell
analyze_faults -class AN -verbose > ../reports/atpg_$env(stage)_internal/ana_class_an

write_faults ../reports/atpg_$env(stage)_internal/Nanochap_ENS2 -replace -uncollapse -class AN

write_patterns  ../data/atpg_patterns_$env(stage)_internal/pattern_seri.wgl -replace -serial -format wgl
write_patterns  ../data/atpg_patterns_$env(stage)_internal/pattern_seri.stil -replace -serial -format stil
write_testbench -input ../data/atpg_patterns_$env(stage)_internal/pattern_seri.stil -output ../data/atpg_patterns_$env(stage)_internal/test_pattern_seri -replace -parameters { -config_file ../scripts/Nanochap_ENS2_tmax.conf }

write_patterns  ../data/atpg_patterns_$env(stage)_internal/pattern_para.wgl -replace -parallel -format wgl 
write_patterns  ../data/atpg_patterns_$env(stage)_internal/pattern_para.stil -replace -parallel -format stil
write_testbench -input ../data/atpg_patterns_$env(stage)_internal/pattern_para.stil -output ../data/atpg_patterns_$env(stage)_internal/test_pattern_para -replace -parameters { -config_file ../scripts/Nanochap_ENS2_tmax.conf }

write_patterns ../data/atpg_patterns_$env(stage)_internal/pattern_seri_5.wgl -replace -serial -format wgl -last 5
write_patterns ../data/atpg_patterns_$env(stage)_internal/pattern_seri_5.stil -replace -serial -format stil -last 5
write_testbench -input ../data/atpg_patterns_$env(stage)_internal/pattern_seri_5.stil -output ../data/atpg_patterns_$env(stage)_internal/test_pattern_seri_5 -replace -parameters { -config_file ../scripts/Nanochap_ENS2_tmax.conf }

exit

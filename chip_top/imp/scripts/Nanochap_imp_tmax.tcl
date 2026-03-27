exec mkdir -p ../reports/atpg_$env(stage)_$env(dc_sel);
exec mkdir -p ../data/atpg_patterns_$env(stage)_$env(dc_sel);

read_netlist -lib ../tech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_sc7xz_base_g1p8/arm/verilog/sc7_ch018ull_base_rvt.v
read_netlist -lib ../tech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_sc7xz_base_g1p8/arm/verilog/sc7_ch018ull_base_rvt_udp.v


read_netlist -lib ../tech/gf_arm_180nm_ULL_BCDlite/GF018bcdlite_icpio_5p0_75_wp_2016q1v1/verilog/GF018bcdlite_icpio_5p0_75_wp.v -define ATPG_SIM
read_netlist -lib ../tech/ana_lib/ENS2_ANA_CHIP.v -define ATPG_PATTERNS


if {$env(stage) == "postlayout"} {
	read_netlist ../data/postlayout_net_for_atpg_gen/Nanochap_ENS2.postlayout_for_atpg.v 
} elseif {$env(stage) == "postscan"} {
	read_netlist ../data/synthesis_$env(stage)_$env(dc_sel)_$env(generate_sdf)/Nanochap_ENS2.$env(stage)_$env(dc_sel).v
} else {
	read_netlist ../data/synthesis_$env(stage)_$env(generate_sdf)/Nanochap_ENS2.$env(stage).v
}

set_build -black_box EO32X32GCT2Q_H3_PA 

set_rules b12 warning
set_rules b24 warning

add_net_connections TIE1 u_iopad_testmode0/Y  -disconnect
add_net_connections TIE0 u_iopad_testmode1/Y  -disconnect

set_build -nodelete_unused_gates

set_fault -atpg_effectiveness
set_fault -fault_coverage
run_build_model Nanochap_ENS2

add_po_masks VSS_DIG
set_drc -allow_unstable_set_resets

if {$env(stage) == "postlayout"} {
	run_drc ../data/synthesis_postscan_dct_no_sdf/Nanochap_ENS2.dft_scan_spf
} elseif {$env(stage) == "postscan"} {
	run_drc ../data/synthesis_$env(stage)_$env(dc_sel)_$env(generate_sdf)/Nanochap_ENS2.dft_scan_spf
} else {
	run_drc ../data/synthesis_postscan_dct_no_sdf/Nanochap_ENS2.dft_scan_spf
}

set_faults -report uncollapsed
set_faults -summary verbose

remove_faults -all


add_faults -all

report_faults -uncollapse -summary > ../reports/atpg_$env(stage)_$env(dc_sel)/summary
report_faults -uncollapse -class AN > ../reports/atpg_$env(stage)_$env(dc_sel)/class_AN
report_faults -uncollapse -class UD > ../reports/atpg_$env(stage)_$env(dc_sel)/class_UD
report_faults -uncollapse -class UR > ../reports/atpg_$env(stage)_$env(dc_sel)/class_UR
report_violation -all > ../reports/atpg_$env(stage)_$env(dc_sel)/violation



set_atpg -lete_fastseq
set_atpg -coverage 99.9

set_atpg -abort 100
set_atpg -merge high

run_atpg -auto

#report_faults -class AN -unsuccessfull >  ../reports/atpg_$env(stage)_$env(dc_sel)/unsuccessfull
report_scan_chain > ../reports/atpg_$env(stage)_$env(dc_sel)/scan_chain
report_scan_cells  -all > ../reports/atpg_$env(stage)_$env(dc_sel)/scan_cell
analyze_faults -class AN -verbose > ../reports/atpg_$env(stage)_$env(dc_sel)/ana_class_an

write_faults ../reports/atpg_$env(stage)_$env(dc_sel)/Nanochap_ENS2 -replace -uncollapse -class AN

write_patterns  ../data/atpg_patterns_$env(stage)_$env(dc_sel)/pattern_seri.wgl -replace -serial -format wgl
write_patterns  ../data/atpg_patterns_$env(stage)_$env(dc_sel)/pattern_seri.stil -replace -serial -format stil
write_testbench -input ../data/atpg_patterns_$env(stage)_$env(dc_sel)/pattern_seri.stil -output ../data/atpg_patterns_$env(stage)_$env(dc_sel)/test_pattern_seri -replace -parameters { -config_file ../scripts/Nanochap_imp_tmax.conf }

exit

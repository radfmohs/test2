# ------------------------------------------------------------------------------
# Purpose : write verilog with pg pins script
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Job Diagnostics
# ------------------------------------------------------------------------------

# Log the time that this script starts executing
set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

# ------------------------------------------------------------------------------
# Set-up Design Configuration Options
# ------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

set dc_sel  DC;#topographical not needed here

# ------------------------------------------------------------------------------
# Set-up Target Technology
# ------------------------------------------------------------------------------

source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

#set stage postscan_pteco
sh mkdir -p ../reports/synthesis_postscan_pteco_sdf
sh mkdir -p ../data/synthesis_postscan_pteco_sdf


# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Set-up Target/Link Libraries
# ------------------------------------------------------------------------------

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
#set_app_var synthetic_library dw_foundation.sldb
#set_app_var symbol_library $stdcell_sdb

if {$stage == "postscan_pteco"} {
    read_verilog  ../data/synthesis_postscan_sdf/${rm_project_top}.postscan.v
}
if {$stage != "postscan_pteco"} {
    read_verilog  ../data/synthesis_postscan_pteco_sdf/${rm_project_top}.postscan_pteco.v
}

set_app_var target_library $stdcell_library(db,$fast_corner_pvt)
set_app_var link_library [concat * $target_library $otp_min_library $io_min_library $ana_min_library];# $synthetic_library]

current_design $rm_project_top

link

set upf_create_implicit_supply_sets false
remove_upf
source -e -v ../scripts/Nanochap_imp_upf.tcl
set_voltage 0.0 -object_list {VSS_DIG }
set_voltage 1.65 -object_list {VDD_DIG }

write -f verilog  -hierarchy -output ../data/synthesis_postscan_pteco_sdf/${rm_project_top}.postscan_pteco_pg.v -pg

print_message_info

set end_time [clock seconds]; echo [string toupper inform:] End time [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "[string toupper inform:] Time elapsed: [format %02d \
                     [expr ($end_time - $start_time)/86400]]d \
                    [clock format [expr ($end_time - $start_time)] \
                    -format %Hh%Mm%Ss -gmt true]"

exit

# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------

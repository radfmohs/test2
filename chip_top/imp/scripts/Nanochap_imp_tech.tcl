
#####################################################################################
# 1. Main design performance targets
#####################################################################################

# -----------------------------------------------------------------------------
# Default corners:
# -----------------------------------------------------------------------------

# The default corner names are 'keys' defining the min/max PVT used throughout
# implementation. These can be changed if matching libraries/pvt corners are
# available
set ss_lib_name sc7_ch018ull_base_rvt_ss_typ_max_1p62v_125c
set tt_lib_name sc7_ch018ull_base_rvt_tt_typ_max_1p80v_25c
set ff_lib_name sc7_ch018ull_base_rvt_ff_typ_min_1p98v_m40c
set sc sc7_ch018ull_base_rvt

set slow_corner_pvt ss_typ_max_1p62v_125c
set typ_corner_pvt  tt_typ_max_1p80v_25c
set fast_corner_pvt ff_typ_min_1p98v_m40c

# Equivalent default RC extraction corners 'keys' are also used

set slow_corner_extraction max
set typ_corner_extraction  typ
set fast_corner_extraction min

# -----------------------------------------------------------------------------
# setup/hold timing margin
# -----------------------------------------------------------------------------
set setup_margin            0.100       ;# in ns. Setup margin this really is the additional margin after ocv, undertainty and corner
set hold_margin             0.050       ;# in ns. Hold margin

# -----------------------------------------------------------------------------
# Pre-CTS clock skew and latency estimates
# -----------------------------------------------------------------------------

set pre_cts_clock_skew_estimate    0.150 ;
set pre_cts_clock_latency_estimate 2.000 ;

#####################################################################################
# 2. Design environment
#####################################################################################

# -----------------------------------------------------------------------------
# Input driving cell models
# -----------------------------------------------------------------------------
set driving_cell            BUF_X4_A7TULL       ;# The driving cell for all inputs 
set driving_from_pin        A
set driving_pin             Y                   ;# The output pin of the driving cell

set clock_driving_cell      CLKBUF_X8_A7TULL    ;# The driving cell for clock ports
set clock_driving_from_pin  A
set clock_driving_pin       Y                   ;# The output pin of the clock driving cell

set icg_name    {integrated:TLATNTSCA_X8_A7TULL};# Name of ICG cell

# -----------------------------------------------------------------------------
# Output loading models
# -----------------------------------------------------------------------------

set output_load             10.0            ;# Capacitive load placed on all inout/output pad

# -----------------------------------------------------------------------------
# Input transition models
# -----------------------------------------------------------------------------

set input_transition        1.0             ;# Input transition placed on all inout/input pad 

# -----------------------------------------------------------------------------
# Max capacitance
# -----------------------------------------------------------------------------

# Keyed from "$transistor_$voltage_$temperature"

# This is used to set the upper limits for tables during timing model creation
# These values have based on the largest max_capacitance in target library
# Smaller values may be preferable for increased accuracy over a smaller range
# CLKINVX32M/Y max_capacitance as reference
set max_capacitance 4.823

# -----------------------------------------------------------------------------
# Transition time targets
# -----------------------------------------------------------------------------

# Keyed from "$transistor_$voltage_$temperature"

# Only max_transition($slow_corner_pvt) is required during implementation
# Others are used in analysis steps such as sta and model creation
# ARM suggests: 1. design frequency is equal or less than lib freq 66.7% of max lib, 
# 2. 1/5 of clock cycle
# take the small one
# default_max_transition : 2.38 ;
# clock cycle : 1000 (1 MHz maximum)
set max_transition          2.547   ;# 3.818 * 0.667  

# Clock transition requirement
set max_clock_transition    0.5

# max fanout 
set max_fanout 32            ;# Maximum fanout threshold

#####################################################################################
# 3. Design libraries
#####################################################################################

# -----------------------------------------------------------------------------------
# Path to libraries
# -----------------------------------------------------------------------------------

if {[info exists sh_launch_dir] == 0} {
  set sh_launch_dir "."
}

# Set the base path for libraries (e.g. "/projects/my_project/libraries")
set stdcell_db_path "../tech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_sc7xz_base_g1p8/arm/db"
#set eeprom_db_path "../tech/GF180_ULL_ISO_65V_EEPROM128x8/Timing_model/"
set otp_db_path "../tech/OTP_eMemory/OTP_32x32_EO32X32GCT2Q_H3_v1/EO32X32GCT2Q_H3_v1.4/lib/"
set io_db_path "../tech/gf_arm_180nm_ULL_BCDlite/GF018bcdlite_icpio_5p0_75_wp_2016q1v1/lib_018ull"
set ana_db_path "../tech/ana_lib"
# Standard Cells Symbol library
set stdcell_sdb_path "../tech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_sc7xz_base_g1p8/arm/sdb"
set stdcell_sdb "sc7_ch018ull_base_rvt.sdb"
# RTL verilog folder
set verilog_rtl_path "../../rtl/"


# -----------------------------------------------------------------------------
# Techfile and metal stack extract models
# -----------------------------------------------------------------------------

set tech_file             [list /home/projects/digitech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_routing_kit/milkyway/1P6M/sc7_tech.tf]
set tf2itf_map_file       [list /home/projects/digitech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_routing_kit/synopsys_tluplus/1P6M/tluplus.map]
#
## Keyed from '$extraction'
#
set tluplus_file($slow_corner_extraction) [list /home/projects/digitech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_routing_kit/synopsys_tluplus/1P6M/wcs.tluplus]
set tluplus_file($typ_corner_extraction) [list  /home/projects/digitech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_routing_kit/synopsys_tluplus/1P6M/typ.tluplus]
set tluplus_file($fast_corner_extraction) [list /home/projects/digitech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_routing_kit/synopsys_tluplus/1P6M/bcs.tluplus]

set stdcell_mw_library [list /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/lib_inputs/mw/sc7_ch018ull_base_rvt]
set ana_mw_library [list /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/lib_inputs/mw/ENS2_ANA_CHIP_syn.mw]
set pad_mw_library [list /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/lib_inputs/mw/GF018bcdlite_icpio_5p0_75_wp_6lm_9TM.mw]
set otp_mw_library [list /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/lib_inputs/mw/otp.mw]
set vpp_mw_library [list /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/lib_inputs/mw/GF_CI_VPP.mw]

# -----------------------------------------------------------------------------
# Library search path and Milkyway locations
# -----------------------------------------------------------------------------
set stdcell_search_path     [list $stdcell_db_path $stdcell_sdb_path]
#set eeprom_search_path         [list $eeprom_db_path]
set otp_search_path         [list $otp_db_path]
set io_search_path          [list $io_db_path]
set ana_search_path         [list $ana_db_path]
# -----------------------------------------------------------------------------
# Library search path and Milkyway locations
# -----------------------------------------------------------------------------
set verilog_search_path     [list $verilog_rtl_path]

# Standard Cells db

set stdcell_library(db,$fast_corner_pvt) [ list \
                                        ${ff_lib_name}.db \
                                        ]

set stdcell_library(db,$slow_corner_pvt) [ list \
                                        ${ss_lib_name}.db \
                                        ]

set stdcell_library(db,$typ_corner_pvt)  [ list \
                                        ${tt_lib_name}.db \
                                        ]

# eeprom
#set eeprom_max_library [list YEN12808F18B5AA2_Y01_SS_V10.db]
#set eeprom_min_library [list YEN12808F18B5AA2_Y01_FF_V10.db]
#set eeprom_typ_library [list YEN12808F18B5AA2_Y01_TT_V10.db]

# otp
set otp_max_library [list EO32X32GCT2Q_H3_PA_ss.db]
set otp_min_library [list EO32X32GCT2Q_H3_PA_ff.db]
set otp_typ_library [list EO32X32GCT2Q_H3_PA_tt.db]

# IO
set io_max_library [list GF018bcdlite_icpio_5p0_75_wp_SS_1P62V_125C_2P97V.db]
set io_min_library [list GF018bcdlite_icpio_5p0_75_wp_FF_1P98V_M40C_3P63V.db]
set io_typ_library [list GF018bcdlite_icpio_5p0_75_wp_TT_1P80V_25C_3P30V.db]
#set io_max_library [list GF018bcdlite_icpio_5p0_75_wp_SS_1P62V_125C_4P50V.db]
#set io_min_library [list GF018bcdlite_icpio_5p0_75_wp_FF_1P98V_M40C_5P50V.db]
#set io_typ_library [list GF018bcdlite_icpio_5p0_75_wp_TT_1P80V_25C_5P00V.db]

# Analog
set ana_max_library [list ENS2_ANA_CHIP_wc.db]
set ana_min_library [list ENS2_ANA_CHIP_bc.db]
set ana_typ_library [list ENS2_ANA_CHIP_tc.db]

# -----------------------------------------------------------------------------
# Operating conditions
# -----------------------------------------------------------------------------

# Keyed from "$transistor_$voltage_$temperature"


set operating_condition_name($fast_corner_pvt)  $fast_corner_pvt
set target_library_name($fast_corner_pvt)       $ff_lib_name

set operating_condition_name($slow_corner_pvt)  $slow_corner_pvt
set target_library_name(${slow_corner_pvt})     $ss_lib_name

set operating_condition_name(${typ_corner_pvt}) ${typ_corner_pvt}
set target_library_name(${typ_corner_pvt})      $tt_lib_name

# -----------------------------------------------------------------------------
# Tetramax ATPG cell views
# -----------------------------------------------------------------------------

set tmax_library [ list \
                        ../tech/gf_arm_180nm_ULL_BCDlite/ULL_1V8_sc7xz_base_g1p8/arm/tetramax/sc7_ch018ull_base_rvt.tv \
                       ]

# -----------------------------------------------------------------------------
# Don't use lists
# -----------------------------------------------------------------------------

# Keyed from a target libary name,
# Note: Use of wildcards permitted in Tcl for library names and cell names:
# e.g. set dont_use(sc7_ce018fg_base_rvt*) [list *_XL_* ]

set dont_use(${sc}_*) {}

# Basic dont_use for specific cell types
lappend dont_use(${sc}_*) *CLK*
lappend dont_use(${sc}_*) *EDFF*
lappend dont_use(${sc}_*) DLY*
lappend dont_use(${sc}_*) TBUF*
lappend dont_use(${sc}_*) SDFFTR*

# Banning low drive strength cells may improve speed, but with area/power impact
lappend dont_use(${sc}_*) *XL*
# Physical only: Tie cell
lappend dont_use(${sc}_*) TIE*

# Example of use within tool:
# foreach libraryname [array names dont_use] {
#     foreach dontusecelltype $dont_use($libraryname) {
#         echo "set_dont_use -power [get_object_name [get_lib_cells ${libraryname}/${dontusecelltype}]]"
#         set_dont_use -power [get_lib_cells ${libraryname}/${dontusecelltype}]
#     }
# }

# -----------------------------------------------------------------------------------
# Tool reporting defaults
# -----------------------------------------------------------------------------------

# Increase the precision of timing reports to 3 significant digits
# Note: *decreases* precision of area reports to 3 from 6 significant digits
set report_default_significant_digits 3

# End of File

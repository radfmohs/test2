# ----------------------------------------------------------------------------------
# Add RTL search path
# ----------------------------------------------------------------------------------
set_app_var search_path [ concat $search_path ../../../chip_top/rtl/]
set_app_var search_path [ concat $search_path ../../../sys_ctrl/clk_ctrl/rtl]
set_app_var search_path [ concat $search_path ../../../sys_ctrl/pmu/rtl]
set_app_var search_path [ concat $search_path ../../../sys_ctrl/reset_ctrl/rtl]
set_app_var search_path [ concat $search_path ../../../pinmux/rtl]
set_app_var search_path [ concat $search_path ../../../top_dig/rtl]
set_app_var search_path [ concat $search_path ../../../common]
set_app_var search_path [ concat $search_path ../../../otp/rtl]
#set_app_var search_path [ concat $search_path ../../../imeas/rtl]
set_app_var search_path [ concat $search_path ../../../spi_slave/rtl]
set_app_var search_path [ concat $search_path ../../../anac/rtl]
set_app_var search_path [ concat $search_path ../../../wg_driver/rtl]

# -----------------------------------------------------------------------------------
#  RTL for chip_top top
# -----------------------------------------------------------------------------------
set ENS2_top [ list \
        Nanochap_ENS2.v \
	clk_ctrl.v \
	pmu.v \
	reset_ctrl.v \
	pinmux_1bit.v \
	pinmux.v \
	apb_anac.v \
	top_dig.v \
            ]
# -----------------------------------------------------------------------------------
#  RTL for OTP
# -----------------------------------------------------------------------------------
set otp [ list \
            constants_EPROM_BIST.v \
            eprom_bist.v     \
            eprom_bist_top.v \
            eprom_timing.v   \
            otp_clkcnt.v     \
            otp_ctrl_top.v   \
            otp_out_ctrl.v   \
            otp_regs.sv      \
            otp_rw_ctrl.v    \
            otp_trim_if.v    \
            ]
## -----------------------------------------------------------------------------------
##  RTL for imeas
## -----------------------------------------------------------------------------------
#set imeas [ list \
#	imeas.v \
#	imeas_cdc.v \
#	imeas_cic.v \
#	imeas_ctrl.v \
#	imeas_reg.v \
#            ]
# -----------------------------------------------------------------------------------
#  RTL for common cells
# -----------------------------------------------------------------------------------
set common_cells [ list \
            common_pulse_cdc.v \
            common_bit_sync.v \
            common_sync_bit.v \
            common_clock_gate.v \
            common_dbg_buf16.v \
            common_rst_sync.v \
            common_clk_switch.v \
            cell_icg.v \
            cell_mx2.v \
            cell_mx4.v \
            cell_mx16.v \
            cell_buf.v \
            cell_clkmx2.v \
            cell_clkbuf.v \
                ]

# -----------------------------------------------------------------------------------
#  RTL for spi_slave
# -----------------------------------------------------------------------------------
set spi_slave [ list \
            spi_top.v \
            _42c_l.v               \
            boot_mul.v             \
            bootcoder.v            \
            csa.v                  \
            spi_cpha_cpol_slct.v   \
            spi_reg.v              \
            spi_reg_wavegen.v      \
            spi_slave_controller.v \
            ]

# -----------------------------------------------------------------------------------
#  RTL for WG_Driver
# -----------------------------------------------------------------------------------
set wg_driver [ list \
            arb_wave_gen.sv          \
            hex2bin.sv               \
            wg_driver_top.sv         \
            wg_driver_top_wrapper.sv \
            ]

set rtl_image [ concat  $otp \
                        $common_cells \
                        $spi_slave \
                        $wg_driver \
                        $ENS2_top \
                        ]
# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from Arm Limited or its affiliates.
#
#            (C) COPYRIGHT 2011-2013 Arm Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from Arm Limited or its affiliates.
#
#      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
#      Revision            : $Revision: 371321 $
#      Release Information : Cortex-M System Design Kit-r1p1-00rel0
#
# ------------------------------------------------------------------------------
# Purpose : Synthesis Script - Reports
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Write final reports
# ------------------------------------------------------------------------------

printvar > ${out_rep}/${rm_project_top}.${i}.vars

check_design -multiple_designs > \
  ${out_rep}/${rm_project_top}.${i}.check_design

check_timing > \
  ${out_rep}/${rm_project_top}.${i}.check_timing

#report_timing -delay max \
#              -max_paths 10 \
#              -nosplit \
#              -cap \
#              -path full_clock_expanded \
#              -nets \
#              -transition_time \
#              -input_pins  \
#              -nworst 10 \
#              -slack_lesser_than 0 > \
#  ${out_rep}/${rm_project_top}.${i}.timing_vio_max

report_timing -delay min \
              -max_paths 100 \
              -nosplit \
              -cap \
              -path full_clock_expanded \
              -nets \
              -transition_time \
              -input_pins  \
              -nworst 2 \
              -slack_lesser_than 0 > \
  ${out_rep}/${rm_project_top}.${i}.timing_vio_min

# Create compacted version of the timing report showing only nets
#set fr [open ${out_rep}/${rm_project_top}.${i}.timing-max r]
#set fw [open ${out_rep}/${rm_project_top}.${i}.timing-max-nets w]

#while {[gets $fr line] >= 0} {
#    if {[regexp {delay} $line] ||
#        [regexp { data } $line] ||
#        [regexp {slack} $line] ||
#        [regexp {\-\-\-\-} $line] ||
#        [regexp {Group} $line] ||
#        [regexp {Startpoint} $line] ||
#        [regexp {Endpoint} $line] ||
#        [regexp {Point} $line] ||
#        [regexp { clock } $line] ||
#        [regexp {(net)} $line] ||
#        [regexp {^ *$} $line]
#    } {
#        if {![regexp {/n[0-9]+ } $line]} {
#            puts $fw $line
#        }
#    }
#}

#close $fr
#close $fw

report_timing -loops > \
  ${out_rep}/${rm_project_top}.${i}.loops

if {[string match S111_min $i]} {
  report_area -nosplit \
              -hierarchy \
              -physical > \
    ${out_rep}/${rm_project_top}.${i}.area

  report_cell {*/u_* *} > \
    ${out_rep}/${rm_project_top}.${i}.cell

  source ../scripts/Nanochap_imp_rpt_cell.tcl

  rpt_cell -h > \
  ${out_rep}/${rm_project_top}.${i}.full_cell

  rpt_cell -a > \
  ${out_rep}/${rm_project_top}.${i}.detail_cell
  report_net_fanout -threshold 32 -nosplit > \
  ${out_rep}/${rm_project_top}.${i}.high_fanout_nets

  report_port -verbose \
              -nosplit > \
    ${out_rep}/${rm_project_top}.${i}.port

  report_hierarchy > \
    ${out_rep}/${rm_project_top}.${i}.hierarchy

  report_resources -hierarchy > \
    ${out_rep}/${rm_project_top}.${i}.resources

  report_compile_options > \
    ${out_rep}/${rm_project_top}.${i}.compile_options

  report_congestion > \
    ${out_rep}/${rm_project_top}.${i}.congestion
    
  report_qor > \
  ${out_rep}/${rm_project_top}.${i}.qor
}

report_power -cell -sort_mode cell_leakage_power -nworst 30 -flat  > \
  ${out_rep}/${rm_project_top}.${i}.top_cell_leakage_power

report_power -nosplit > \
  ${out_rep}/${rm_project_top}.${i}.power

#set_case_analysis 0 [get_pins u_top_ana/A2D_WAKE_UP_I]

#report_power -cell -only u_top_dig_always_on -flat -nosplit > \
#  ${out_rep}/${rm_project_top}.${i}.power_AO_LP

#set_case_analysis 1 [get_pins u_top_ana/A2D_WAKE_UP_I]

report_constraint -all_violators \
                  -nosplit > \
  ${out_rep}/${rm_project_top}.${i}.constraint_violators

report_design > \
  ${out_rep}/${rm_project_top}.${i}.design_attributes

report_clock -attributes \
              -skew > \
  ${out_rep}/${rm_project_top}.${i}.clocks

report_clock_gating -multi_stage \
                    -verbose \
                    -gated \
                    -ungated \
  > ${out_rep}/${rm_project_top}.${i}.clock_gating

# This crashed on DC TOPO!
#if {${dc_sel} == "nodct"} {
#report_clock_tree -summary \
#                  -settings \
#                  -structure > \
#  ${out_rep}/${rm_project_top}.${i}.clock_tree
#}

query_objects -truncate 0 [all_registers -level_sensitive ] \
  > ${out_rep}/${rm_project_top}.${i}.latches

report_isolate_ports -nosplit > \
  ${out_rep}/${rm_project_top}.${i}.isolate_ports

# Zero interconnect delay mode to investigate potential design/floorplan problems
#set_zero_interconnect_delay_mode true
#report_timing -delay max \
#              -max_paths 50 \
#              -nosplit \
#              -path full_clock_expanded \
#              -nets \
#              -transition_time \
#              -input_pins > \
#  ${out_rep}/${rm_project_top}.${i}_zero-interconnect.timing

#report_qor > \
#  ${out_rep}/${rm_project_top}.${i}_zero-interconnect.qor
#set_zero_interconnect_delay_mode false


# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------

#Title:       rpt_cell.tcl
#
#Description: This Tcl procedure generates a cell
#             report of a design. 
#             It reports all cells and the following attributes:
#               b  - black box (unknown)
#               d  - has dont_touch attribute
#               h  - hierarchy
#               n  - noncombinational
#               t  - test cell
#
#Options:     -all_cells    one line per cell plus summary
#             -hier_only    every hierarchy cell and summary
#             -total_only   generate summary only
#
#Usage:       prompt> source rpt_cell.tcl
#             prompt> rpt_cell -t 
#
proc rpt_cell args {
   suppress_message UID-101
   
   set option [lindex $args 0]
   if {[string match -a* $option]} {
       echo " "
       echo "Attributes:"
       echo " b  - black-box (unknown)"
       echo " d  - dont_touch"
       echo " h  - hier"
       echo " n  - noncombo"
       echo " t  - test cell"
       echo " "
       echo [format "%-32s %-14s %5s %11s" "Cell" "Reference" "Area" "Attributes"]
       echo "-------------------------------------------------------------"
      } elseif {[string match -t* $option]} {
          set option "-total_only"
          echo ""
          set cd [current_design]
          echo "Performing cell count on [get_object_name $cd] ..." 
          echo " "
      } elseif {[string match -h* $option]} {
          set option "h";   # hierarchical only 
          echo ""
          set cd [current_design]
          echo "Performing hierarchical cell report on [get_object_name $cd] ..."
          echo " "
          echo [format "%-36s %-14s %11s" "Cell" "Reference" "Attributes"]
          echo "-----------------------------------------------------------------"
      } else {
          echo " "
          echo "  Message: Option Required"
          echo "  Usage: rpt_cell \[-all_cells\] \[-hier_only\] \[-total_only\]"
          echo " "
          return
      }
   
   # initialize summary vars
   set total_cells 0
   set dt_cells 0
   set hier_cells 0
   set hier_dt_cells 0
   set seq_cells 0
   set seq_dt_cells 0
   set test_cells 0
   set total_area 0

   # initialize other vars
   set hdt ""
   set tc_atr ""
   set xcell_area 0

   # create a collection of all cell objects
   set all_cells [get_cells -hierarchical *]

   foreach_in_collection cell $all_cells {
      incr total_cells
   
      set cell_name [get_attribute $cell full_name]
      set dt [get_attribute $cell dont_touch]
   
      if {$dt=="true"} {
          set dt_atr "d"
          incr dt_cells
         } else {
          set dt_atr ""
         }
   
      set ref_name [get_attribute $cell ref_name]
      set cell_area [get_attribute $cell area]
   
      if {$cell_area > 0} {
        set xcell_area $cell_area
        } else {
        set cell_area 0
      }
   
      set t_cell [get_attribute $cell is_a_test_cell]
      if {$t_cell=="true"} {
        set tc_atr "t"
        incr test_cells
        } else {
        set tc_atr ""
      }
      set hier [get_attribute $cell is_hierarchical]
      set combo [get_attribute $cell is_combinational]
      set seq [get_attribute $cell is_sequential]
   
      if {$hier} {
        set attribute "h"
        incr hier_cells
        set hdt [concat $option $hier]
        if {$dt_atr=="d"} {
          incr hier_dt_cells
        }
        } elseif {$seq} {
        set attribute "n"
        incr seq_cells
        if {$dt_atr=="d"} {
          incr seq_dt_cells
        }
        set total_area [expr $total_area + $xcell_area]
        } elseif {$combo} {
        set attribute ""
        set total_area [expr $total_area + $xcell_area]
        } else {
        set attribute "b"
      }
   
      if {[string match -a* $option]} {
       echo [format "%-32s %-14s %5.2f %2s %1s %1s" $cell_name $ref_name \
             $cell_area $attribute $dt_atr $tc_atr]
      } elseif {$hdt=="h true"} {
          echo [format "%-36s %-14s %2s" $cell_name $ref_name $attribute \
                 $dt_atr]
          set hdt ""
        }
     } ; # close foreach_in_collection

   echo "-----------------------------------------------------------------"
   echo [format "%10s Total Cells" $total_cells]
   echo [format "%10s Cells with dont_touch" $dt_cells]
   echo ""
   echo [format "%10s Hierarchical Cells" $hier_cells]
   echo [format "%10s Hierarchical Cells with dont_touch" $hier_dt_cells]
   echo ""
   echo [format "%10s Sequential Cells (incl Test Cells)" $seq_cells]
   echo [format "%10s Sequential Cells with dont_touch" $seq_dt_cells]
   echo ""
   echo [format "%10s Test Cells" $test_cells]
   echo ""
   echo [format "%10.2f Total Cell Area" $total_area]
   echo "-----------------------------------------------------------------"
   echo ""
 }


 define_proc_attributes rpt_cell \
   -info "Procedure to report all cells in the design" \
   -define_args {
   {-a "report every cell and the summary"}
   {-h "report only hierarchical cells and the summary"}
   {-t "report the summary only"} }

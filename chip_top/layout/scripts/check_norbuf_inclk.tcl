### Usage: Check BUF in clk path and create file to size BUF to CLKBUF

set out "./size_buf_to_clkbuf.txt"
set out2 "./swap_norbuf_toclk.tcl"

set files [open $out w]

set cells [get_cells -hierarchical -filter "ref_name=~NBL_NID*"]

foreach_in_collection cell $cells {
        set nets [get_nets -of_object $cell]
        foreach_in_collection net $nets {
		set type [get_attribute [get_object_name $net] -value_list "net_type"] 
                if { $type == "Clock" } {
			echo "\[INFO\]: find normal BUF: [get_object_name $cell] in clk net: [get_object_name $net]"
			set ref [get_attribute [get_cells $cell] ref_name]
			set cmd "size_cell \[get_cells [get_object_name $cell]\] $ref"
			puts $files "$cmd"
                }
        }
}

echo "\[INFO\]: Please source $out2 to fix"

close $files

exec cat $out | sort -u | sed "s/NBL_NID/NBL_CKNID/g" > $out2
exec rm -rf $out 

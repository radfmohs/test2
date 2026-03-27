### Usage: Check CLKBUF in data path and create file to size CLKBUF to BUF

set out "./size_clkbuf_to_normal.txt"
set out2 "./swap_clkbuf_tonor.tcl"
set files [open $out w]

set cells [get_cells -hierarchical -filter "ref_name=~*NBL_CKNID*"]

foreach_in_collection cell $cells {
        set nets [get_nets -of_object $cell]
	set i 0
        foreach_in_collection net $nets {
		set type [get_attribute [get_object_name $net] -value_list "net_type"] 
                if { $type == "Signal" } {
			incr i
			if {$i==2} {
				echo "\[INFO\]: find CLKBUF: [get_object_name $cell] in data net: [get_object_name $net]"
				set ref [get_attribute [get_cells $cell] ref_name]
				set cmd "size_cell \[get_cells [get_object_name $cell]\] $ref"
				puts $files "$cmd"
			}
                }
        }
}

echo "\[INFO\]: Please source $out2 to fix"

close $files

exec cat $out | sort -u | sed "s/NBL_CKNID/NBL_NID/g" > $out2
exec rm -rf $out 

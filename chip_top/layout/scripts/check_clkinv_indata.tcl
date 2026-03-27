### Usage: Check CLKINV in data path and create file to size CLKINV to INV

set out	"./script/size_clkinv_to_normal.txt"
set out2 "./script/2.1.clkinv_filter.tcl"

set files [open $out w]

set cells [get_cells -hierarchical -filter "ref_name=~*NBL_CKIVD*"]

foreach_in_collection cell $cells {
        set nets [get_nets -of_object $cell]
	set i 0
        foreach_in_collection net $nets {
		set type [get_attribute [get_object_name $net] -value_list "net_type"] 
                if { $type == "Signal" } {
			incr i
			if {$i==2} {
				echo "\[INFO\]: find CLKINV: [get_object_name $cell] in data net: [get_object_name $net]"
				set ref [get_attribute [get_cells $cell] ref_name]
				set cmd "size_cell \[get_cells [get_object_name $cell]\] $ref"
				puts $files "$cmd"
			}
                }
        }
}

echo "\[INFO\]: Please source $out2 to fix"

close $files

exec cat $out | sort -u | sed "s/NBL_CKIVD/NBL_IVD/g" > $out2
exec rm -rf $out 

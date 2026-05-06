proc find_and_remove_fully_floating_modules {} {
    set all_instances [get_cells -hier *]
    set instances_to_remove [list]

    foreach_in_collection instance $all_instances {
        set output_pins [get_pins -of $instance -filter "direction==out"]
        set total_outputs [sizeof_collection $output_pins]

        if {$total_outputs == 0} { continue }

        set floating_outputs 0
        foreach_in_collection pin $output_pins {
            set net [get_nets -of $pin -segments]
            if {[sizeof_collection $net] == 0} {
                incr floating_outputs
            }
        }

        # Flag the INSTANCE, not the module type
        if {$floating_outputs == $total_outputs} {
            set inst_name [get_attribute $instance full_name]
            set module_name [get_attribute $instance ref_name]
            puts "WARNING: Instance $inst_name (ref: $module_name) has ALL outputs floating marking for removal"
            lappend instances_to_remove $instance
        }
    }

    if {[llength $instances_to_remove] == 0} {
        puts "INFO: No instances with ALL outputs floating found."
        return
    }

    puts "INFO: Removing [llength $instances_to_remove] floating instances..."
    foreach inst $instances_to_remove {
        set inst_name [get_attribute $inst full_name]
        puts "  Removing: $inst_name"
        remove_cell $inst
    }

    puts "INFO: Done."
}

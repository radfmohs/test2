# TCL Script to find and remove modules where ALL outputs are floating

proc find_and_remove_fully_floating_modules {} {
    # Get all hierarchical instances
    set all_instances [get_cells -hier *]
    
    # Initialize list to store modules where ALL outputs are floating
    set fully_floating_modules [list]
    
    # Iterate through all instances
    foreach_in_collection instance $all_instances {
        set module_name [get_attribute $instance ref_name]
        
        # Skip if we've already processed this module type
        if {[lsearch $fully_floating_modules $module_name] != -1} {
            continue
        }
        
        # Get all output pins of this instance
        set output_pins [get_pins -of $instance -filter "direction==out"]
        set total_outputs [sizeof_collection $output_pins]
        set floating_outputs 0
        
        # Skip if no outputs
        if {$total_outputs == 0} {
            continue
        }
        
        # Check each output pin
        foreach_in_collection pin $output_pins {
            set net [get_nets -of $pin -segments]
            if {[sizeof_collection $net] == 0} {
                incr floating_outputs
            }
        }
        
        # If ALL outputs are floating, mark this module for removal
        if {$floating_outputs == $total_outputs} {
            lappend fully_floating_modules $module_name
            puts "WARNING: Module $module_name has ALL outputs floating in instance [get_attribute $instance full_name]"
        }
    }
    
    # Report findings
    if {[llength $fully_floating_modules] == 0} {
        puts "INFO: No modules with ALL outputs floating found in the design."
        return
    } else {
        puts "INFO: Found [llength $fully_floating_modules] modules with ALL outputs floating:"
        foreach mod $fully_floating_modules {
            puts "  - $mod"
        }
    }
    
    # Remove these modules from the netlist
    puts "INFO: Removing identified modules with ALL outputs floating..."
    foreach mod $fully_floating_modules {
        set instances_to_remove [get_cells -hier -filter "ref_name==$mod"]
        
        foreach_in_collection inst $instances_to_remove {
            set inst_name [get_attribute $inst full_name]
            puts "  Removing instance: $inst_name"
            remove_cell $inst
        }
    }
    
    puts "INFO: Removal of fully floating modules completed."
}

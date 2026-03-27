
create_power_domain Nanochap_ENS2
#tmp remove_net VDD_DIG
#tmp remove_net VSS_DIG
#tmp remove_port VDD_DIG
#tmp remove_port VSS_DIG
#tmp 
#tmp create_supply_port VDD_DIG -domain Nanochap_ENS2
#tmp create_supply_port VSS_DIG -domain Nanochap_ENS2
 create_supply_net VDD_DIG -domain Nanochap_ENS2
 create_supply_net VSS_DIG -domain Nanochap_ENS2
#tmp connect_supply_net VSS_DIG -ports VSS_DIG
#tmp connect_supply_net VDD_DIG -ports VDD_DIG
#tmp 
#tmp set_scope u_top_ana_wrapper 
#tmp remove_port VDD_DIG
#tmp remove_port VSS_DIG
#tmp #remove_net VDD_DIG
#tmp #remove_net VSS_DIG
#tmp #create_supply_port VDD_DIG -domain Nanochap_ENS2
#tmp #create_supply_port VSS_DIG -domain Nanochap_ENS2
#tmp #connect_supply_net VSS_DIG -ports VSS_DIG
#tmp #connect_supply_net VDD_DIG -ports VDD_DIG
#tmp create_supply_port VDD_DIG
#tmp create_supply_port VSS_DIG
#tmp set_scope  /
#tmp set_scope  /
#tmp connect_supply_net VDD_DIG -ports {u_top_ana_wrapper/VDD_DIG }
#tmp connect_supply_net VSS_DIG -ports {u_top_ana_wrapper/VSS_DIG }
#tmp 
#tmp set_scope u_top_dig
#tmp create_supply_port VDD_DIG
#tmp create_supply_port VSS_DIG
#tmp create_supply_net VDD_DIG
#tmp create_supply_net VSS_DIG
#tmp #remove_port VDD_OTP
#tmp #remove_port VSS_OTP
#tmp #remove_net VDD_OTP
#tmp #remove_net VSS_OTP
#tmp #create_supply_port VDD_OTP
#tmp #create_supply_port VSS_OTP
#tmp #create_supply_net VDD_OTP
#tmp #create_supply_net VSS_OTP
#tmp #connect_supply_net VDD_DIG -ports {VDD_OTP }
#tmp #connect_supply_net VSS_DIG -ports {VSS_OTP }
#tmp set_scope  /
#tmp set_scope  /
#tmp connect_supply_net VDD_DIG -pins {u_top_dig/VDD_DIG }
#tmp connect_supply_net VDD_DIG -pins {u_top_dig/VDD_OTP }
#tmp connect_supply_net VSS_DIG -pins {u_top_dig/VSS_DIG }
#tmp connect_supply_net VSS_DIG -pins {u_top_dig/VSS_OTP }
#tmp connect_supply_net VSS_DIG -pins {u_top_dig/VSUB_OTP }
#tmp #set_scope u_top_ana_wrapper/u_top_ana
#tmp #create_supply_port VDD_DIG
#tmp #create_supply_port VSS_DIG
#tmp #set_scope  /
#tmp #set_scope  /
#tmp #set_scope  /
#tmp #set_scope  /
#tmp #connect_supply_net VDD_DIG -ports {u_top_ana_wrapper/u_top_ana/VDD_DIG }
#tmp #connect_supply_net VSS_DIG -ports {u_top_ana_wrapper/u_top_ana/VSS_DIG }

set_domain_supply_net Nanochap_ENS2 -primary_power_net VDD_DIG -primary_ground_net VSS_DIG


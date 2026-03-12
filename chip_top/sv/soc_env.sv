/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_env.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC Top Environment                                      
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
class soc_env extends nnc_env;

    soc_virtual_sequencer      top_sqr;

   // nnc_spi_env                spi_env_i;
    nnc_analog_env             ana_env;
//  timer_env                  timer_env_i;

//  soc_sys_ctrl_env           soc_sys_ctrl_env_i;

//  virtual nnc_spi_vip_if     top_spi_if;

    soc_chip_cfg               top_cfg;
`ifndef OTP_ENABLE
    nnc_eeprom_env             eeprom_env;
    `else
    nnc_eprom_env              eprom_env;    
`endif

    nnc_sysc_environment       sysc_env;
    nnc_boost_env              boost_env;
    nnc_imeas_env              imeas_env;
    nnc_lead_off_env           lead_off_env;
    nnc_wavegen_env            wavegen_env;
    nnc_pinmux_env             pinmux_env;
    nnc_spi_mon_env            spi_mon_env_i;
    //virtual  nnc_spi_if             spi_mon_if;                       
    virtual  nnc_spi_interface      spi_vif;
    virtual  nnc_boost_interface    boost_vif;
    virtual  nnc_imeas_if           imeas_vif;                       
    virtual  nnc_lead_off_interface lead_off_vif;                       
    virtual  nnc_wavegen_interface  wavegen_vif[`WAVEGEN_NUM_OF_MULT_CHIPS];
    virtual  nnc_pinmux_interface   pinmux_vif;    

    
    `nnc_component_utils(soc_env)

    function new(string name, nnc_component parent);
        super.new(name, parent);
        //nnc_spi_vip_pkg::spi_vip_rstn = top_sqr.dut_if.resetn; 
    endfunction

    virtual function void build_phase(nnc_phase phase);
        `nnc_info(get_name(), "Build phase is starting", UVM_HIGH);
        super.build_phase(phase);
        
        top_cfg = new("top_cfg");
        top_sqr = soc_virtual_sequencer::type_id::create("top_sqr", this);
`ifndef OTP_ENABLE
        eeprom_env = nnc_eeprom_env::type_id::create("eeprom_env", this);
        //analog_env_i = soc_analog_env::type_id::create("analog_env_i",this);          
    `else
        eprom_env = nnc_eprom_env::type_id::create("eprom_env", this);
`endif
        boost_env = nnc_boost_env::type_id::create("boost_env", this);
        imeas_env = nnc_imeas_env::type_id::create("imeas_env",this);
        lead_off_env = nnc_lead_off_env::type_id::create("lead_off_env",this);

        wavegen_env = nnc_wavegen_env::type_id::create("wavegen_env",this);
        pinmux_env = nnc_pinmux_env::type_id::create("pinmux_env",this);
        //spi_env_i = nnc_spi_env::type_id::create("spi_env_i", this);
        sysc_env = nnc_sysc_environment::type_id::create("sysc_env", this);
        spi_mon_env_i = nnc_spi_mon_env::type_id::create("spi_mon_env_i", this);
        ana_env = nnc_analog_env::type_id::create("ana_env", this);

        if (!nnc_config_db#(soc_chip_cfg)::get(this, "", "top_cfg", top_cfg))
          `nnc_fatal("TOP_ENV_BUILD_PHASE", "Can't get top_cfg")
        nnc_config_db#(soc_chip_cfg)::set(this, "*", "top_cfg", top_cfg);
`ifndef OTP_ENABLE
        nnc_config_db#(nnc_eeprom_config)::set(this, "eeprom_env", "eeprom_cfg", top_cfg.eeprom_cfg);
    `else
        nnc_config_db#(nnc_eprom_config)::set(this, "eprom_env", "eprom_cfg", top_cfg.eprom_cfg);
`endif
        //nnc_config_db#(soc_analog_config)::set(this, "analog_env_i.*","analog_cfg", top_cfg.analog_cfg);
        nnc_config_db#(nnc_sysc_config)::set(this, "sysc_env.*", "sysc_cfg", top_cfg.sysc_cfg);          
        nnc_config_db#(nnc_spi_monitor_config)::set(this, "spi_mon_env_i", "spi_mon_cfg", top_cfg.spi_cfg);
        nnc_config_db#(nnc_boost_config)::set(this, "boost_env*", "boost_cfg", top_cfg.boost_cfg);
        nnc_config_db#(nnc_imeas_cfg)::set(this, "imeas_env", "cfg", top_cfg.imeas_cfg);
        nnc_config_db#(nnc_lead_off_config)::set(this, "lead_off_env*", "lead_off_cfg", top_cfg.lead_off_cfg);
        nnc_config_db#(nnc_pinmux_config)::set(this, "pinmux_env*", "pinmux_cfg", top_cfg.pinmux_cfg);

        for(int i = 0; i< `WAVEGEN_NUM_OF_MULT_CHIPS ;i++) begin
          //wavegen_cfg[i].wavegen_no_of_chips = `WAVEGEN_NUM_OF_MULT_CHIPS;
          nnc_config_db#(nnc_wavegen_config)::set(this, "*", $sformatf("wavegen_cfg[%0d]",i), top_cfg.wavegen_cfg[i]);
        end

        nnc_config_db#(nnc_analog_config)::set(this, "ana_env.*", "ana_cfg", top_cfg.ana_cfg);
        //if (!nnc_config_db#(virtual nnc_spi_if)::get(this, "", "spi_mon_if", spi_mon_if))
        //  `nnc_fatal("ENS2_CHIP_ENV", "Can't get spi_mon_if")
        //nnc_config_db#(virtual nnc_spi_if)::set(this, "spi_mon_env_i.*", "spi_mon_if", spi_mon_if);


        if (!nnc_config_db#(virtual nnc_spi_interface)::get(this, "", "spi_vif", spi_vif))
          `nnc_fatal("ENS2_CHIP_ENV", "Can't get spi_vif")
        nnc_config_db#(virtual nnc_spi_interface)::set(this, "spi_mon_env_i.*", "spi_vif", spi_vif);

        if (!nnc_config_db#(virtual nnc_boost_interface)::get(this, "", "boost_vif", boost_vif))
          `nnc_fatal("ENS2_CHIP_ENV", "Can't get boost_vif")
        nnc_config_db#(virtual nnc_boost_interface)::set(this, "boost_env.*", "boost_vif", boost_vif);

        if (!nnc_config_db#(virtual nnc_imeas_if)::get(this, "", "imeas_vif", imeas_vif))
          `nnc_fatal("ENS2_CHIP_ENV", "Can't get imeas_vif")
        nnc_config_db#(virtual nnc_imeas_if)::set(this, "imeas_env.*", "imeas_vif", imeas_vif);

        if (!nnc_config_db#(virtual nnc_lead_off_interface)::get(this, "", "lead_off_vif", lead_off_vif))
          `nnc_fatal("ENS2_CHIP_ENV", "Can't get lead_off_vif")
        nnc_config_db#(virtual nnc_lead_off_interface)::set(this, "lead_off_env.*", "lead_off_vif", lead_off_vif);

        if (!nnc_config_db#(virtual nnc_pinmux_interface)::get(this, "", "pinmux_vif", pinmux_vif))
          `nnc_fatal("ENS2_CHIP_ENV", "Can't get pinmux_vif")
        nnc_config_db#(virtual nnc_pinmux_interface)::set(this, "pinmux_env.*", "pinmux_vif", pinmux_vif);


        for(int i = 0; i< `WAVEGEN_NUM_OF_MULT_CHIPS ;i++) begin
          if (!nnc_config_db#(virtual nnc_wavegen_interface)::get(this, "", $sformatf("wavegen_vif[%0d]",i), wavegen_vif[i]))
            `nnc_fatal("ENS2_CHIP_ENV", $sformatf("Can't get wavegen_vif[%0d]",i))
          nnc_config_db#(virtual nnc_wavegen_interface)::set(this, "nnc_wavegen_env[i].*", "wavegen_vif", wavegen_vif[i]);
        end

        //if (!nnc_config_db#(virtual spi_master_if)::get(this, "", "m_spiif", m_spiif))
        //  `nnc_fatal("ENS2_CHIP_ENV", "Can't get m_spiif")

        //nnc_config_db#(virtual spi_master_if)::set(this, "spi_mon_env_i", "m_spiif", m_spiif);

        //if (!nnc_config_db#(virtual spi_slave_if)::get(this, "", "s_spiif", s_spiif))
        //  `nnc_fatal("ENS2_CHIP_ENV", "Can't get s_spiif")

        //nnc_config_db#(virtual spi_slave_if)::set(this, "spi_mon_env_i", "s_spiif", s_spiif);

        //if (!nnc_config_db#(virtual timer_if)::get(this, "", "vif", vif))
        //  `nnc_fatal("ENS2_CHIP_ENV", "Can't get vif")

        //nnc_config_db#(virtual timer_if)::set(this, "timer_env_i", "vif", vif);

    endfunction

    virtual function void connect_phase(nnc_phase phase);
        `nnc_info(get_name(), "Connect phase is starting", UVM_HIGH);
        super.connect_phase(phase);
    endfunction

endclass

//========================================================================================================  
// -------------------------------------------------------------------------------------------------------  
//  Nanochap Electronics Copyright (C) 2014. ALL RIGHTS RESERVED.  
// -------------------------------------------------------------------------------------------------------  
// Project name    : ENS2
// File name       : soc_py_tb.sv
// Description     : Testbench to support Python Environment  
// -------------------------------------------------------------------------------------------------------  
// Revision History:  
// -------------------------------------------------------------------------------------------------------  
// Revision       Date(dd-mm-yyyy)     Author                       Description  
// -------------------------------------------------------------------------------------------------------  
//   1.0          24-03-2024          ddang@nanochap.com            Initial version
// -------------------------------------------------------------------------------------------------------  
//========================================================================================================
//`define SERIAL_BIT_PY_NUM 1000000000-1
//`define IMEAS_DATA_SIZE 32
//`define ONE_IMEAS_SIZE 5120*`IMEAS_DATA_SIZE
//`define ALL_IMEAS_SIZE 16*`ONE_IMEAS_SIZE // 16: ADCs - 5120: points (16Khz), 32-bit data
module soc_py_tb ();
assign `SOC_TB.dut_vif.python_imeas_length = `IMEAS_DATA_SIZE;
assign `SOC_TB.dut_vif.python_filter_length = `IMEAS_DATA_SIZE;

integer python_size;
assign `SOC_TB.dut_vif.python_length = 10000;
assign python_size = `SOC_TB.dut_vif.python_length*32-1;

integer python_data_num_0 = 0;
integer python_data_num_1 = 0;
integer python_data_num;

bit [31 :0] imeas_data_num = 0;
bit [31 :0] filter_data_num = 0;

bit [31 :0] imeas_chnum;
bit [31 :0] filter_chnum; 

bit [`SERIAL_BIT_PY_NUM-1:0] local_data_0;
bit [`SERIAL_BIT_PY_NUM-1:0] local_data_1;
bit [`ALL_IMEAS_SIZE-1:0]    local_data_imeas; 
// 32-bit_width of sample data * ADC_NUM(1) * `SOC_TB.dut_vif.python_imeas_length (Input filter - IMEAS output)

bit [`ALL_IMEAS_SIZE-1:0] local_data_filter;
// 32-bit_width of sample data * ADC_NUM(16) * `SOC_TB.dut_vif.python_imeas_length (output filter - Filter output)

wire [`SERIAL_BIT_PY_NUM:0]   local_data;

bit [7:0]           local_data_out;
bit [31 :0]         local_len ;
bit [127 :0]        local_mode;

bit [32*32-1:0]     config_data;
bit [32*32-1:0]     config_data_imeas;

assign `SOC_TB.dut_vif.python_wavegen_en = `SOC_TB.dut_vif.python_check_en;

/************************************************************************************************************************************************************************************************/
/**************************************************************************************** WAVEGEN SETTINGS **************************************************************************************/
/************************************************************************************************************************************************************************************************/
assign config_data = {

     // ---------------------------------------
     // Word-31 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-30 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-29 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-28 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-27 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-26 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-25 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-24 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-23 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-22 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-21 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-20 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-19 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-18 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-17 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-16 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-15 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-14 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-13 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-12 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-11 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-10 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-9 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-8 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-7 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-6 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-5 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-4 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-3 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-2 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-1 for Wavegen Configuratiion
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-0 for Wavegen Configuratiion
     // ---------------------------------------
     {`SOC_TB.dut_vif.python_wavegen_en, // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_drive, // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_drv_pnt_cfg, // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_drv_cfg, // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_drv_ctrl, // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_silent_wave2_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_rest_wave2_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_silent_wave1_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_rest_wave1_lim[0],  // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_silent_wave0_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_rest_wave0_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_neg_hlf_wave2_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_hlf_wave2_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_neg_hlf_wave1_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_hlf_wave1_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_neg_hlf_wave0_lim[0], // 1-bit - bit-31
     `SOC_TB.dut_vif.wg_hlf_wave0_lim[0]} // 1-bit - bit-31
     };

/************************************************************************************************************************************************************************************************/
/**************************************************************************************** WAVEGEN DATA COLLECTION *******************************************************************************/
/************************************************************************************************************************************************************************************************/
logic pos_stick1, pos_stick2;
logic neg_stick1, neg_stick2;

logic dac0_tag, dac1_tag;

integer seed;
initial
  begin
    pos_stick1 = 0;
    pos_stick2 = 0;
    dac0_tag = 0;
    dac1_tag = 0;
    #1;
    seed = $get_initial_random_seed();
  end

logic [1000000:0] wr_data;
bit  [1000000:0] rd_data;

logic [7:0] wavegen_addr0;
logic [7:0] wavegen_addr1;

logic [7:0] wavegen_addr0_buff;
logic [7:0] wavegen_addr1_buff;

`ifndef BEHAVIORAL
assign wavegen_addr0 = `WG_DRIVER_TOP.wg_driver_top_inst.in_wave_addr[7:0];
assign wavegen_addr1 = `WG_DRIVER_TOP.wg_driver_top_inst.in_wave_addr[15:8];
`else
assign wavegen_addr0 = `WG_DRIVER_TOP.wg_driver_top_inst.in_wave_addr[dut_vif.DRIVE_SLCT*4+0][7:0];
assign wavegen_addr1 = `WG_DRIVER_TOP.wg_driver_top_inst.in_wave_addr[dut_vif.DRIVE_SLCT*4+1][7:0];
`endif

always @(negedge `WG_DRIVER_TOP.i_pclk)  
  begin
    if ((pos_stick1 == 1'b0) && (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+0] === 1'b0)) begin
      `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, 1'b0, `WG_DRIVER_TOP.o_out_wave_driver_idac[dut_vif.DRIVE_SLCT*4+0][11:0]};//bit[15:13] = drv_num; bit[12]= pos/neg indication (1: neg, 0: pos); bit[11:0] dac data
      local_data_0 = `SOC_TB.dut_vif.python_data_dac0[python_data_num_0];
    end else if (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+0] === 1'b1) begin
      pos_stick1 = 1;
    end 
  end

always @(negedge `WG_DRIVER_TOP.i_pclk)
  begin
    if ((pos_stick2 == 1'b0) && (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+1] === 1'b0)) begin
      `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, 1'b0, `WG_DRIVER_TOP.o_out_wave_driver_idac[dut_vif.DRIVE_SLCT*4+1][11:0]};//bit[15:13] = drv_num; bit[12]= pos/neg indication (1: neg, 0: pos); bit[11:0] dac data
      local_data_1 = `SOC_TB.dut_vif.python_data_dac1[python_data_num_1];
    end else if (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+1] === 1'b1) begin
      pos_stick2 = 1;
    end
  end

wire match_pos_dac0 = (`WG_DRIVER_TOP.o_source_driver[0] === 1'b1) && (`WG_DRIVER_TOP.o_source_driver[0] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b1);
wire match_neg_dac0 = (`WG_DRIVER_TOP.o_source_driver[0] === 1'b1) && (`WG_DRIVER_TOP.o_source_driver[0] === 1'b1) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b1) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b0);
wire match_dac0 = (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+0] === 1'b1) ;//match_pos_dac0 || match_neg_dac0;
wire special_match_dac0 = (`WG_DRIVER_TOP.o_source_driver[0] === 1'b0) && (`WG_DRIVER_TOP.o_source_driver[0] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[0] === 1'b0) && ((wavegen_addr0 % 4) === 0);

wire match_pos_dac1 = (`WG_DRIVER_TOP.o_source_driver[1] === 1'b1) && (`WG_DRIVER_TOP.o_source_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b1);
wire match_neg_dac1 = (`WG_DRIVER_TOP.o_source_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_source_driver[1] === 1'b1) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b1) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b0);
wire match_dac1 = (`WG_DRIVER_TOP.o_source_driver[dut_vif.DRIVE_SLCT*4+0] === 1'b1) ;//match_pos_dac1 || match_neg_dac1;
wire special_match_dac1 = (`WG_DRIVER_TOP.o_source_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_source_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b0) && (`WG_DRIVER_TOP.o_pulldn_driver[1] === 1'b0) && ((wavegen_addr1 % 4) === 0);

always @(wavegen_addr0)
begin
  if ((`WG_DRIVER_TOP.i_presetn == 1'b1) && (python_data_num_0 < `SOC_TB.dut_vif.python_length) && (`SOC_TB.dut_vif.python_wavegen_en === 1'b1)) begin
 
    if (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1) begin
       if (wavegen_addr0 == 0) begin
         @(negedge `WG_DRIVER_TOP.i_pclk);
         if ((wavegen_addr0 == 0) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b0)) dac0_tag = !dac0_tag;
         if ((wavegen_addr0 == 1) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1)) dac0_tag = !dac0_tag; 
         #1;
         if (pos_stick1 == 1) begin
           python_data_num_0++;
           `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
         end
       end else if (wavegen_addr0 == 1)  begin
         if (pos_stick1 == 0) begin
           #1;
           if ((wavegen_addr0 == 0) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b0)) dac0_tag = !dac0_tag;
           if ((wavegen_addr0 == 1) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1)) dac0_tag = !dac0_tag;
         end else begin
           if ((wavegen_addr0 == 0) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b0)) dac0_tag = !dac0_tag;
           if ((wavegen_addr0 == 1) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1)) dac0_tag = !dac0_tag;
           @(negedge `WG_DRIVER_TOP.i_pclk);
           #1;
           python_data_num_0++;
           `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
         end
       end else if (wavegen_addr0 > 1) begin
         @(negedge `WG_DRIVER_TOP.i_pclk);
         #1;
         if ((wavegen_addr0 == 0) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b0)) dac0_tag = !dac0_tag;
         if ((wavegen_addr0 == 1) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1)) dac0_tag = !dac0_tag;
         if ((pos_stick1 == 1) && (special_match_dac0 === 1'b0)) begin
           wait (match_dac0);
           python_data_num_0++;
           `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
         end
         else if ((pos_stick1 == 1) && (special_match_dac0 === 1'b1)) begin
           python_data_num_0++;
           `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
         end
       end
    end else begin
       @(posedge `WG_DRIVER_TOP.i_pclk);
       @(negedge `WG_DRIVER_TOP.i_pclk);
       if ((wavegen_addr0 == 0) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b0)) dac0_tag = !dac0_tag;
       if ((wavegen_addr0 == 1) && (pos_stick1 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac0 === 1'b1)) dac0_tag = !dac0_tag;
       wait (match_dac0); 
       python_data_num_0++;
       if (match_pos_dac0) `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
       if (match_neg_dac0) `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0] = {3'b110, dac0_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[0][11:0]};
    end

    if (`SOC_TB.dut_vif.testmode_sel === 2'b00) begin
      `nnc_info("WAVEGEN INFO", $sformatf("WAVEGEN IS SENDING DATA[%d]: %h", python_data_num_0, `SOC_TB.dut_vif.python_data_dac0[python_data_num_0][15:0]),UVM_DEBUG);
      local_data_0 = local_data_0 | ({16'h0, `SOC_TB.dut_vif.python_data_dac0[python_data_num_0]} << (32*python_data_num_0));
    end
  end
end

always @(wavegen_addr1)
begin
  if ((`WG_DRIVER_TOP.i_presetn == 1'b1) && (python_data_num_1 < `SOC_TB.dut_vif.python_length) && (`SOC_TB.dut_vif.python_wavegen_en === 1'b1)) begin

    if (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1) begin
       if (wavegen_addr1 == 0) begin
         @(negedge `WG_DRIVER_TOP.i_pclk);
         #1;
         if ((wavegen_addr1 == 0) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b0)) dac1_tag = !dac1_tag;
         if ((wavegen_addr1 == 1) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1)) dac1_tag = !dac1_tag; 
         if (pos_stick2 == 1) begin
           python_data_num_1++;
           `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
         end
       end else if (wavegen_addr1 == 1)  begin
         if (pos_stick2 == 0) begin
           #1;
           if ((wavegen_addr1 == 0) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b0)) dac1_tag = !dac1_tag;
           if ((wavegen_addr1 == 1) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1)) dac1_tag = !dac1_tag;
         end
         else begin
           @(negedge `WG_DRIVER_TOP.i_pclk);
           if ((wavegen_addr1 == 0) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b0)) dac1_tag = !dac1_tag;
           if ((wavegen_addr1 == 1) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1)) dac1_tag = !dac1_tag;
           #1;
           python_data_num_1++;
           `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
         end
       end else if (wavegen_addr1 > 1) begin
         @(negedge `WG_DRIVER_TOP.i_pclk);
         if ((wavegen_addr1 == 0) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b0)) dac1_tag = !dac1_tag;
         if ((wavegen_addr1 == 1) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1)) dac1_tag = !dac1_tag;
         #1;
         if ((pos_stick2 == 1) && (special_match_dac1 === 1'b0)) begin
             wait (match_dac1);
             python_data_num_1++;
             `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
         end
         else if ((pos_stick2 == 1) && (special_match_dac1 === 1'b1)) begin
             python_data_num_1++;
             `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
         end
       end
    end else begin
       @(posedge `WG_DRIVER_TOP.i_pclk);
       @(negedge `WG_DRIVER_TOP.i_pclk);
       if ((wavegen_addr1 == 0) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b0)) dac1_tag = !dac1_tag;
       if ((wavegen_addr1 == 1) && (pos_stick2 == 1) && (`SOC_TB.dut_vif.clk_per_point_short_dac1 === 1'b1)) dac1_tag = !dac1_tag;
       wait (match_dac1); 
       python_data_num_1++;
       if (match_pos_dac1) `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
       if (match_neg_dac1) `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16] = {3'b111, dac1_tag, `WG_DRIVER_TOP.o_out_wave_driver_idac[1][11:0]};
    end

    if (`SOC_TB.dut_vif.testmode_sel === 2'b00) begin
      `nnc_info("WAVEGEN INFO", $sformatf("WAVEGEN IS SENDING DATA[%d]: %h", python_data_num_1, `SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16]),UVM_DEBUG);
      local_data_1 = local_data_1 | ({`SOC_TB.dut_vif.python_data_dac1[python_data_num_1][31:16], 16'h0} << (32*python_data_num_1));
    end
  end
end

/************************************************************************************************************************************************************************************************/
/**************************************************************************************** IMEAS SETTINGS ****************************************************************************************/
/************************************************************************************************************************************************************************************************/
assign config_data_imeas = {
     // -------------------------------------------------------
     // Word-0 to Word-31, Verifiers can use for your purposes
     // -------------------------------------------------------
     // Please add more here for IMEAS and Filters
     // -------------------------------------------------------

     // ---------------------------------------
     // Word-31 for IMEAS Configuration (total IMEAS elements)
     // ---------------------------------------
     32'd2580,

     // ---------------------------------------
     // Word-30 for IMEAS Configuration (total Filter elements)
     // ---------------------------------------
     32'd2580,

     // ---------------------------------------
     // Word-29 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-28 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-27 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-26 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-25 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-24 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-23 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-22 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-21 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-20 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-19 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-18 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-17 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-16 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-15 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-14 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-13 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-12 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-11 for IMEAS Configuration
     // ---------------------------------------
     32'h00000000,

     // ---------------------------------------
     // Word-10 for IMEAS Configuration
     // ---------------------------------------
     `SOC_TB.dut_vif.hpf_fc,

     // ---------------------------------------
     // Word-9 for IMEAS Configuration
     // ---------------------------------------

     {15'h0, `SOC_TB.dut_vif.filter_python_check_en, `SOC_TB.dut_vif.hpf_filter_en_per_ch},

     // ---------------------------------------
     // Word-8 for IMEAS Configuration
     // ---------------------------------------
     {`SOC_TB.dut_vif.lpf_filter_en_per_ch, `SOC_TB.dut_vif.notch_filter_en_per_ch},

     // ---------------------------------------
     // Word-7 for IMEAS Configuration
     // ---------------------------------------
     `SOC_TB.dut_vif.imeas_sin_expected_freq,

     // ---------------------------------------
     // Word-6 for IMEAS Configuration(fstop of lpf)
     // ---------------------------------------
     `SOC_TB.dut_vif.stopband_cut_off_freq,

     // ---------------------------------------
     // Word-5 for IMEAS Configuration(fpass of lpf)
     // ---------------------------------------
     `SOC_TB.dut_vif.passband_cut_off_freq,

     // ---------------------------------------
     // Word-4 for IMEAS Configuration(data_rate of filter)
     // ---------------------------------------
     `SOC_TB.dut_vif.imeas_samp_rate,

     // ---------------------------------------
     // Word-3 for IMEAS Configuration (element number from SV filter)
     // ---------------------------------------
     filter_data_num,

     // ---------------------------------------
     // Word-2 for IMEAS Configuration (element number from IMEAS filter)
     // ---------------------------------------
     imeas_data_num,

     // ---------------------------------------
     // Word-1 for IMEAS Configuration
     // ---------------------------------------
     imeas_chnum,

     // ---------------------------------------
     // Word-0 for IMEAS Configuration
     // ---------------------------------------
     `SOC_TB.dut_vif.output_format, // 2-bit [31:30]
     `SOC_TB.dut_vif.python_imeas_en, // 1-bit [29] - IMEAS CHECKER ENABLE
     `SOC_TB.dut_vif.imeas_noise_gen_en, // 1-bit [28]
     `SOC_TB.dut_vif.imeas_sample_num_per_period, // 12-bit 
     `SOC_TB.dut_vif.imeas_en_dis_ch[`ADC_NUM-1:0] // 16-bit
};


//assign `SOC_TB.dut_vif.python_imeas_en = `SOC_TB.dut_vif.imeas_sin_gen_en;

/************************************************************************************************************************************************************************************************/
/**************************************************************************************** IMEAS DATA COLLECTION *********************************************************************************/
/************************************************************************************************************************************************************************************************/

// =====================================================================
// Connect data from IMEAS to here (2560 words) - local_data_imeas
// =====================================================================
always @(negedge `CLK_CTRL_TOP.imeas_dig_adc_clk[imeas_chnum])
  if ((|`FILTER_WRAPPER_TOP.chdata_en == 1'b1) && (imeas_data_num < `SOC_TB.dut_vif.python_imeas_length) && (`SOC_TB.dut_vif.python_imeas_en === 1'b1)) begin

    for (int i=0; i <16; i++) begin 
      `SOC_TB.dut_vif.imeas_data[i] = `FILTER_WRAPPER_TOP.chdata[i] << imeas_data_num*32;
      if (`SOC_TB.dut_vif.testmode_sel === 2'b00)
        `nnc_info("IMEAS INFO", $sformatf("IMEAS IS SENDING DATA[%d]: %h", imeas_data_num, `SOC_TB.dut_vif.imeas_data[i]), UVM_DEBUG);
    end

    casez (`SOC_TB.dut_vif.imeas_en_dis_ch)
      16'h????_????_????_???0: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[0]; imeas_chnum = 0; end
      16'h????_????_????_??01: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[1]; imeas_chnum = 1; end
      16'h????_????_????_?011: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[2]; imeas_chnum = 2; end
      16'h????_????_????_0111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[3]; imeas_chnum = 3; end
      16'h????_????_???0_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[4]; imeas_chnum = 4; end
      16'h????_????_??01_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[5]; imeas_chnum = 5; end
      16'h????_????_?011_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[6]; imeas_chnum = 6; end
      16'h????_????_0111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[7]; imeas_chnum = 7; end
      16'h????_???0_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[8]; imeas_chnum = 8; end
      16'h????_??01_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[9]; imeas_chnum = 9; end
      16'h????_?011_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[10]; imeas_chnum = 10; end
      16'h????_0111_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[11]; imeas_chnum = 11; end
      16'h???0_1111_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[12]; imeas_chnum = 12; end
      16'h??01_1111_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[13]; imeas_chnum = 13; end
      16'h?011_1111_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[14]; imeas_chnum = 14; end
      16'h0111_1111_1111_1111: begin local_data_imeas = local_data_imeas | `SOC_TB.dut_vif.imeas_data[15]; imeas_chnum = 15; end
      default:                 begin local_data_imeas = local_data_imeas; imeas_chnum = 0; end
    endcase
/*
    local_data_imeas = local_data_imeas | 
       `SOC_TB.dut_vif.imeas_data[0] |
                       (`SOC_TB.dut_vif.imeas_data[1]  << (1*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[2]  << (2*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[3]  << (3*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[4]  << (4*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[5]  << (5*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[6]  << (6*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[7]  << (7*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[8]  << (8*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[9]  << (9*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[10] << (10*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[11] << (11*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[12] << (12*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[13] << (13*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[14] << (14*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.imeas_data[15] << (15*`ONE_IMEAS_SIZE));
    end
*/
    imeas_data_num++;
  end

// =====================================================================
// Connect data from Filters to here (2560 words) - local_data_filter
// =====================================================================
always @(negedge `FILTER_WRAPPER_TOP.pclk/*clk[filter_chnum]*/) // 16 clocks -> need to check
  if ((`IMEAS_WRAPPER_TOP.meas_done == 1'b1) && (filter_data_num < `SOC_TB.dut_vif.python_filter_length) && (`SOC_TB.dut_vif.python_imeas_en === 1'b1)) begin

    for (int i=0; i < 16; i++) begin
      `SOC_TB.dut_vif.filter_data[i] = `IMEAS_WRAPPER_TOP.imeas_chdata_out[i][31:0] << filter_data_num*32;
      if (`SOC_TB.dut_vif.testmode_sel === 2'b00)
        `nnc_info("FILTER INFO", $sformatf("FILTER IS OUTPUTTING DATA[%d]: %h", filter_data_num, `SOC_TB.dut_vif.filter_data[i]), UVM_DEBUG);
    end

    casez (`SOC_TB.dut_vif.imeas_en_dis_ch & (`SOC_TB.dut_vif.notch_filter_en_per_ch | `SOC_TB.dut_vif.lpf_filter_en_per_ch | `SOC_TB.dut_vif.hpf_filter_en_per_ch))
      16'h????_????_????_???0: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[0]; filter_chnum = 0; end
      16'h????_????_????_??01: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[1]; filter_chnum = 1; end
      16'h????_????_????_?011: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[2]; filter_chnum = 2; end
      16'h????_????_????_0111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[3]; filter_chnum = 3; end
      16'h????_????_???0_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[4]; filter_chnum = 4; end
      16'h????_????_??01_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[5]; filter_chnum = 5; end
      16'h????_????_?011_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[6]; filter_chnum = 6; end
      16'h????_????_0111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[7]; filter_chnum = 7; end
      16'h????_???0_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[8]; filter_chnum = 8; end
      16'h????_??01_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[9]; filter_chnum = 9; end
      16'h????_?011_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[10]; filter_chnum = 10; end
      16'h????_0111_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[11]; filter_chnum = 11; end
      16'h???0_1111_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[12]; filter_chnum = 12; end
      16'h??01_1111_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[13]; filter_chnum = 13; end
      16'h?011_1111_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[14]; filter_chnum = 15; end
      16'h0111_1111_1111_1111: begin local_data_filter = local_data_filter | `SOC_TB.dut_vif.filter_data[15]; filter_chnum = 15; end
      default:                 begin local_data_filter = local_data_filter; filter_chnum = 0; end
    endcase
/*

    local_data_filter = local_data_filter |
       `SOC_TB.dut_vif.filter_data[0] |
                       (`SOC_TB.dut_vif.filter_data[1]  << (1*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[2]  << (2*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[3]  << (3*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[4]  << (4*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[5]  << (5*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[6]  << (6*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[7]  << (7*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[8]  << (8*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[9]  << (9*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[10] << (10*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[11] << (11*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[12] << (12*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[13] << (13*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[14] << (14*`ONE_IMEAS_SIZE)) |
                       (`SOC_TB.dut_vif.filter_data[15] << (15*`ONE_IMEAS_SIZE));
*/
    filter_data_num++;
  end

/************************************************************************************************************************************************************************************************/
/**************************************************************************************** GENERAL SETTINGS **************************************************************************************/
/************************************************************************************************************************************************************************************************/

  
assign local_data = ((local_data_0 | local_data_1) << (2*32*32 + `ALL_IMEAS_SIZE*2)) | local_data_filter << (2*32*32 + `ALL_IMEAS_SIZE) | local_data_imeas << (2*32*32) | (config_data_imeas << (32*32)) | config_data; 
 
assign python_data_num = (python_data_num_0 > python_data_num_1) ? python_data_num_0 + 32 + 32 + `ALL_IMEAS_SIZE*2/32 : python_data_num_1 + 32 + 32 + `ALL_IMEAS_SIZE*2/32;

`include "/projects/libs/vips/py_lib/sv/nnc_python_api.sv"

`include "../tc/python/sv/soc_py_main_test.sv"

endmodule

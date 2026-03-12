//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2022
//
// Module Name : ENS2 Verification 
// Description : SPI OP_CMD Test
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author  jayanthi
//------------------------------------------------------------------------------
// 0.1          
// Initial Rev
//------------------------------------------------------------------------------
logic [15:0] wr_data;
logic [7:0]  cmd;
logic [7:0]  rdatac_cmd;
logic [7:0]  stop_rd_cmd;
logic [7:0]  rdata_cmd;
logic [2:0]  wr_data_cmd;
logic [2:0]  rd_data_cmd;
logic [4:0]  no_of_reg;
logic [4:0]  start_address;

logic [7:0]  rd_data[];
logic [7:0]  wr_data[];

//logic [215:0] rdatac_data[];
logic [433:0] rdatac_data[];
logic [215:0] rdata_data[];
logic [7:0] rd_data_ens1;
logic [7:0] rd_data_mem_ens1[];

task do_run;
begin

// -------------------
//SP1 master writes the wakeup cmd//
//--------------------

//op_cmd
//cmd  =8'h02;  //wakeup_stand_by
//cmd = 8'h04;  //enter standby
//cmd = 8'h06;  //reset device
//cmd = 8'h08;  //start/restart
cmd = 8'h0a;  //stop conv

//data_rd_cmd
rdatac_cmd  = 8'h10; //read data continious
stop_rd_cmd = 8'h11; //stop read data continious
rdata_cmd   = 8'h12; //read data by cmd

//wr_data = 15'h2304; //reg_rd_cmd ,rd_reg
//wr_data = 15'h4304; //reg_rd_cmd ,wr_reg

$display("RUNNING INSIDE THE DO_RUN TASK \n");
//data_rd_cmd(wr_data);


wr_data_cmd    = 3'b010;
rd_data_cmd    = 3'b001;

no_of_reg      = 5'b00010;
start_address  = 5'h01;


//op_cmd(cmd);

//rdatac_cmd_fr(rdatac_cmd,rdatac_data);
//stop_rd_cmd_fr(stop_rd_cmd);
//rdata_cmd_fr(rdata_cmd,rdata_data);

//op_cmd(cmd);


//#5000;
//data_wr_cmd(wr_data_cmd,start_address,no_of_reg,wr_data);
//#5000;
//data_rd_cmd(rd_data_cmd,start_address,no_of_reg,rd_data);

//data_rd_cmd(rd_data_cmd,start_address,no_of_reg,rd_data);

//start_address  = 5'h03;

//data_wr_cmd(wr_data_cmd,start_address,no_of_reg,wr_data);

//data_wr_cmd_con_sclk(wr_data_cmd,start_address,no_of_reg,wr_data);
//data_rd_cmd_con_sclk(rd_data_cmd,start_address,no_of_reg,rd_data);


master_write(8'h01,8'h80,8'h02,8'h00); //addr=01 data=02
#5000;
master_read(8'h01,8'h00,rd_data_ens1); //addr=01

#100000;
master_write_burst(8'h01,8'ha0,8'h04,8'h00);  //adddr=01, no_of_data=04.
#5000;
master_read_burst(8'h01,8'h20,8'h04,rd_data_mem_ens1);   //addr=01, no_of_data=04

end
endtask

initial 
begin
//  #1000;
#1250;
  wait(`RESETN);

  do_run;
  #2000000;
 $finish();
 
end




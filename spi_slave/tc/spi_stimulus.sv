
//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2022
//
// Module Name : ENS2 Verification 
// Description : spi stimulus for ENS1-P4
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author  jayanthi
//------------------------------------------------------------------------------
// 0.1          
// Initial Rev
//------------------------------------------------------------------------------

////////////////////-----------------From ENS2 Stimulus----------------////////////////
// =====================================================================
// WRITE - COMMAND TASK OF VIP CORE
// =====================================================================
task master_write;            // WRITE_Format :- ADDR<7:0>,CMD<7:0>,DATA<7:0>,PAD<7:0>

  input [mem_depth-1:0] addr;
  input [mem_width-1:0] cmd;  //addr
  input [mem_depth-1:0] d;    //data
  input [mem_depth-1:0] pad;  //pad
  begin

     // data_ens2 = 32;

       @(negedge clk_r);
       cs_n_r = 0;            //  active low chip select (to start trsnaction)
   
     // Step 1: Enable SCLK clock (First Phase)
      // ------------------------------------------
      sclk_g =1'b1;
       
      
      // Step 2 - Sending the 8-bit of address
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin  
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @negedge
        else 

	  @(posedge clk_rr);      //master shiftsout @posedge

      // Timing of mosi
     // #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = addr[i];  
      end

      // Step 3 - Sending the 8-bit of command 
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
      	  @(posedge sclk_r);      //master shiftsout @posedge

        // Timing of mosi
       // #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = cmd[i];    
      end

      // Step 4 - Sending the 8-bit of data 
      // ------------------------------------------        
      for (int i = mem_depth-1; i >= 0; i--) begin  
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge sclk_r);      //master shiftsout @posedge

        // Timing of mosi
      //  #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = d[i];  
      end

      // Step 5 - Sending the 8-bit of pad
      // ------------------------------------------
      for (int i = mem_width-1; i >= 0; i--) begin  
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge sclk_r);      //master shiftsout @posedge

        // Timing of mosi
     //   #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = pad[i];  
      end

      // Step 6: Disable SCLK clock (First Phase)
      // ------------------------------------------ 
    //  @(negedge sclk_g_g); 
    @(negedge sclk_r);
      sclk_g  =1'b0;

      // ------------------------------------------
      // Completed to Transfer 1
      // ==========================================

      // ===================================================
      // wait for tsccs of sys_clk (min is 4) (TI Spec)
      // =================================================== 
     // repeat(tsccs) begin
    //    @(posedge sys_clk);
   //   end

    // ===================================================
    // finish transaction (master pull up the chip select)
    // ===================================================
    cs_n_r = 1;            //  active high chip select (to finish the  trsnaction)
    mosi_r = 1'bz;         //  when no transction mosi_r is high impedence

   // data_ens2 = 0;
    // ==================================================================
    // Wait for tcsh of sys_clk to start new request (min is 2 of sysclk)
    // ==================================================================
  //  repeat(tcsh) begin
   //   @(posedge sys_clk);
   // end

  end
endtask

// =====================================================================
// READ - COMMAND TASK OF VIP CORE - Format:ADDR<7:0>,CMD<7:0>,DATA<7:0>
// =====================================================================
task master_read;
   input [mem_depth-1:0]   addr;     // ins
   input [mem_width-1:0]   cmd;      // addr
   output [mem_depth-1:0]  rd_data;  // data
  begin

     // data_ens2 = 24;
      // ==========================================
      // active low chip select (to start transaction)
      // ------------------------------------------   
     // if (spi_mode[1] === 1'b0)
        @(negedge clk_r);      //master shiftsout @posedge

      cs_n_r = 0;            //  active low chip select (to start trsnaction)

           // ==========================================
      // Start to Transfer 1
      // ------------------------------------------

      // Step 1: Enable SCLK clock (First Phase)
      // ------------------------------------------
      sclk_g =1'b1;

      // Step 2 - Sending the 8-bit of address
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin

        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge sclk_r);      //master shiftsout @posedge

        // Timing of mosi
     //   #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = addr[i];    

      end

      // Step 3 - Sending the 8-bit of command 
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin  
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge sclk_r);      //master shiftsout @posedge

        // Timing of mosi
    //    #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = cmd[i];  
      end

        /* for (int i = mem_depth-1; i >= 0; i--) begin
	  mosi_r = pad_1[i];    
	  @(posedge clk_rr);
	end */

      // Need to check by Daniel
    //  @(posedge spi_sck);

      // Step 4 - Reading the 8-bit of data 
      // ------------------------------------------ 
        for (int i = mem_depth-1; i >= 0; i--) begin
          if ((spi_mode === 2'b00) || (spi_mode === 2'b11))
            @(posedge clk_rr);
          else 
	    @(negedge sclk_r);      //master shiftsout @posedge

          rd_data[i] = miso_w;      
   	end

      // Step 5: Disable SCLK clock (First Phase)
      // ------------------------------------------ 
      @(negedge sclk_r); 
      sclk_g  =1'b0;

      // ------------------------------------------
      // Completed to Transfer 1
      // ==========================================

      // ===================================================
      // wait for tsccs of sys_clk (min is 4) (TI Spec)
      // =================================================== 
  //    repeat(tsccs) begin
  //      @(posedge sys_clk);
  //    end

    // ===================================================
    // finish transaction (master pull up the chip select)
    // ===================================================
    cs_n_r = 1;            //  active high chip select (to finish the  trsnaction)
    mosi_r = 1'bz;         //  when no transction mosi_r is high impedence

  //  data_ens2 = 0;
    // ==================================================================
    // Wait for tcsh of sys_clk to start new request (min is 2 of sysclk)
    // ==================================================================
  //  repeat(tcsh) begin
   //   @(posedge sys_clk);
   // end    
   end

endtask

// =============================================================================================================
// BUSRT WRITE - COMMAND TASK OF VIP CORE - Format :- ADDR<7:0>,CMD<7:0>,DATA_N<7:0>,.....,DATA_0<7:0>,PAD<7:0>
// =============================================================================================================
// =====================================================================
// INITIAL DATA_MEM
// =====================================================================
logic[7:0] data_mem[5];

/*
initial begin
  for (int i=0; i<256; i++) begin 
    data_mem[i] = 8'h00;
  end
*/
initial begin
data_mem[0]=8'h11;
data_mem[1]=8'h22;
data_mem[2]=8'h33;
data_mem[3]=8'h44;
data_mem[4]=8'h55;

end

// =====================================================================
// INITIAL PAD_MEM
// =====================================================================
logic[7:0] pad_mem[256];
initial begin
  for (int i=0; i<256; i++) begin 
    pad_mem[i] = 8'h00;
  end
end


task master_write_burst;  
   input [mem_depth-1:0] addr;            //ins
   input [mem_width-1:0] cmd;             //addr
   input integer         number_of_data;
   input [mem_depth-1:0] pad;             //pad
   begin

    //  data_ens2 = 16 + number_of_data * mem_depth + mem_width;
      // ==========================================
      // active low chip select (to start transaction)
      // ------------------------------------------   
    //  if (spi_mode[1] === 1'b0)
        @(negedge clk_r);      //master shiftsout @posedge

      cs_n_r = 0;            //  active low chip select (to start trsnaction)

      //  mosi_r = addr[7];

      // This is TI Spec
     // #(tcssc);

      // ==========================================
      // Start to Transfer 1
      // ------------------------------------------

      // Step 1: Enable SCLK clock (First Phase)
      // ------------------------------------------
      sclk_g =1'b1;
   
      // Step 2 - Sending the 8-bit of address
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge clk_rr);      //master shiftsout @posedge

        // Timing of mosi
      //  #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = addr[i];  
     //   sclk_g =1'b1;  
      end

      // Step 3 - Sending the 8-bit of command 
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin  
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge clk_rr);      //master shiftsout @posedge

        // Timing of mosi
      //  #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

        mosi_r = cmd[i];  
      end

      // Step 4 - Sending the 8-bit of data 
      // ------------------------------------------ 
      for(int j = number_of_data-1;j>=0;j--) begin       
	for (int i = mem_depth-1; i >= 0; i--) begin  
          if (spi_mode[1] === 1'b1)
            @(negedge clk_rr);      //master shiftsout @posedge
          else 
	    @(posedge clk_rr);      //master shiftsout @posedge

          // Timing of mosi
        //  #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	  mosi_r = data_mem[j][i];  
	end
      end

      // Step 5 - Sending the 8-bit of pad
      // ------------------------------------------
      for (int i = mem_width-1; i >= 0; i--) begin   
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge clk_rr);      //master shiftsout @posedge

        // Timing of mosi
     //   #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = pad[i]; 
      end

      // Step 6: Disable SCLK clock (First Phase)
      // ------------------------------------------ 
      @(negedge sclk_r); 
      sclk_g  =1'b0;

      // ------------------------------------------
      // Completed to Transfer 1
      // ==========================================

      // ===================================================
      // wait for tsccs of sys_clk (min is 4) (TI Spec)
      // =================================================== 
   //   repeat(tsccs) begin
   //     @(posedge sys_clk);
   //   end

    // ===================================================
    // finish transaction (master pull up the chip select)
    // ===================================================
    cs_n_r = 1;            //  active high chip select (to finish the  trsnaction)
    mosi_r = 1'bz;         //  when no transction mosi_r is high impedence

 //   data_ens2 = 0;
    // ==================================================================
    // Wait for tcsh of sys_clk to start new request (min is 2 of sysclk)
    // ==================================================================
 //   repeat(tcsh) begin
 //     @(posedge sys_clk);
 //   end    

  end
endtask

// =====================================================================
// BUSRT READ - COMMAND TASK OF VIP CORE
// =====================================================================
task master_read_burst;         // READ_Burst_Format :- ADDR<7:0>,CMD<7:0>,PAD_N<7:0>,.....,PAD_0<7:0>
   input [mem_depth-1:0] addr;  //ins
   input [mem_width-1:0] cmd;   //addr

   input  integer        number_of_data;
   output [7:0]          rd_data[];  
   begin

      rd_data = new[number_of_data];

    //  data_ens2 = 16 + number_of_data * mem_depth;
      // ==========================================
      // active low chip select (to start transaction)
      // ------------------------------------------   
    //  if (spi_mode[1] === 1'b0)
        @(negedge clk_r);      //master shiftsout @posedge

      cs_n_r = 0;            //  active low chip select (to start trsnaction)

      // This is TI Spec
    //  #(tcssc);
      
      // ==========================================
      // Start to Transfer 1
      // ------------------------------------------

      // Step 1: Enable SCLK clock (First Phase)
      // ------------------------------------------
      sclk_g =1'b1;
   
      // Step 2 - Sending the 8-bit of address
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge clk_rr);      //master shiftsout @posedge

        // Timing of mosi
     //   #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = addr[i];
      end

      // Step 3 - Sending the 8-bit of command 
      // ------------------------------------------
      for (int i = mem_depth-1; i >= 0; i--) begin 
        if (spi_mode[1] === 1'b1)
          @(negedge clk_rr);      //master shiftsout @posedge
        else 
	  @(posedge clk_rr);      //master shiftsout @posedge

        // Timing of mosi
     //   #((SPI_CLK_PERIOD/2 - 10)*(tdist)/100);

	mosi_r = cmd[i];   
      end
 
      // Need to check by Daniel
    //  @(posedge spi_sclk);
        @(posedge clk_rr);

      // Step 4 - Reading the 8-bit of data 
      // ------------------------------------------ 
      for(int j = number_of_data-1;j>=0;j--) begin 
        for (int i = mem_depth-1; i >= 0; i--) begin
          //mosi_r = 8'h00;
          if ((spi_mode === 2'b00) || (spi_mode === 2'b11))
         //   @(posedge spi_sclk);
             @(posedge clk_rr);
          else 
	  //  @(negedge spi_sclk);      //master shiftsout @posedge
         @(negedge clk_rr);

          rd_data[j][i] = miso_w;
        end
      end

      // Step 6: Disable SCLK clock (First Phase)
      // ------------------------------------------ 
      @(negedge sclk_r); 
      sclk_g  =1'b0;

      // ------------------------------------------
      // Completed to Transfer 1
      // ==========================================

      // ===================================================
      // wait for tsccs of sys_clk (min is 4) (TI Spec)
      // =================================================== 
   //   repeat(tsccs) begin
   //     @(posedge sys_clk);
   //   end

    // ===================================================
    // finish transaction (master pull up the chip select)
    // ===================================================
    cs_n_r = 1;            //  active high chip select (to finish the  trsnaction)
    mosi_r = 1'bz;         //  when no transction mosi_r is high impedence

  //  data_ens2 = 0;
    // ==================================================================
    // Wait for tcsh of sys_clk to start new request (min is 2 of sysclk)
    // ==================================================================
//    repeat(tcsh) begin
//      @(posedge sys_clk);
//    end    

  end
endtask



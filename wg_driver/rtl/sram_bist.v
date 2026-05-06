/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/* File Name	: sram_bist.v                                                             */
/* Project	: Nanochap Glucose Chip                                                     */
/* Description	: sram bist function, include FSM,                                      */
/*                results compare, address and data generator                           */
/* Designer	: Daniel Wang                                                               */
/* Date		: 08/07/2019                                                                  */
/* Revision	:                                                                           */
/* R001 first draft                                                                     */
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
module sram_bist #(
parameter WE_WIDTH    = 4,
parameter ADDR_WIDTH  = 11,
parameter DATA_WIDTH  = 32
)
(
input  wire                   bist_clk,           // bist clock
input  wire                   bist_rst_n,         // bist resetn
input  wire                   bist_en,            // bist enable
input  wire [DATA_WIDTH-1 :0] bist_rdata,         // bist read data from sram
output wire [DATA_WIDTH-1 :0] bist_wdata,         // bist write data to sram
output wire [ADDR_WIDTH-1 :0] bist_addr,          // bist read/write address
output wire [WE_WIDTH-1   :0] bist_wen,           // bist write enable
output wire                   bist_cen,           // bist sram chip select
output wire                   bist_done,          // bist finish flag
output wire                   bist_fail           // bist fail flag
);

//----------------------------------------------------
//Define 25 work states of BIST block for bist test
//----------------------------------------------------
`define IDLE          5'b00000
`define P1_WRITE0     5'b00001
`define P2_READ0      5'b00010
`define P2_COMPARE0   5'b00011
`define P2_WRITE1     5'b00100
`define P2_READ1      5'b00101
`define P2_COMPARE1   5'b00110
`define P3_READ1      5'b00111
`define P3_COMPARE1   5'b01000
`define P3_WRITE0     5'b01001
`define P3_READ0      5'b01010
`define P3_COMPARE0   5'b01011
`define P4_READ0      5'b01100
`define P4_COMPARE0   5'b01101
`define P4_WRITE1     5'b01110
`define P4_READ1      5'b01111
`define P4_COMPARE1   5'b10000
`define P5_READ1      5'b10001
`define P5_COMPARE1   5'b10010
`define P5_WRITE0     5'b10011
`define P5_READ0      5'b10100
`define P5_COMPARE0   5'b10101
`define P6_READ0      5'b10110
`define P6_COMPARE0   5'b10111
`define END           5'b11000

// sram address when in bist test mode
reg [(ADDR_WIDTH-1):0] test_addr;

// sram address reset when in bist test mode.
reg test_addr_rst;

// sram read or write enable signal when in bist test mode
reg [(WE_WIDTH-1):0] test_wen;
// chip select in bist test mode
reg test_cen;


// compare the data read from sram with the data written into sram enable signal
reg check_en;

// bist test data source select signal
// "pattern_sel == 1'b0"-----> test_pattern =  32'b0000_0000;
// "pattern_sel == 1'b1"-----> test_pattern =  32'bffff_ffff;
reg pattern_sel;
wire [(DATA_WIDTH-1):0] test_pattern;

// FSM
reg [4:0] cstate, nstate;
    
// 1 -- address is goign upward; 0 -- address is going downward
reg addr_up_down;

// 1 -- address is stepping; 0 -- address remains
reg count_en;

// bist fail pulse when check_en is 1'b1
wire fail_en;

// bist fail latch value
reg fail_reg;

// end flag
reg end_en;
reg end_reg;

//-----------------------------------------------------------------
//     Combinatorial portion
//-----------------------------------------------------------------
assign test_pattern = (pattern_sel == 1'b0) ? {DATA_WIDTH{1'b0}} : {DATA_WIDTH{1'b1}};

//--------------------------------------------------------------------
//      Ouput Value to SRAM
//---------------------------------------------------------------------
assign  bist_wdata  =   test_pattern;
assign  bist_addr   =   test_addr;
assign  bist_cen    =   test_cen;
assign  bist_wen    =   test_wen;        

//----------------------------------------------------
//          Generate the sram test address.
// "test_addr_rst " and "addr_up_down" decide the mode of 
// variable the address(increment/decrement). 
//-----------------------------------------------------
always @(posedge bist_clk or negedge bist_rst_n) begin
    if (~bist_rst_n)
        test_addr <= {ADDR_WIDTH{1'b0}};
    else if (bist_en & test_addr_rst)
        if (addr_up_down)
            test_addr<=  {ADDR_WIDTH{1'b0}};
        else
            test_addr<=  {ADDR_WIDTH{1'b1}};
    else if (bist_en & count_en)
        if (addr_up_down)
            test_addr<=  test_addr + 1'b1;
        else
            test_addr<=  test_addr - 1'b1;
    else
        test_addr <= test_addr;
end

//----------------------------------------------------
//      Generate the bist fail.
// when data read from sram is different 
// from the expected data wirtten into sram
//-----------------------------------------------------
assign fail_en = bist_en & check_en & (test_pattern != bist_rdata);
always @(posedge bist_clk or negedge bist_rst_n) begin
    if (~bist_rst_n)
        fail_reg <= 1'b0;
    else if (fail_en)
        fail_reg <= 1'b1;
    else
        fail_reg <= fail_reg;
end
assign bist_fail = fail_reg;

// Generate bist end 
always @(posedge bist_clk or negedge bist_rst_n) begin
    if (~bist_rst_n)
        end_reg <= 1'b0;
    else
        end_reg <= end_en;
end
assign bist_done = end_reg;

//-----------------------------------------------------------------------------------------------------------
//                    Bist test state machine
//   write "0"(initial sram)                                                            test_address 0-->ffff
//   read  "0"------> compare0 -------->write "1" --------> read "1" ------> compare1   test_address 0-->ffff
//   read  "1"------> compare1 -------->write "0" --------> read "0" ------> compare0   test_address 0-->ffff
//   read  "0"------> compare0 -------->write "1" --------> read "1" ------> compare1   test_address ffff-->0
//   read  "1"------> compare1 -------->write "0" --------> read "0" ------> compare0   test_address ffff-->0
//   read  "0"------> compare0                                                          test_address 0-->ffff
//-----------------------------------------------------------------------------------------------------------
always @(posedge bist_clk or negedge bist_rst_n) begin
    if (~bist_rst_n)
        cstate <= `IDLE;
    else
        cstate <= nstate;
end

always @(*) begin
    addr_up_down    = 1'b1;
    count_en        = 1'b0;
    end_en          = 1'b0;
    pattern_sel     = 1'b0;
    test_addr_rst   = 1'b0;
    check_en        = 1'b0;
    test_wen        = {WE_WIDTH{1'b1}};
    test_cen        = 1'b1;
    nstate          = cstate;
    case (cstate)
        `IDLE:
            begin
                addr_up_down    = 1'b1;
                test_addr_rst   = 1'b1;
                if (bist_en)
                    nstate  = `P1_WRITE0;
                else
                    nstate  = `IDLE;
            end
        `P1_WRITE0: // P1: initial sram to all "0" from addr 0~ffff
            begin
                count_en    = 1'b1;
                test_wen    = {WE_WIDTH{1'b0}};
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                if (test_addr == {ADDR_WIDTH{1'b1}}) begin
                    test_addr_rst   = 1'b1;
                    addr_up_down    = 1'b1;
                    nstate          = `P2_READ0;
                end 
                else 
                    nstate          = `P1_WRITE0;
            end
        `P2_READ0: // P2: read all "0" from addr 0~ffff
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                nstate      = `P2_COMPARE0;
            end
        `P2_COMPARE0: // P2: compare all "0" data after read from addr 0~ffff
            begin
                pattern_sel = 1'b0;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else
                    nstate  = `P2_WRITE1;
            end
        `P2_WRITE1: // P2: write all "1" data from addr 0~ffff
            begin
                test_cen    = 1'b0;
                test_wen    = {WE_WIDTH{1'b0}};
                pattern_sel = 1'b1;
                nstate      = `P2_READ1;
            end
        `P2_READ1: // P2: read all "1" from addr 0~ffff
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b1;
                nstate      = `P2_COMPARE1;
            end
        `P2_COMPARE1: // P2: compare all "1" data after read from addr 0~ffff
            begin
                pattern_sel = 1'b1;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else if (test_addr == {ADDR_WIDTH{1'b1}}) begin
                    count_en        = 1'b0;
                    test_addr_rst   = 1'b1;
                    addr_up_down    = 1'b1;
                    nstate          = `P3_READ1;
                end
                else begin
                    count_en        = 1'b1;
                    addr_up_down    = 1'b1;
                    nstate          = `P2_READ0;
                end
            end
        `P3_READ1: // P3: read all "1" from addr 0~ffff
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b1;
                nstate      = `P3_COMPARE1;
            end
        `P3_COMPARE1: // P3: compare all "1" data after read from addr 0~ffff
            begin
                pattern_sel = 1'b1;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else
                    nstate  = `P3_WRITE0;
            end
        `P3_WRITE0: // P3: write all "0" data from addr 0~ffff
            begin
                test_cen    = 1'b0;
                test_wen    = {WE_WIDTH{1'b0}};
                pattern_sel = 1'b0;
                nstate      = `P3_READ0;
            end
        `P3_READ0: // P3: read all "0" from addr 0~ffff
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                nstate      = `P3_COMPARE0;
            end
        `P3_COMPARE0: // P3: compare all "0" data after read from addr 0~ffff
            begin
                pattern_sel = 1'b0;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else if (test_addr == {ADDR_WIDTH{1'b1}}) begin
                    count_en    = 1'b0;
                    nstate      = `P4_READ0;
                end
                else begin
                    addr_up_down    = 1'b1;
                    count_en        = 1'b1;
                    nstate          = `P3_READ1;
                end
            end
        `P4_READ0: // P4: read all "0" from addr ffff~0
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                nstate      = `P4_COMPARE0;
            end
        `P4_COMPARE0: // P4: compare all "0" data after read from addr ffff~0
            begin
                pattern_sel = 1'b0;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else
                    nstate  = `P4_WRITE1;
            end
        `P4_WRITE1: // P4: write all "1" data from addr ffff~0
            begin
                test_cen    = 1'b0;
                test_wen    = {WE_WIDTH{1'b0}};
                pattern_sel = 1'b1;
                nstate      = `P4_READ1;
            end
        `P4_READ1: // P4: read all "1" from addr ffff~0
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b1;
                nstate      = `P4_COMPARE1;
            end
        `P4_COMPARE1: // P4: compare all "1" data after read from addr ffff~0
            begin
                pattern_sel = 1'b1;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else if (test_addr == {ADDR_WIDTH{1'b0}}) begin
                    count_en        = 1'b0;
                    test_addr_rst   = 1'b1;
                    addr_up_down    = 1'b0;
                    nstate          = `P5_READ1;
                end
                else begin
                    addr_up_down    = 1'b0;
                    count_en        = 1'b1;
                    nstate          = `P4_READ0;
                end
            end
        `P5_READ1: // P5: read all "1" from addr ffff~0
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b1;
                nstate      = `P5_COMPARE1;
            end
        `P5_COMPARE1: // P5: compare all "1" data after read from addr ffff~0
            begin
                pattern_sel = 1'b1;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else
                    nstate  = `P5_WRITE0;
            end
        `P5_WRITE0: // P5:  write all "0" data from addr ffff~0
            begin
                test_cen    = 1'b0;
                test_wen    = {WE_WIDTH{1'b0}};
                pattern_sel = 1'b0;
                nstate      = `P5_READ0;
            end
        `P5_READ0: // P5: read all "0" from addr ffff~0
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                nstate      = `P5_COMPARE0;
            end
        `P5_COMPARE0: // P5: compare all "0" data after read from addr ffff~0
            begin
                pattern_sel = 1'b0;
                check_en    = 1'b1;
                if (fail_en)
                    nstate  = `END;
                else if (test_addr == {ADDR_WIDTH{1'b0}}) begin
                    count_en    = 1'b0;
                    nstate      = `P6_READ0;
                end
                else begin
                    addr_up_down    = 1'b0;
                    count_en        = 1'b1;
                    nstate          = `P5_READ1;
                end
            end
        `P6_READ0: // P6: read all "0" from addr 0~ffff
            begin
                test_cen    = 1'b0;
                pattern_sel = 1'b0;
                nstate      = `P6_COMPARE0;
            end
        `P6_COMPARE0: // P6: compare all "0" data after read from addr 0~ffff
            begin
                addr_up_down    = 1'b1;
                count_en        = 1'b1;
                pattern_sel     = 1'b0;
                check_en        = 1'b1;
                if (fail_en | (test_addr == {ADDR_WIDTH{1'b1}}))
                    nstate      = `END;
                else
                    nstate      = `P6_READ0;
            end
        `END:
            begin
                test_addr_rst   = 1'b1;
                addr_up_down    = 1'b1;
                end_en          = 1'b1;
            end
        default:
            begin
                test_addr_rst   = 1'b1;
                nstate          = `IDLE;
            end
    endcase

end

endmodule


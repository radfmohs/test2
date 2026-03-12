/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	:   spi_master_dev.v                                                    */
/* Project	    :   ECG Chip                                                            */
/* Designer	    :   Daniel Wang                                                         */
/* Description	:   SPI Master Device Model                                             */
/* Date		    :   06/18/2020                                                          */
/*--------------------------------------------------------------------------------------*/
/* Revision History:                                                                    */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/*06/18/2020    0.1     Daniel Wang     First draft                                     */
/*--------------------------------------------------------------------------------------*/
`timescale 1ns / 10ps
module spi_master_dev #(
parameter ID = "spi_master_dev0")
(
output reg  spi_nss,
output wire spi_sck,
output reg  spi_mosi,
input  wire spi_miso 
);

reg spi_clk;
reg cpol;
reg cpha;
reg rx_en;
reg tx_en;
reg lsb_sel; // 0: MSB, 1: LSB
reg tx_random;
reg nss_pulse;
reg [4:0] data_size;
reg [4:0] data_len;
reg [2:0] cur_state;
reg [2:0] nxt_state;
reg [4:0] bits_cnt;
reg [15:0] tx_data;
reg [15:0] tx_data_buf;
reg [15:0] msb_data;
reg [15:0] lsb_data;
reg [15:0] dataout;
reg [15:0] rx_shift;
reg [15:0] rx_data;
reg [4:0] tran_cnt;
reg [4:0] nxt_tran_cnt;
reg data_change;
reg data_sample;
reg nxt_spi_sck;
reg cur_spi_sck;
reg rx_cmpl;
reg [4:0] rx_cnt;
reg [15:0] exp_rxdata;
reg [15:0] exp_rx_data[0:15];
reg [15:0] exp_tx_data[0:15];
parameter D = 1;
parameter PERIOD = 40; // 25MHz

parameter IDLE          = 4'b0000,
          NSS_START0    = 4'b0001,
          NSS_START1    = 4'b0011,
          SCK_TOGGLE0   = 4'b0010,
          SCK_TOGGLE1   = 4'b0110,
          NSS_STOP0     = 4'b0111,
          NSS_STOP1     = 4'b0101,
          NSS_PULSE0    = 4'b0100,
          NSS_PULSE1    = 4'b1100;

always #(PERIOD/2) spi_clk = ~spi_clk;

initial begin
    cpol        = 1'b0;
    cpha        = 1'b0;
    rx_en       = 1'b0; 
    tx_en       = 1'b0; 
    lsb_sel     = 1'b0;
    data_size   = 5'h8;
    data_len    = 5'h0;
    spi_clk     = 1'b0;
    cur_state   = 4'b0;
    nxt_state   = 4'b0;
    bits_cnt    = 5'h1f;
    spi_mosi    = 1'bz;  //original 1
    spi_nss     = 1'b1;
    tx_random   = 1'b0;
    nss_pulse   = 1'b0;
    tran_cnt    = 5'b0;
    nxt_tran_cnt= 5'b0;
    rx_cmpl     = 1'b0;
    rx_shift    = 16'b0;
    rx_data     = 16'b0;
    rx_cnt      = 5'b0;
    exp_rx_data = '{16{'0}};
    exp_tx_data = '{16{'0}};
end

always @ (posedge spi_clk) begin
    cur_state <= nxt_state;
end

always @ (posedge spi_clk) begin
    cur_spi_sck <= nxt_spi_sck;
end

always @ (posedge spi_clk) begin
    tran_cnt <= nxt_tran_cnt;
end

assign spi_sck = nxt_spi_sck;

always @ (*) begin
    data_change = 0;
    data_sample = 0;
    rx_cmpl     = 0;
    case(cur_state)
        IDLE: begin
            nxt_spi_sck = cpol;
            spi_nss = 1'b1;
            if (|tran_cnt)
                nxt_state = NSS_START0;
            else
                nxt_state = IDLE;
        end
        NSS_START0: begin
            //dataout = tx_random ? exp_tx_data[data_len-nxt_tran_cnt] : tx_data_buf;
	    dataout = exp_tx_data[data_len-nxt_tran_cnt];
            $display($time, "\t%s transmit data = %h\n", ID, dataout);
            spi_nss = 1'b0;
            nxt_state = NSS_START1;
        end
        NSS_START1: begin
            if (~cpha) data_change = 1'b1;
            nxt_state = SCK_TOGGLE0;
        end
        SCK_TOGGLE0: begin
            nxt_spi_sck = ~cur_spi_sck;
            if (cpha) data_change = 1'b1;
            if (~cpha) data_sample = 1'b1;
            nxt_state = SCK_TOGGLE1;
        end
        SCK_TOGGLE1: begin
            nxt_spi_sck = ~cur_spi_sck;
            if (cpha) data_sample = 1'b1;
            if (cpha ? (bits_cnt == data_size-5'b1) : (bits_cnt == data_size)) 
                nxt_state = NSS_STOP0;
            else begin
                nxt_state = SCK_TOGGLE0;
                if (~cpha) data_change = 1'b1;
            end
        end
        NSS_STOP0: begin
            nxt_spi_sck = cpol;
            nxt_tran_cnt = tran_cnt - 4'b1;
            if(rx_en) rx_cmpl = 1'b1;
            if (~nss_pulse)
                nxt_state = NSS_STOP1;
            else
                nxt_state = NSS_PULSE0;
        end
        NSS_STOP1: begin
            if (|tran_cnt) 
                nxt_state = NSS_START0;
            else 
                nxt_state = IDLE;
        end
        NSS_PULSE0: begin
            spi_nss = 1'b1;
            nxt_state = NSS_PULSE1;
        end
        NSS_PULSE1: begin
            spi_nss = 1'b1;
            if (|tran_cnt)
                nxt_state = NSS_START0;
            else
                nxt_state = IDLE;
        end
        default: begin
            nxt_spi_sck = cpol;
            spi_nss = 1'b1;
            nxt_state = IDLE;
        end
    endcase
end

always @ (posedge data_change) begin
    if (cpha ? (bits_cnt == data_size-5'b1) : (bits_cnt == data_size))
        bits_cnt <= 5'b0;
    else
        bits_cnt <= bits_cnt + 5'b1;
end

always @ (*) begin
    case(data_size)
        5'd1: begin
            lsb_data = {15'b0, dataout[0]};
            msb_data = {15'b0, dataout[0]};
        end
        5'd2: begin
            lsb_data = {14'b0, dataout[1:0]};
            msb_data = {14'b0, dataout[0], dataout[1]};
        end
        5'd3: begin
            lsb_data = {13'b0, dataout[2:0]};
            msb_data = {14'b0, dataout[0], dataout[1], dataout[2]};
        end
        5'd4: begin
            lsb_data = {12'b0, dataout[3:0]};
            msb_data = {12'b0, dataout[0], dataout[1], dataout[2], dataout[3]};
        end
        5'd5: begin
            lsb_data = {11'b0, dataout[4:0]};
            msb_data = {11'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4]};
        end
        5'd6: begin
            lsb_data = {10'b0, dataout[5:0]};
            msb_data = {10'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5]};
        end
        5'd7: begin
            lsb_data = {9'b0, dataout[6:0]};
            msb_data = {9'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6]};
        end
        5'd8: begin
            lsb_data = {8'b0, dataout[7:0]};
            msb_data = {8'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7]};
        end
        5'd9: begin
            lsb_data = {7'b0, dataout[8:0]};
            msb_data = {7'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8]};
        end
        5'd10: begin
            lsb_data = {6'b0, dataout[9:0]};
            msb_data = {6'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9]};
        end
        5'd11: begin
            lsb_data = {5'b0, dataout[10:0]};
            msb_data = {5'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10]};
        end
        5'd12: begin
            lsb_data = {4'b0, dataout[11:0]};
            msb_data = {4'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10], dataout[11]};
        end
        5'd13: begin
            lsb_data = {3'b0, dataout[12:0]};
            msb_data = {3'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10], dataout[11], dataout[12]};
        end
        5'd14: begin
            lsb_data = {2'b0, dataout[13:0]};
            msb_data = {2'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10], dataout[11], dataout[12], dataout[13]};
        end
        5'd15: begin
            lsb_data = {1'b0, dataout[14:0]};
            msb_data = {1'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10], dataout[11], dataout[12], dataout[13], dataout[14]};
        end
        5'd16: begin
            lsb_data = dataout[15:0];
            msb_data = {dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7], dataout[8], dataout[9], dataout[10], dataout[11], dataout[12], dataout[13], dataout[14], dataout[15]};
        end
        default: begin
            lsb_data = {8'b0, dataout[7:0]};
            msb_data = {8'b0, dataout[0], dataout[1], dataout[2], dataout[3], dataout[4], dataout[5], dataout[6],  dataout[7]};
        end
    endcase 
end

always @ (*) begin
    if (~spi_nss) begin
        case(bits_cnt)
            5'd0:  spi_mosi =  lsb_sel ? lsb_data[0] : msb_data[0];
            5'd1:  spi_mosi =  lsb_sel ? lsb_data[1] : msb_data[1];
            5'd2:  spi_mosi =  lsb_sel ? lsb_data[2] : msb_data[2];
            5'd3:  spi_mosi =  lsb_sel ? lsb_data[3] : msb_data[3];
            5'd4:  spi_mosi =  lsb_sel ? lsb_data[4] : msb_data[4];
            5'd5:  spi_mosi =  lsb_sel ? lsb_data[5] : msb_data[5];
            5'd6:  spi_mosi =  lsb_sel ? lsb_data[6] : msb_data[6];
            5'd7:  spi_mosi =  lsb_sel ? lsb_data[7] : msb_data[7];
            5'd8:  spi_mosi =  lsb_sel ? lsb_data[8] : msb_data[8];
            5'd9:  spi_mosi =  lsb_sel ? lsb_data[9] : msb_data[9];
            5'd10:  spi_mosi =  lsb_sel ? lsb_data[10] : msb_data[10];
            5'd11:  spi_mosi =  lsb_sel ? lsb_data[11] : msb_data[11];
            5'd12:  spi_mosi =  lsb_sel ? lsb_data[12] : msb_data[12];
            5'd13:  spi_mosi =  lsb_sel ? lsb_data[13] : msb_data[13];
            5'd14:  spi_mosi =  lsb_sel ? lsb_data[14] : msb_data[14];
            5'd15:  spi_mosi =  lsb_sel ? lsb_data[15] : msb_data[15];
            default: spi_mosi = 1'b1;
        endcase
    end
end

always @ (posedge data_sample) begin
    if (~spi_nss & rx_en) begin
        if (~lsb_sel)
            rx_shift <= {rx_shift[14:0], spi_miso};
        else
            rx_shift <= {spi_miso, rx_shift[15:1]};
    end
end

always @ (posedge rx_cmpl) begin
    if(lsb_sel) begin
	case(data_size)
	    5'd1: begin
            rx_data = {15'b0, rx_shift[15]};
            end
	    5'd2: begin
            rx_data = {14'b0, rx_shift[15:14]};
            end
	    5'd3: begin
            rx_data = {13'b0, rx_shift[15:13]};
            end
	    5'd4: begin
            rx_data = {12'b0, rx_shift[15:12]};
            end
	    5'd5: begin
            rx_data = {11'b0, rx_shift[15:11]};
            end
	    5'd6: begin
            rx_data = {10'b0, rx_shift[15:10]};
            end
	    5'd7: begin
            rx_data = {9'b0, rx_shift[15:9]};
            end
	    5'd8: begin
            rx_data = {8'b0, rx_shift[15:8]};
            end
	    5'd9: begin
            rx_data = {7'b0, rx_shift[15:7]};
            end
	    5'd10: begin
            rx_data = {6'b0, rx_shift[15:6]};
            end
	    5'd11: begin
            rx_data = {5'b0, rx_shift[15:5]};
            end
	    5'd12: begin
            rx_data = {4'b0, rx_shift[15:4]};
            end
	    5'd13: begin
            rx_data = {3'b0, rx_shift[15:3]};
            end
	    5'd14: begin
            rx_data = {2'b0, rx_shift[15:2]};
            end
	    5'd15: begin
            rx_data = {1'b0, rx_shift[15:1]};
            end
	    5'd16: begin
            rx_data = rx_shift[15:0];
            end
	endcase
    end
    else begin
    	rx_data = rx_shift;
    end
    rx_shift = 16'h0;
    exp_rxdata = exp_rx_data[rx_cnt] & ((2**data_size)-1); 
    if(rx_data != exp_rxdata)
    $display($time, "\tFAIL master received data = %h, expected data = %h\n", rx_data[15:0], exp_rxdata);
    else
    $display($time, "\tPASS master received data = %h\n", rx_data[15:0]);
    rx_cnt = rx_cnt + 1;
    //if(rx_cnt == data_len) begin
    //   rx_cnt = 0;
    //end
end

/*task send_one_data;
//input [15:0] data;
begin
    data_len = 5'd1;
    nxt_tran_cnt= 5'd1;
    //tx_random   = 1'b0;
    //tx_data_buf = data;
end
endtask
*/
task send_data;
input [4:0] len;
begin
// @(posedge spi_clk);
    data_len = len;
    nxt_tran_cnt = len;  //commented by jto send one transction
    //tx_random   = 1'b1;
end
endtask

endmodule


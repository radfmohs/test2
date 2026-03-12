import "DPI-C" context function int gen_vec(int fs, Nsamples, freq[2], cfg);
import "DPI-C" context function int output_check(int fs, Nsamples, stable_num, freq[2], cfg);
//freq:the freq of input data
//cfg[15:0]:lpf_fc, cfg[19:16]:Fs/lpf_delta_f(only supports values of 4'ha, i.e. Fs/lpf_delta_f = 4'ha), cfg[20]:notch_bypass, cfg[21]:lpf_bypass, cfg[22]:hpf_bypass
//


import uvm_pkg::*;

//`timescale 1ns/1ps
module filter_tb_top_1;
logic clk, clk_8M;
logic clk_enable;
logic signed [31:0] filter_in_design[0:0];
bit [3:0] osr_sel, osr_sel_cmd;
bit [3:0] iclk_div , iclk_div_cmd;
logic signed [31:0] filter_out[0:0];

initial begin
    clk = 0;
    forever #(122.070312*(2**iclk_div)/2)  clk = !clk;   ///8Mhz  122.070312   119.20929
end

initial begin
    clk_8M = 0;
    forever #(122.070312/2)  clk_8M = !clk_8M;   ///8Mhz  122.070312   119.20929
end



bit reset_n;
initial begin
    reset_n = 0;
    clk = 0;
    filter_in_design = '{default:0};
    #10000;   
    reset_n = 1;
end

int osr;
initial begin
    clk_enable =0;
    //osr_sel =3;
    wait(reset_n);
    osr = get_osr(osr_sel) -1;
    while(reset_n) begin
    repeat(osr) @(posedge clk);  //osr = 64 
        #1;
        clk_enable = 1;
        @(posedge clk);
        #1;
        clk_enable = 0;
    end
end




int file, file1, lpf_coeff_file;
int code;
int idx;
int stable_num;  //after how many samples, the notch will stabilize
logic signed [31:0] data_in;
logic signed [31:0] data_out;
int Nsamples, Nsamples_cmd;
int freq[2], cfg;

initial begin
    osr_sel = 4;
    Nsamples = 100000;
    if($value$plusargs("OSR=%d", osr_sel_cmd))  osr_sel = osr_sel_cmd;
    if($value$plusargs("Ns=%d", Nsamples_cmd))  Nsamples = Nsamples_cmd;
    if($value$plusargs("div=%d", iclk_div_cmd))  iclk_div = iclk_div_cmd;
    if($value$plusargs("freq0=%d", freq[0])); else freq[0] = 200;
    if($value$plusargs("freq1=%d", freq[1])); else freq[1] = 500;
        
    if($value$plusargs("cfg=%h", cfg)); else cfg = 32'h003a_0100;
    stable_num = 1000000000/(1000000000/get_fs(osr_sel));
    `uvm_info("", $sformatf("notch stable_num = %d, osc_sel = %d, iclk_div = %d, Nsamples = %d, freq=%p, cfg=%h", stable_num, osr_sel, iclk_div, Nsamples,freq, cfg), UVM_LOW);
    
    if(freq[0] > get_fs(osr_sel)/2) `uvm_error("","freq[0] is greater than Fs/2");
    if(freq[1] > get_fs(osr_sel)/2) `uvm_error("","freq[1] is greater than Fs/2");    

    if(gen_vec(get_fs(osr_sel), Nsamples, freq, cfg) == 1) begin
        `uvm_fatal(""," cont get vec");
    end
    
    file = $fopen("../uvm_tb/py/test_vectors.txt", "r");
    if(!file) $display("Error!!! cannot open test.txt");
    wait(reset_n);
    while(!$feof(file)) begin
        code = $fscanf(file, "%d %d %d", idx, data_in, data_out);
        if(code != 3) continue;
        @(posedge clk_enable);
        filter_in_design[0] =  data_in;        
    end
    $fclose(file);
end



initial begin
        file1 = $fopen("../uvm_tb/py/output_of_dut.txt", "w");
        if(!file1)`uvm_error("TEST", "Error!!! cannot open test.txt");
        wait(reset_n);
        @(negedge clk_enable);
        repeat(Nsamples) begin  //Nsamples
            @(negedge clk_enable);
            $fwrite(file1,"%d\n" ,filter_out[0]);        
        end
        $fclose(file1);
    if(output_check(get_fs(osr_sel), Nsamples, stable_num, freq, cfg) == 1) begin
        `uvm_fatal(""," cont get output_check");
    end
end

initial begin
    repeat(Nsamples+1) @(posedge clk_enable);
    #200us;
    $finish;
end

bit [17:0] lpf_coeff_py[31:0];
bit [17:0] lpf_coeff_data[31:0];
int idx_coeff;
initial begin
    lpf_coeff_file = $fopen("../uvm_tb/py/lpf_coeff.txt", "r");
    if(!lpf_coeff_file) $display("Error!!! cannot open lpf_coeff.txt");
    wait(reset_n);
    while(!$feof(lpf_coeff_file)) begin
        code = $fscanf(lpf_coeff_file, "%h", lpf_coeff_py[idx_coeff]);
        idx_coeff++;
        //@(posedge clk_enable);
        //filter_in_design[0] =  data_in;        
        #100;
    end
    $fclose(lpf_coeff_file);    
    if(idx_coeff == 33) lpf_coeff_data =  lpf_coeff_py;
    else `uvm_error("TEST", $sformatf("Error!!! coeff length is %0d not 32", idx_coeff));
end

initial begin
    if($test$plusargs("ncpy")) begin
    `uvm_info("TB", "notch_coeff from py", UVM_LOW);
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff1 = 18'b111111111110111111; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff2 = 18'b111111111101110000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff3 = 18'b111111111101000100; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff4 = 18'b111111111111110010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff5 = 18'b000000001011000001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff6 = 18'b000000100110010000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff7 = 18'b000001011010100101; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff8 = 18'b000010110001000101; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff9 = 18'b000100110000010010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff10= 18'b000111011001100100; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff11= 18'b001010100111000001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff12= 18'b001110001010100001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff13= 18'b010001101110110010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff14= 18'b010100111010010000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff15= 18'b010111010011011011; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff16= 18'b011000100101101111; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff17= 18'b011000100101101111; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff18= 18'b010111010011011011; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff19= 18'b010100111010010000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff20= 18'b010001101110110010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff21= 18'b001110001010100001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff22= 18'b001010100111000001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff23= 18'b000111011001100100; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff24= 18'b000100110000010010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff25= 18'b000010110001000101; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff26= 18'b000001011010100101; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff27= 18'b000000100110010000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff28= 18'b000000001011000001; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff29= 18'b111111111111110010; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff30= 18'b111111111101000100; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff31= 18'b111111111101110000; //sfix18_En20
 force filter_tb_top_1.filter.FILTER[0].u_filter_fir_lpf.coeff32= 18'b111111111110111111; //sfix18_En20
    end
    else `uvm_info("TB", "notch_coeff from dut", UVM_LOW);
end
 
 
logic [19:0] notch_coeff_py[41:0];
int notch_coeff_file;
int idx_notch_coeff;
initial begin
    notch_coeff_file = $fopen("../uvm_tb/py/notch_coeff.txt", "r");
    if(!notch_coeff_file) $display("Error!!! cannot open notch_coeff.txt");
    wait(reset_n);
    while(!$feof(notch_coeff_file)) begin
        code = $fscanf(notch_coeff_file, "%h", notch_coeff_py[idx_notch_coeff]);
        idx_notch_coeff++;
        #100;
        //@(posedge clk_enable);
        //filter_in_design[0] =  data_in;        
    end
    $fclose(notch_coeff_file);    
    //if(idx_coeff == 13) lpf_coeff_data =  lpf_coeff_py;
    //else `uvm_error("TEST", $sformatf("Error!!! coeff length is %0d not 52", idx_coeff));
end

logic [23:0] hpf_coeff_data;
int hpf_coeff_file;
int idx_hpf_coeff;
initial begin
    hpf_coeff_file = $fopen("../uvm_tb/py/hpf_coeff.txt", "r");
    if(!hpf_coeff_file) $display("Error!!! cannot open hpf_coeff.txt");
    wait(reset_n);
    while(!$feof(hpf_coeff_file)) begin
        code = $fscanf(hpf_coeff_file, "%h", hpf_coeff_data);
        idx_hpf_coeff++;
        #100;
        //@(posedge clk_enable);
        //filter_in_design[0] =  data_in;        
    end
    $fclose(hpf_coeff_file);    
    //if(idx_coeff == 13) lpf_coeff_data =  lpf_coeff_py;
    //else `uvm_error("TEST", $sformatf("Error!!! coeff length is %0d not 52", idx_coeff));
end


initial begin
    if($test$plusargs("ncpy")) begin
    `uvm_info("TB", "notch_coeff from py", UVM_LOW);    
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst1 = 20'b00111111111111110001; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section1 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section1 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section1 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section1 = 20'b10000000000000100111; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section1 = 20'b00111111111111100000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst2 = 20'b00111111111111110001; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section2 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section2 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section2 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section2 = 20'b10000000000000100011; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section2 = 20'b00111111111111100011; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst3 = 20'b00111111111111010101; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section3 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section3 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section3 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section3 = 20'b10000000000001100001; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section3 = 20'b00111111111110100110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst4 = 20'b00111111111111010101; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section4 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section4 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section4 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section4 = 20'b10000000000001011001; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section4 = 20'b00111111111110101101; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst5 = 20'b00111111111111000010; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section5 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section5 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section5 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section5 = 20'b10000000000010000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section5 = 20'b00111111111110000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst6 = 20'b00111111111111000010; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section6 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section6 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section6 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section6 = 20'b10000000000010000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section6 = 20'b00111111111110000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.scaleconst7 = 20'b00111111111110111011; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b1_section7 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b2_section7 = 20'b10000000000000000110; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_b3_section7 = 20'b01000000000000000000; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a2_section7 = 20'b10000000000010010001; //sfix20_En18
    force filter_tb_top_1.filter.FILTER[0].u_notch_filter.coeff_a3_section7 = 20'b00111111111101110101; //sfix20_En18
    end

    else `uvm_info("TB", "notch_coeff from dut", UVM_LOW);
end

bit [3:0] iclk_div = 0;
localparam [17:0] lpf_coeff_data_def [0:25] = '{
18'b000000000000000111, 
18'b000000000000001000, 
18'b111111111111101111, 
18'b111111111110110110, 
18'b111111111110000101, 
18'b111111111110110000, 
18'b000000000001111000, 
18'b000000000110100010, 
18'b000000001001001011, 
18'b000000000101001101,
18'b111111111001000001,
18'b111111101001110000,
18'b111111100011000111,
18'b111111110000101010,
18'b000000010011011111,
18'b000000111011001101,
18'b000001001010000111,
18'b000000100110010011,
18'b111111010000001100,
18'b111101101111001110,
18'b111101001000010100,
18'b111110011101011001,
18'b000010000100110100,
18'b000111010000110010,
18'b001100011000101111,
18'b001111100100011111
};

//initial begin
//    for(int i=0; i<26; i++)begin
//        lpf_coeff_data[i] =  lpf_coeff_data_def[i];
//    end
//    for(int i=51; i>25; i--)begin
//        lpf_coeff_data[i] =  lpf_coeff_data_def[51-i];
//    end
//end

logic lpf_clk_gtg, hpf_clk_gtg, notch_clk_gtg;

logic notch_clk, lpf_clk, hpf_clk;

assign clk_in =  osr_sel === 1? clk_8M:clk;



common_clock_gate u_notch_clk_gate(
.clk        (clk_in),
.enable     (notch_clk_gtg),
.bypass     (1'b0),
.gated_clk  (notch_clk));

common_clock_gate u_lpf_clk_gate (
.clk        (clk_in),
.enable     (lpf_clk_gtg),
.bypass     (1'b0),
.gated_clk  (lpf_clk));

common_clock_gate u_hpf_clk_gate (
.clk        (clk_in),
.enable     (hpf_clk_gtg),
.bypass     (1'b0),
.gated_clk  (hpf_clk));

filter_wrapper #(32, 1) filter(

.clk(clk_in),   
.pclk(),     
.notch_clk(notch_clk),
.lpf_clk(lpf_clk),
.hpf_clk(hpf_clk),
.reset(reset_n),
.sign_en(1'b1),
.scan_mode(1'b0),
.osr_sel(osr_sel),
.iclk_div(iclk_div),
//.filter_seq(3'b100),
.int_length_slct(),
.eeg_int_en(),
.eeg_int_clr(),
.cic_data_ignore_tar(),
.notch_filter_bypass(cfg[20]),
.lpf_filter_bypass(cfg[21]),
.hpf_filter_bypass(cfg[22]),
.imeas_chdata_in(filter_in_design),
.chdata_en(clk_enable),
.o_eeg_int(),
.eeg_int_sts(),
.meas_done_d1(),
.notch_clk_gtg_en(notch_clk_gtg),
.lpf_clk_gtg_en(lpf_clk_gtg),
.hpf_clk_gtg_en(hpf_clk_gtg),
.lpf_coeff_data(lpf_coeff_data),
.notch_coeff_data(notch_coeff_py),
.imeas_chdata_out(filter_out),
.hpf_coeff_data(hpf_coeff_data)
);
/*
filter_wrapper #(
.DATA_WIDTH(EEG_DATA_WIDTH),
.CHN_NUM(EEG_CHN_NUM))
u_filter_wrapper(
.clk(imeas_dig_filter_clk_post),   
.notch_clk(notch_clk),
.lpf_clk(lpf_clk),
.hpf_clk(hpf_clk),
.pclk	(pclk),  // pclk
.reset(cic_rst_n),
.sign_en(~imeas_reg_0[7]),
.osr_sel(DR),
.iclk_div(iclk_div),
//.filter_seq(filter_seq),
.notch_filter_valid(notch_filter_valid),
.notch_clk_gtg_en(notch_clk_gtg_en),
.lpf_clk_gtg_en(lpf_clk_gtg_en),
.hpf_clk_gtg_en(hpf_clk_gtg_en),

.notch_filter_bypass(notch_filter_bypass),
.lpf_filter_bypass(lpf_filter_bypass),
.hpf_filter_bypass(hpf_filter_bypass),
.hpf_filter_bypass(hpf_filter_bypass),
.int_length_slct(int_length_slct),
.eeg_int_en(eeg_int_en),
.eeg_int_clr(eeg_int_clr),
.scan_mode(atpg_en),
//.imeas_chdata_in(imeas_chdata),
//.chdata_en(chdata_en),
.imeas_chdata_in(imeas_chdata_adcclk),
.chdata_en(chdata_en_adcclk),

.cic_data_ignore_tar(cic_data_ignore_tar),
.lpf_coeff_data(lpf_coeff_data),
.hpf_coeff_data(hpf_coeff_data),
.notch_coeff_data(notch_coeff_data),
.o_eeg_int(o_eeg_int),
.eeg_int_sts(eeg_int_sts),
.meas_done_d1(meas_done_filter),
.imeas_chdata_out(imeas_chdata_filter),
.i_imeas_intr_clr(imeas_intr_clr)

);
*/

/*
`ifdef NOTCH
   notch_filter u_notch_filter(
   .clk(clk),
   .clk_enable(clk_enable),
   .reset(reset_n),
   .sign_en(1'b1),
   .bypass(1'b0),
   .filter_in(filter_in_design),
   .osr_sel(osr_sel),	                
   .filter_out(filter_out)
   );
`else
   filter_fir_lpf u_notch_filter(
   .clk(clk),
   .clk_enable(clk_enable),
   .reset(reset_n),
   .sign_en(1'b1),
   .bypass(1'b0),
   .filter_in(filter_in_design),
   .sinc_osr_sel(osr_sel),	                
   .filter_out(filter_out)
   );
`endif
*/
///nnc_filter_if  vif();
///initial begin
///    uvm_config_db#(nnc_filter_if)::set(uvm_root::get(), "uvm_test_top.*", "filter_vif", vif);
///end

    function int get_fs(int osc_sel);
        case(osc_sel)
        4'h00: return 1024000/(2**iclk_div)   ;
        4'h01: return 512000/(2**iclk_div)    ;
        4'h02: return 256000/(2**iclk_div)    ;
        4'h03: return 128000/(2**iclk_div)    ;
        4'h04: return 64000/(2**iclk_div)     ;
        4'h05: return 32000/(2**iclk_div)     ;
        4'h06: return 16000/(2**iclk_div)     ;
        4'h07: return 8000/(2**iclk_div)      ;
        4'h08: return 4000/(2**iclk_div)      ;
        4'h09: return 2000/(2**iclk_div)      ;
        4'h0a: return 1000/(2**iclk_div)      ;
        4'h0b: return 500/(2**iclk_div)       ;
        4'h0c: return 250/(2**iclk_div)       ;
        4'h0d: return 125/(2**iclk_div)       ;
        default: begin
         `uvm_error("", "cfg error");
          return 32768/(2**iclk_div);
        end
        endcase
    endfunction
    function int get_osr(int osc_sel);
        case(osc_sel)
        4'h00: return 8    ;
        4'h01: return 16     ;
        4'h02: return 32    ;
        4'h03: return 64    ;
        4'h04: return 128     ;
        4'h05: return 256     ;
        4'h06: return 512     ;
        4'h07: return 1024      ;
        4'h08: return 2048      ;
        4'h09: return 4096      ;
        4'h0a: return 8192      ;
        4'h0b: return 16384       ;
        4'h0c: return 32768       ;
        4'h0d: return 65536       ;
        default: begin
         `uvm_error("", "cfg error");
          return 64;
        end
        endcase
    endfunction






    function void c2sv_print(int c);
        //if(c === 1) `uvm_error("C2SV", $sformatf("%s", printf))
        //else if (c === 0) `uvm_info("C2SV", $sformatf("%s", printf), UVM_LOW)
        //else if (c === 2) `uvm_fatal("C2SV", $sformatf("%s", printf))   
        //else `uvm_info("C2SV", $sformatf("UNKNOWN: %s", printf), UVM_LOW);
        `uvm_info("C2SV", $sformatf("cfg: %b", c), UVM_LOW)
    endfunction

    task delay();
        $display("time: %t \n",$realtime);
        #20000ns;
        $display("time: %t \n",$realtime);
    endtask

    export "DPI-C" function c2sv_print;    
    export "DPI-C" task delay;

initial begin
        $fsdbDumpvars(0, filter_tb_top_1);
        $vcdpluson(0);
        $vcdpluson(0);
        $vcdplusmemon(0);
        $vcdplusglitchon(0);
        $vcdplusdeltacycleon();
end

endmodule


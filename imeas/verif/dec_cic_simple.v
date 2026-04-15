// Simplified CIC filter from decimator.sv with SINC_3_EN defined
// FILTER_DATA_WIDTH = 24, COUNTER_SIZE = 12, OSR_SIZE = 4
// CN_SIZE = 24+24+2 = 50
// FORMAT=2'b00 (Din: 0->0, 1->+1), active-low RST (RST=0 resets)
// ADCEN always = 1
`timescale 1ns/1ps

module dec_cic_simple (
    input  wire        CLK4M,
    input  wire        RST,    // active-high: ~RST means reset
    input  wire        Din,
    input  wire [3:0]  OSR,
    output wire [23:0] Dout,
    output wire        TRIG
);
    localparam CN = 50;  // CN_SIZE = FILTER_DATA_WIDTH + 24 + 2 = 50

    // Integrators (run at full CLK4M rate)
    reg  [CN-1:0] delta1;
    reg  [CN-1:0] CN0, CN1;

    // Comb delay registers (update only on TRIG)
    reg  [CN-1:0] DN0, DN1, DN3, DN5;

    // Comb outputs (purely combinatorial)
    reg  [CN-1:0] CN3_w, CN4_w, CN5_w;

    // Counter
    reg  [11:0] count;

    // TRIG = (count == 8*2^OSR - 1)
    assign TRIG = (count == ((12'h8 << OSR) - 12'h1));

    // Integrator 1: delta1 (FORMAT=2'b00: add 0 or 1)
    always @(negedge RST or posedge CLK4M)
        if (~RST) delta1 <= {CN{1'b0}};
        else      delta1 <= delta1 + {{(CN-1){1'b0}}, Din};

    // Integrators 2 & 3
    always @(negedge RST or posedge CLK4M)
        if (~RST) begin
            CN0 <= {CN{1'b0}};
            CN1 <= {CN{1'b0}};
        end else begin
            CN0 <= CN0 + delta1;
            CN1 <= CN1 + CN0;
        end

    // Comb delay registers: capture on TRIG
    always @(negedge RST or posedge CLK4M)
        if (~RST) begin
            DN0 <= {CN{1'b0}}; DN1 <= {CN{1'b0}};
            DN3 <= {CN{1'b0}}; DN5 <= {CN{1'b0}};
        end else if (TRIG) begin
            DN0 <= CN1;      // sample integrator output
            DN1 <= DN0;      // previous sample
            DN3 <= CN3_w;    // sample 1st comb output (combinatorial)
            DN5 <= CN4_w;    // sample 2nd comb output (combinatorial)
        end

    // Comb differences (purely combinatorial)
    always @(*) CN3_w = DN0 - DN1;
    always @(*) CN4_w = CN3_w - DN3;
    always @(*) CN5_w = CN4_w - DN5;

    // Output bit-slice based on OSR (FILTER_DATA_WIDTH=24)
    // Dout_tmp[24:0] is the 25-bit intermediate result
    wire [24:0] Dout_tmp;
    assign Dout_tmp =
        (OSR==4'h0) ? {CN5_w[10:0], 14'b0} :    // OSR=8
        (OSR==4'h1) ? {CN5_w[13:0], 11'b0} :    // OSR=16
        (OSR==4'h2) ? {CN5_w[16:0],  8'b0} :    // OSR=32
        (OSR==4'h3) ? {CN5_w[19:0],  5'b0} :    // OSR=64
        (OSR==4'h4) ? {CN5_w[22:0],  2'b0} :    // OSR=128
        (OSR==4'h5) ? CN5_w[25:1]          :    // OSR=256
        (OSR==4'h6) ? CN5_w[28:4]          :    // OSR=512
        (OSR==4'h7) ? CN5_w[31:7]          :    // OSR=1024
        (OSR==4'h8) ? CN5_w[34:10]         :    // OSR=2048
        (OSR==4'h9) ? CN5_w[37:13]         :    // OSR=4096
                      CN5_w[37:13];

    // FORMAT=2'b00: no overflow management, take [23:0]
    assign Dout = Dout_tmp[23:0];

    // Counter (COUNTER_SIZE=12)
    always @(negedge RST or posedge CLK4M)
        if (~RST)
            count <= {12{1'b1}};    // ffff init → TRIG won't fire immediately
        else begin
            if (count < ((12'h8 << OSR) - 12'h1))
                count <= count + 12'h1;
            else
                count <= 12'h0;
        end

endmodule

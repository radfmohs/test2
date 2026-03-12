`timescale 1us/1us

module kaiser_fir_19taps (
    input wire clk,                  // 16 kHz clock
    input wire rst,                  // Active-high reset
    input wire [31:0] data_in,       // 32-bit input sample (Q1.31)
    output reg [31:0] data_out       // 32-bit filtered output (Q1.31)
);

    // Number of taps
    localparam NTAPS = 19;

    // Normalized Kaiser window FIR coefficients, Q1.31 format
    // Generated for cutoff 1024Hz @ 16kHz, beta=1, sum=1.0, scaled to Q1.31
    reg signed [31:0] coeffs [0:NTAPS-1];
    initial begin
        coeffs[0]  = 32'sd14696854;
        coeffs[1]  = 32'sd45447654;
        coeffs[2]  = 32'sd111160634;
        coeffs[3]  = 32'sd229591866;
        coeffs[4]  = 32'sd447683217;
        coeffs[5]  = 32'sd807572376;
        coeffs[6]  = 32'sd1379735949;
        coeffs[7]  = 32'sd2229501911;
        coeffs[8]  = 32'sd3349728151;
        coeffs[9]  = 32'sd4020533794;
        coeffs[10] = 32'sd3349728151;
        coeffs[11] = 32'sd2229501911;
        coeffs[12] = 32'sd1379735949;
        coeffs[13] = 32'sd807572376;
        coeffs[14] = 32'sd447683217;
        coeffs[15] = 32'sd229591866;
        coeffs[16] = 32'sd111160634;
        coeffs[17] = 32'sd45447654;
        coeffs[18] = 32'sd14696854;
    end

    // Shift register for input samples
    reg signed [31:0] shift_reg [0:NTAPS-1];

    // Output accumulator as 64 bits to prevent overflow
    reg signed [63:0] acc;

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < NTAPS; i = i + 1)
                shift_reg[i] <= 32'sd0;
            data_out <= 32'sd0;
        end else begin
            // Shift input samples
            for (i = NTAPS-1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= data_in;

            // FIR filter multiply-accumulate
            acc = 64'sd0;
            for (i = 0; i < NTAPS; i = i + 1) begin
                acc = acc + shift_reg[i] * coeffs[i];
            end

            // Output Q1.31: take acc[61:30]
            data_out <= acc[61:30];
        end
    end

endmodule

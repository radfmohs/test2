//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    temp_sar_t_nom.v 
// Module Name : temp_sar_t_nom
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module temp_sar_t_nom 
#(
  parameter WIDTH_VDAC = 8 
)

(
    input clk,
    input resetn,
    //input start,

    input wire [7:0]  sample_duration,
    input tsc_comp_low_ch1,
    input a2d_tsc_comp_out_ch1,         // 1 if Vin > Vdac, else 0
    output wire [WIDTH_VDAC -1 :0] VDAC_NOR_OUT,     // SAR output connected to DAC
    output reg [WIDTH_VDAC -1:0] VDAC_NOR,
    output reg done
    //output wire busy_doing
);

 // FSM states
/*
 typedef enum wire [2:0] {
        IDLE = 3'b000,
        SET_BIT = 3'b001,
        COMPARE = 3'b010,
        WAIT = 3'b011,
        FINISH = 3'b100
    } state_t;

    state_t state, next_state;
*/
localparam  IDLE = 3'b000;
localparam  SET_BIT = 3'b001;
localparam  COMPARE = 3'b010;
localparam  WAIT = 3'b011;
localparam  FINISH = 3'b100;

reg[2:0] state;
reg[2:0] next_state;

    //reg done;
    reg [WIDTH_VDAC -1 :0] sar_out;     // SAR output connected to DAC
    assign VDAC_NOR_OUT=sar_out;

    //wire busy_doing;
    //assign busy_doing = (state!=IDLE);
wire a2d_tsc_comp_out_ch1_check;
assign a2d_tsc_comp_out_ch1_check = tsc_comp_low_ch1 ? ~a2d_tsc_comp_out_ch1 : a2d_tsc_comp_out_ch1;

reg[7:0]    sample_duration_cnt;
always @ (posedge clk or negedge resetn) begin
  if (~resetn)
        sample_duration_cnt <= 8'b0;
  else if (sample_duration_cnt == sample_duration)
        sample_duration_cnt <= 8'b0;
  else if (state==WAIT)
        sample_duration_cnt <= sample_duration_cnt + 8'b1;
end

always @(posedge clk or negedge resetn) begin
        if (~resetn)
     		VDAC_NOR <= {WIDTH_VDAC{1'b0}};
	else if(done)
     		VDAC_NOR <= sar_out;
end

//    reg [WIDTH_VDAC -1 :0] trial_code;
    reg [3:0] bit_pos;

// State register
always @(posedge clk or negedge resetn) begin
        if (~resetn)
            state <= IDLE;
        else
            state <= next_state;
    end

reg start_0;
reg start_1;
always @(posedge clk or negedge resetn) begin
        if (~resetn) begin 
		start_0 <= 1'b0;
		start_1 <= 1'b0;
	end else begin
	    	start_0 <= 1'b1;
	    	start_1 <= start_0;
	end
end

wire start;
assign start = start_0 & (!start_1);

// FSM next state logic
always @(*) begin
        case (state)
            IDLE:    next_state = (start) ? SET_BIT : IDLE;
            SET_BIT: next_state = WAIT;
            WAIT:    next_state = (sample_duration_cnt == sample_duration) ? COMPARE : WAIT;
            COMPARE: next_state = (bit_pos == 0) ? FINISH : SET_BIT;
            FINISH:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end


// Output and control logic
always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            sar_out    <= {WIDTH_VDAC{1'b0}};
            bit_pos    <= WIDTH_VDAC -4'b1;
//            trial_code <= {WIDTH_VDAC{1'b0}};
            done       <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done    <= 0;
                    sar_out <= {WIDTH_VDAC{1'b0}};
//                    trial_code <= {WIDTH_VDAC{1'b0}};
                    bit_pos <= WIDTH_VDAC -4'b1;
                end

                SET_BIT: begin
//                    trial_code <= sar_out | (1 << bit_pos);
                    sar_out <= sar_out | ({{(WIDTH_VDAC-1){1'b0}},1'b1} << bit_pos); // Drive DAC
                end

                WAIT: begin
		end

                COMPARE: begin                    
                        bit_pos <= bit_pos - 4'b1;			
                    if (a2d_tsc_comp_out_ch1_check)
                        sar_out[bit_pos] <= 1;  // Keep bit
                    else
                        sar_out[bit_pos] <= 0;  // Clear bit
                end

                FINISH: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule





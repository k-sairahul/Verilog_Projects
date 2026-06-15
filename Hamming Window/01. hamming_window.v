`timescale 1ps/1ps
module hamming_window (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire signed [15:0] sample_in,
    input  wire [8:0]  idx,
    output reg         done,
    output reg  [15:0] windowed_out
);
    localparam signed [15:0] TWO_PI = 16'd25736;
    localparam signed [15:0] ALPHA  = 16'd2212;
    localparam signed [15:0] BETA   = 16'd1884;

    // Internal CORDIC signals
    reg  start_cordic;
    wire cordic_done;
    wire signed [15:0] cos_out, sin_out;

    reg signed [31:0] theta_wide;
    reg signed [15:0] theta;

    reg signed [31:0] coeff;
    reg signed [31:0] windowed_result;
    reg signed [15:0] sample_reg;
    // FSM
    reg [2:0] state;
    localparam IDLE       = 0,
    THETA_CALC = 1,
    START_CRD  = 2,
    WAIT_CRD   = 3,
    COMPUTE    = 4;

    cordic_rv cordic_inst (
        .clk(clk), .rst(rst),
        .start(start_cordic),
        .x_in(16'd2487), .y_in(16'd0),
        .theta_in(theta),
        .done(cordic_done),
        .x_out(cos_out), .y_out(sin_out)
        );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            start_cordic    <= 0;
            done            <= 0;
            windowed_out    <= 0;
            theta_wide      <= 0;
            theta           <= 0;
            coeff           <= 0;
            windowed_result <= 0;
            state           <= IDLE;
        end

        else
        begin
            done <= 0; // default
            case (state)
                IDLE: begin
                    if (start)
                    begin
                        sample_reg <= sample_in;
                        theta_wide <= (($signed(TWO_PI) * $signed({1'b0, idx}) * 18'd257)    >>> 17);                        
                        state <= THETA_CALC;                    
                    end
                end

                THETA_CALC: begin
                    theta        <= theta_wide[15:0];
                    start_cordic <= 1;
                    state        <= START_CRD;
                end

                START_CRD: begin
                    start_cordic <= 0;
                    state        <= WAIT_CRD;
                end

                WAIT_CRD: begin                
                    if (cordic_done)
                    begin                
                        coeff <= ALPHA - ((BETA * cos_out) >>> 12);                
                        state <= COMPUTE;
                    end                
                end

                COMPUTE: begin            
                    windowed_result <= (sample_reg * coeff) >>> 12;                
                    windowed_out <= ((sample_reg * coeff) >>> 12);                
                    done <= 1'b1;                
                    state <= IDLE;                
                end     
            endcase
        end
    end
endmodule

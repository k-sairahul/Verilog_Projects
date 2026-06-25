`timescale 1ns/1ps
module detector(
    input clk, rst, din, valid,
    input [1:0] mode,
    output [7:0] led
);
reg [7:0] count;
reg [1:0] mode_prev;
reg [3:0] state;
reg match_found; //Internal flag to strobe whenever a sequence completes

// Moore states
localparam s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100;
// Mealy states          
localparam s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000;

localparam MOORE_NONOVERLAP = 2'b00,
           MOORE_OVERLAP    = 2'b01,
           MELAY_NONOVERLAP = 2'b10,
           MELAY_OVERLAP    = 2'b11;

always @(posedge clk or posedge rst) begin
    if (rst) mode_prev <= 2'b00;
    else mode_prev <= mode;
end

always @(*) begin
    match_found = 1'b0;
    if (valid) begin
        case (mode)
            // MOORE
            MOORE_NONOVERLAP, MOORE_OVERLAP: begin
                match_found = (state == s4);
            end
           
            // Mealy
            MELAY_NONOVERLAP, MELAY_OVERLAP: begin
                match_found = (state == s8 && din == 1'b0);
            end
           
            default: match_found = 1'b0;
        endcase
    end
end

// FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= s0;
    end
    else if (mode != mode_prev) begin
        state <= mode[1] ? s5 : s0;
    end
    else if (valid) begin
        case (mode)
            MOORE_NONOVERLAP: begin
                case(state)
                    s0: state <= din ? s0 : s1;
                    s1: state <= din ? s0 : s2;
                    s2: state <= din ? s3 : s2;
                    s3: state <= din ? s0 : s4;
                    s4: state <= din ? s0 : s1;
                    default: state <= s0;
                endcase
            end

            MOORE_OVERLAP: begin
                case(state)
                    s0: state <= din ? s0 : s1;
                    s1: state <= din ? s0 : s2;
                    s2: state <= din ? s3 : s2;
                    s3: state <= din ? s0 : s4;
                    s4: state <= din ? s0 : s2;
                    default: state <= s0;
                endcase
            end

            MELAY_NONOVERLAP: begin
                case (state)
                    s5: state <= din ? s5 : s6;
                    s6: state <= din ? s5 : s7;
                    s7: state <= din ? s8 : s7;
                    s8: state <= din ? s5 : s5;
                    default: state <= s5;
                endcase
            end

            MELAY_OVERLAP: begin
                case (state)
                    s5: state <= din ? s5 : s6;
                    s6: state <= din ? s5 : s7;
                    s7: state <= din ? s8 : s7;
                    s8: state <= din ? s5 : s7;
                    default: state <= s5;
                endcase
            end
            default: state <= s0;
        endcase
    end
end

// Counter Logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
    end
    else if (mode != mode_prev) begin
        count <= 0;
    end
    else if (valid && match_found) begin
        count <= count + 1;
    end
end
assign led = count;
endmodule

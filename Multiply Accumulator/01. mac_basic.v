`timescale 1ns/1ps
module mac_basic(
    input clk,
    input rst,
    input en,
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    output reg [31:0] Y
);

    always @(posedge clk) begin
        if (rst)
            Y <= 0;
        else if (en)
            Y <= (A * B) + C;
    end

endmodule

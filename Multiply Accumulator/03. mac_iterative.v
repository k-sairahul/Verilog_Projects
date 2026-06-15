`timescale 1ns/1ps
module mac_iterative (
    input clk,
    input rst,
    input start,
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    output reg done,
    output reg [31:0] Y
);

    reg [63:0] product;
    reg [31:0] multiplicand;
    reg [31:0] multiplier;
    reg [5:0] count;

    always @(posedge clk) begin
        if (rst) begin
            product <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            count <= 0;
            done <= 0;
            Y <= 0;
        end
        else if (start) begin
            product <= 0;
            multiplicand <= A;
            multiplier <= B;
            count <= 0;
            done <= 0;
        end
        else if (count < 32) begin
            if (multiplier[0])
                product <= product + multiplicand;

            multiplicand <= multiplicand << 1;
            multiplier <= multiplier >> 1;
            count <= count + 1;
        end
        else if (count == 32) begin
            Y <= product[31:0] + C;
            done <= 1;
            count <= count + 1;
        end
    end

endmodule

`timescale 1ns/1ps
module tb_dotproduct;
reg [7:0]a0,a1,a2,a3,a4,a5,a6,a7;
reg [7:0]b0,b1,b2,b3,b4,b5,b6,b7;
reg clk;
wire [26:0]y;

dotproduct uut(
  .a0(a0), .a1(a1), .a2(a2), .a3(a3), .a4(a4), .a5(a5), .a6(a6), .a7(a7),
  .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5), .b6(b6), .b7(b7),
  .clk(clk),
  .y(y)
);

initial begin clk = 0; forever #5 clk = ~clk; end

initial begin
  a0 = 0; a1 = 1;a2=2;a3=3;a4=4;a5=5;a6=6;a7=7;
  b0=8;b1=9;b2=10;b3=11;b4=12;b5=13;b6=14;b7=15;
  #50; $finish;
end
endmodule

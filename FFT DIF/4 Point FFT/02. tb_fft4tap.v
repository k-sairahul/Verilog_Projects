`timescale 1ns/1ps
module tb_fft4tap;
reg clk;
reg signed [15:0] x0r, x0i;
reg signed [15:0] x1r, x1i;
reg signed [15:0] x2r, x2i;
reg signed [15:0] x3r, x3i;
wire signed [17:0] y0r, y0i;
wire signed [17:0] y1r, y1i;
wire signed [17:0] y2r, y2i;
wire signed [17:0] y3r, y3i;

fft4tap uut (
    .clk(clk),
    .x0r(x0r), .x0i(x0i),
    .x1r(x1r), .x1i(x1i),
    .x2r(x2r), .x2i(x2i),
    .x3r(x3r), .x3i(x3i),
    .y0r(y0r), .y0i(y0i),
    .y1r(y1r), .y1i(y1i),
    .y2r(y2r), .y2i(y2i),
    .y3r(y3r), .y3i(y3i)
);

initial begin  clk = 0;  forever #5 clk = ~clk; end

initial
begin
    $dumpfile("wave.vcd"); $dumpvars(0);
    // Inputs 1 
    x0r = 6;   x0i = 0;
    x1r = 5;   x1i = 0;
    x2r = 4;   x2i = 0;
    x3r = 3;   x3i = 0;
    #30;
    $display("Y0 = %0d + j%0d", y0r, y0i);
    $display("Y1 = %0d + j%0d", y1r, y1i);
    $display("Y2 = %0d + j%0d", y2r, y2i);
    $display("Y3 = %0d + j%0d", y3r, y3i);

    // Inputs 2
    x0r = 10;   x0i = -96;
    x1r = 20;   x1i = 20;
    x2r = 30;   x2i = 49;
    x3r = 40;   x3i = -27;
    #30;
    $display("---------------------------");
    $display("Y0 = %0d + j%0d", y0r, y0i);
    $display("Y1 = %0d + j%0d", y1r, y1i);
    $display("Y2 = %0d + j%0d", y2r, y2i);
    $display("Y3 = %0d + j%0d", y3r, y3i);

    #10; $finish;
end
endmodule

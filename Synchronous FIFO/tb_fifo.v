`timescale 1ns / 1ps
module tb_fifo;
    localparam WIDTH = 8,
               DEPTH = 4;
    reg clk, rst, wr_en, rd_en;
    reg [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out; 
    wire full, empty;

fifo uut(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);

initial
begin
    clk = 0; wr_en=0;rd_en=0;rst=1;
    forever #5 clk = ~ clk;
end

always@(posedge clk)
begin
    #5; rst = 0;
    #0; data_in = 8'b00000001;
    #5; data_in = 8'b10000000;
    #10; wr_en = 1;
    #10; data_in = 8'b00000010;
    #10; data_in = 8'b00000011;
    #10; rd_en = 1;
    #10; data_in = 8'b00000100;
    #10; data_in = 8'b00000101;
    #50; $finish;
end

endmodule
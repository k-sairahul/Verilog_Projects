/*
`timescale 1ns / 1ps
module tb_elevator;
    reg clk, rst;
    reg sw2,sw3,sw4,sw5,sw6,sw7;
    wire [2:0]led ;

elevator uut(
    .clk(clk),
    .rst(rst),
    .sw2(sw2),
    .sw3(sw3),
    .sw4(sw4),
    .sw5(sw5),
    .sw6(sw6),
    .sw7(sw7),
    .led(led)
);

initial
begin
    clk = 0;
end
always
begin
    #5 clk = ~clk ;
end

initial
begin
    current_floor = 2
end


endmodule
*/
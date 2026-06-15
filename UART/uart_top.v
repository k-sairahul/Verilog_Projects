`timescale 1ns/1ps
module uart_top (
input clk,rst,

input [7:0]data_in,
input tx_start,
output tx, tx_done,

input rx,
output rx_done,
output [7:0] data_out

);
wire tx_tick, rx_tick;

baud_generator uut1 (
    .clk(clk),
    .rst(rst),
    .tx_tick(tx_tick),
    .rx_tick(rx_tick)    
);

uart_tx uut2 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .tx_start(tx_start),
    .tx_tick(tx_tick),
    .tx(tx),
    .tx_done(tx_done)   
);

uart_rx uut3 (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_done(rx_done),
    .rx_tick(rx_tick),
    .data_out(data_out)
);

endmodule
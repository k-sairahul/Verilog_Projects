`timescale 1ns / 1ps
module baud_generator(
    input clk,rst,
    output wire tx_tick, rx_tick
    );    
    
    integer counter_rx, counter_tx;
    
    always@(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            counter_tx <= 0;
            counter_rx <= 0;
        end
        else
        begin
            if (counter_rx == 53) //  (100Mhz) / (115200 x 16) = 54 => 16x to match for the Rx
                counter_rx <= 0;
            else
                counter_rx <= counter_rx + 1;
            if (counter_tx == 867 )  // (100Mhz) / (115200 ) = 868
                counter_tx <= 0;  
            else
                counter_tx <= counter_tx + 1 ;
        end

    end

    assign rx_tick = (counter_rx == 53);
    assign tx_tick = (counter_tx == 867);
endmodule

`timescale 1ns/1ps
module uart_rx (
    input clk,rst,rx_tick,rx,
    output reg rx_done,
    output reg [7:0] data_out

);
reg [1:0] state;
reg [3:0] tick_counter = 0;
reg [2:0] bit_index;
reg [7:0] temp_data_out;

localparam IDLE = 2'b00,
            START = 2'b01,
            DATA = 2'b10,
            STOP = 2'b11;
            
always@(posedge clk or posedge rst)
begin
    if (rst)
    begin
        rx_done <= 0;
        bit_index <= 0;
        tick_counter <= 0 ;
        state<= IDLE;
    end
    
    else
    begin
        case (state)
            IDLE: begin
                rx_done <= 0;
                tick_counter <= 0;
                bit_index <= 0;
                if (rx == 1'b0)
                begin
                    state <= START;                    
                end 
            end
            
            START: begin
                if (rx_tick)
                begin
                    if (tick_counter == 7)
                    begin
                        tick_counter <= 0;
                        if (rx == 1'b0)  state <= DATA;
                        else state <= IDLE;
                    end                    
                    else
                    begin
                        tick_counter <= tick_counter + 1 ;
                    end
                end
            end
            
            DATA: begin
                if (rx_tick)
                begin
                    if (tick_counter == 15)
                    begin
                        temp_data_out [bit_index] <= rx ;
                        tick_counter <= 0;
                        if (bit_index == 7) state <= STOP ;
                        else bit_index <= bit_index + 1;
                    end
                    else tick_counter <= tick_counter + 1;
                end
            end
            
            STOP: begin
                if(rx_tick)
                begin
                    if (tick_counter == 15)
                    begin                 
                        tick_counter <= 0 ;
                        rx_done <= 1'b1;
                        state <= IDLE;
                        data_out <= temp_data_out ;
                    end
                    else tick_counter <= tick_counter + 1 ;
                end
            end
        endcase
    end
end
endmodule

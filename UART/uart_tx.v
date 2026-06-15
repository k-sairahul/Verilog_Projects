`timescale 1ns/1ps
module uart_tx(
    input clk,rst,
    input tx_tick,tx_start, //tx_tick -> comes from baud generator
    input [7:0] data_in,
    output reg tx_done, tx
);

reg [1:0] state;
reg [3:0] tick_counter = 0;
reg [2:0] bit_index = 0;
reg [7:0] temp_data_in;

localparam IDLE = 2'b00,
            START = 2'b01,
            DATA = 2'b10,
            STOP = 2'b11;

always @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        tx <= 1'b1;
        tx_done <= 1'b0;
        tick_counter <= 0;
        bit_index <= 0;
        temp_data_in <= 0;
        
    end
    
    else
    begin
        case(state)
            IDLE: begin
                tx<=1'b1;
                tx_done <= 1'b0;
                tick_counter <= 0;
                bit_index <= 0;
                temp_data_in <= 0;
                
                if(tx_start) begin
                    state <= START;
                    temp_data_in <= data_in ; 
                end
            end
            
            START: begin
                tx <= 1'b0;
                if(tx_tick)
                begin
                    state <= DATA;
                end
            end
            
            DATA : begin
                tx <= temp_data_in[bit_index];
                if (tx_tick)
                begin
                     if (bit_index == 7)
                     begin
                        state <= STOP;
                     end
                     else
                        bit_index <= bit_index + 1 ;
                end
            end
            
            STOP: begin
                tx <= 1'b1;
                if (tx_tick)
                begin
                    tx_done <= 1'b1;
                    state <= IDLE;  
                end
            end
        endcase
    end
end

endmodule
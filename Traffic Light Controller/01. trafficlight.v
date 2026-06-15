`timescale 1ns / 1ps

module trafficlight(
input clk, rst,
output reg [2:0] led
);

reg [26:0] counter_1s ;
reg [4:0] sec1_counter_30;
reg [2:0] sec1_counter_5;

reg sec_1 ;
reg sec_5;
reg sec_30;

reg [1:0] state ;
localparam RED = 2'b00;
localparam YELLOW = 2'b01;
localparam GREEN = 2'b10;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        counter_1s <= 0; sec_1<=0; sec_30<=0; sec_5<= 0; sec1_counter_30<= 0;
        sec1_counter_5 <= 0;
    end
    
    else
    begin
        sec_1  <= 0;
        sec_5  <= 0;
        sec_30 <= 0;

        if(counter_1s == 9999_9999) begin
            counter_1s <= 0;
            sec_1 <= 1;

            if(sec1_counter_5 == 4) begin
                sec1_counter_5 <= 0;
                sec_5 <= 1;
            end
            else
                sec1_counter_5 <= sec1_counter_5 + 1;

            if(sec1_counter_30 == 29) begin
                sec1_counter_30 <= 0;
                sec_30 <= 1;
            end
            else
                sec1_counter_30 <= sec1_counter_30 + 1;
        end
        else
            counter_1s <= counter_1s + 1;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= RED;
        led<= 3'b100;
    end
    else begin
        case (state)
            RED: begin  
                led <= 3'b100;          
                if (sec_30)
                    state <= YELLOW;
            end

            YELLOW: begin
                led <= 3'b010;
                if (sec_5)
                    state <= GREEN;
            end

            GREEN: begin
                led <= 3'b001;
                if(sec_30)
                    state <= RED;
            end
        endcase
    end
end
endmodule

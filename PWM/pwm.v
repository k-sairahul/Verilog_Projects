// PWM 1K Hz => 50%, 30%
`timescale 1ns / 1ps
module pwm(
    input clk,
    output reg [7:0] led,
    input sw
    );

reg [26:0]counter = 0; 

always @ (posedge clk)
begin
    counter <= counter + 1;
    case(sw)
        1'b0: begin
            if (counter <= 30000)
            begin
               led <= 8'b11111111;
            end
            
            if (counter > 30000 && counter < 100000)
            begin
               led <= 8'b00000000;
            end   
             
            if (counter == 100000)
                counter <= 0;        
        end 
    
        1'b1: begin
            if (counter <= 50000)
                begin
                   led <= 8'b11111111;
                end
                
                if (counter > 50000 && counter < 100000)
                begin
                   led <= 8'b00000000;
                end   
                 
                if (counter == 100000)
                    counter <= 0;             
        end
        
    endcase
end
endmodule

`timescale 1ns / 1ps
module elevator(
    input clk, rst,
    input sw2,sw3,sw4,sw5,sw6,sw7, 
    output [2:0]led,
    output reg door_open
    );
    
reg [1:0] current_floor;
reg [1:0] target_floor;
reg [26:0] counter;
reg [3:0] door_open_timer;
reg tick;

reg [3:0] state;
localparam IDLE = 0;
localparam MOVE = 1;
localparam DOOR_OPEN = 2;
localparam LIFT_BTN = 3;
localparam FLOOR_BTN = 4;

//Tick generator
always @ (posedge clk)
begin
    if (rst)
    begin
        counter <= 0;
        tick <= 0;
    end
    
    else 
    begin
        if (counter == 99999999) begin
            tick <= 1 ;
            counter <= 0 ;
        end
        else begin
            tick <= 0 ;
            counter <= counter + 1 ;
        end 
    end
end


assign led = current_floor;

always @(posedge clk ) begin
    if (rst)
    begin
        current_floor <= 0;
        target_floor <= 0;
        state <= IDLE;
        door_open <= 0;
        door_open_timer <= 0;
    end 
    else
    begin
        case (state)
            IDLE: begin
                state <= (sw2 || sw3 || sw4 )? LIFT_BTN:
                         (sw5 || sw6 || sw7 )? FLOOR_BTN : IDLE ;
            end

            MOVE: begin
                if (tick)
                begin
                    if (current_floor < target_floor)
                    begin
                        current_floor <= current_floor + 1;
                    end
                    else if (current_floor > target_floor)
                    begin
                        current_floor <= current_floor - 1;
                    end
                    else
                        state <= DOOR_OPEN;                    
                end
            end

            DOOR_OPEN: begin
                if (tick)
                begin
                    if (door_open_timer < 3)
                    begin
                        door_open_timer <= door_open_timer + 1;
                        door_open <= 1;
                    end
                    else
                    begin
                        door_open_timer <= 0;
                        door_open <= 0;
                        state <= IDLE;
                    end
                end
            end

            LIFT_BTN: begin
                if(sw2) begin
                    target_floor <= 0;
                    state <= MOVE;
                end                    
                else if(sw3) begin
                    target_floor <= 1;
                    state <= MOVE;
                end
                else if(sw4)begin
                    target_floor <= 2;
                    state <= MOVE;
                end 
            end

            FLOOR_BTN: begin
                if (sw5)
                begin
                    target_floor <= 2'b00;
                    state <= MOVE;
                end
                else if (sw6)
                begin
                    target_floor <= 2'b01;
                    state <= MOVE;
                end
                else if (sw7)
                begin
                    target_floor <= 2'b10;
                    state <= MOVE;
                end
            end

            default: state <= IDLE;

        endcase
    end
end
endmodule

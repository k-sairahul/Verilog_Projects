module cordic_rv (
    input  wire        start,
    input  wire        clk,
    input  wire        rst,
    input  wire signed [15:0] x_in,
    input  wire signed [15:0] y_in,
    input  wire signed [15:0] theta_in,
    output reg         done,
    output reg  signed [15:0] x_out,
    output reg  signed [15:0] y_out
);

localparam signed [15:0] PI_OVER_2 = 16'sd6434;
localparam signed [15:0] PI        = 16'sd12868;
localparam signed [15:0] TWO_PI    = 16'sd25736;
localparam signed [15:0] NEG_PI    = -16'sd12868;

reg signed [15:0] z_temp;

localparam IDLE = 2'd0,
           INIT = 2'd1,
           CALC = 2'd2,
           EXIT = 2'd3;

reg [1:0] state;
reg [3:0] i;

reg signed [15:0] x;
reg signed [15:0] y;
reg signed [15:0] z;

reg signed [15:0] x_next;
reg signed [15:0] y_next;
reg signed [15:0] z_next;

reg flip;

reg signed [15:0] atan_table [0:15];

initial begin
    atan_table[0]  = 16'sd3217;
    atan_table[1]  = 16'sd1899;
    atan_table[2]  = 16'sd1003;
    atan_table[3]  = 16'sd509;
    atan_table[4]  = 16'sd256;
    atan_table[5]  = 16'sd128;
    atan_table[6]  = 16'sd64;
    atan_table[7]  = 16'sd32;
    atan_table[8]  = 16'sd16;
    atan_table[9]  = 16'sd8;
    atan_table[10] = 16'sd4;
    atan_table[11] = 16'sd2;
    atan_table[12] = 16'sd1;
    atan_table[13] = 16'sd0;
    atan_table[14] = 16'sd0;
    atan_table[15] = 16'sd0;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        state <= IDLE;
        done <= 1'b0;
        x_out <= 16'sd0;
        y_out <= 16'sd0;
        x <= 16'sd0;
        y <= 16'sd0;
        z <= 16'sd0;
        i <= 4'd0;
        flip <= 1'b0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            done <= 1'b0;
            if(start)
            begin
                state <= INIT;
            end
        end

        INIT:
        begin
            x <= x_in;
            y <= y_in;
            i <= 4'd0;
            flip <= 1'b0;

            if(theta_in > PI)
                z_temp = theta_in - TWO_PI;
            else if(theta_in < -PI)
                z_temp = theta_in + TWO_PI;
            else
                z_temp = theta_in;

            if(z_temp > PI_OVER_2)
            begin
                z <= z_temp - PI;
                flip <= 1'b1;
            end
            else if(z_temp < -PI_OVER_2)
            begin
                z <= z_temp + PI;
                flip <= 1'b1;
            end
            else
            begin
                z <= z_temp;
            end

            state <= CALC;
        end

        CALC:
        begin
            if(z >= 0)
            begin
                x_next = x - (y >>> i);
                y_next = y + (x >>> i);
                z_next = z - atan_table[i];
            end
            else
            begin
                x_next = x + (y >>> i);
                y_next = y - (x >>> i);
                z_next = z + atan_table[i];
            end

            x <= x_next;
            y <= y_next;
            z <= z_next;

            if(i == 4'd15)
            begin
                state <= EXIT;
            end
            else
            begin
                i <= i + 1'b1;
            end
        end

        EXIT:
        begin
            if(flip)
            begin
                x_out <= -x;
                y_out <= -y;
            end
            else
            begin
                x_out <= x;
                y_out <= y;
            end

            done <= 1'b1;
            state <= IDLE;
        end

        default:
        begin
            state <= IDLE;
        end

        endcase
    end
end

endmodule

`timescale 1ns/1ps
module fft4tap(
    input clk,rst,
    input [7:0] s_axis_config_tdata,
    input  s_axis_config_tvalid,
    output reg s_axis_config_tready,
    input signed [31:0] s_axis_data_tdata,
    input s_axis_data_tvalid,
    output reg s_axis_data_tready,
    input s_axis_data_tlast,
    output reg signed [35:0] m_axis_data_tdata,
    output reg m_axis_data_tlast,
    output reg m_axis_data_tvalid,
    input m_axis_data_tready
);

reg [15:0] input_samples [0:3];
wire [35:0] output_samples [0:3];
reg [2:0] input_count, output_count ;
reg start = 0;
reg [3:0] temp_count = 0 ;

wire signed [17:0] y0r,y0i;
wire signed [17:0] y1r,y1i;
wire signed [17:0] y2r,y2i;
wire signed [17:0] y3r,y3i;

main uut (
    .clk(clk),
    .start(start),
    .x0(input_samples[0]),
    .x1(input_samples[1]),
    .x2(input_samples[2]),
    .x3(input_samples[3]),
    .y0r(y0r),  .y0i(y0i),
    .y1r(y1r),  .y1i(y1i),
    .y2r(y2r),  .y2i(y2i),
    .y3r(y3r),  .y3i(y3i)
);

assign output_samples[0] = {y0i,y0r};
assign output_samples[1] = {y1i,y1r};
assign output_samples[2] = {y2i,y2r};
assign output_samples[3] = {y3i,y3r};


reg [3:0]state;
localparam IDLE = 4'h0,
            INPUT = 4'h1,
            PROCESS = 4'h2,
            OUTPUT = 4'h3;

always @ (posedge clk or posedge rst)
begin
    if (rst)
    begin
        s_axis_config_tready <= 0;
        s_axis_data_tready <= 0;
        m_axis_data_tdata <= 0;
        m_axis_data_tlast <= 0;
        m_axis_data_tvalid <= 0;
        start <= 0;
        state <= IDLE;
        input_count <= 0;
        output_count <= 0;
        temp_count <= 0;
    end
    else
    begin
        case (state)
            IDLE :
            begin
                if ( s_axis_config_tvalid && s_axis_config_tdata[0] )
                begin
                    state <= INPUT;
                    s_axis_config_tready <= 1'b1 ;
                    s_axis_data_tready <= 1'b1 ;
                end
                
                m_axis_data_tlast <= 0;
                m_axis_data_tvalid <= 0;
                input_count <= 0;
                output_count <= 0;
                temp_count <= 0;
            end

            INPUT:
            begin
                if ( s_axis_data_tvalid && s_axis_data_tready && input_count < 4 )
                begin
                    input_samples[input_count] <= s_axis_data_tdata[15:0] ;
                    input_count <= input_count + 1 ;
                    if (s_axis_data_tlast)
                    begin
                        state <= PROCESS;
                        s_axis_config_tready <= 0 ;
                        s_axis_data_tready <= 0;
                    end
                end
            end

            PROCESS:
            begin
                if (!temp_count)  start <= 1'b1 ;
                else start<= 0;

                if (temp_count<5)
                    temp_count <= temp_count + 1 ;
                else
                begin
                    m_axis_data_tvalid <= 1'b1;
                    state <= OUTPUT ;
                end
            end

            OUTPUT:
            begin
                if (m_axis_data_tvalid && m_axis_data_tready)
                begin
                    if (output_count < 4 && !m_axis_data_tlast)
                    begin
                        m_axis_data_tdata <= output_samples[output_count] ;
                        m_axis_data_tlast <= (output_count == 3) ;

                        if (output_count == 3)
                        begin
                            start <= 0;
                            state <= IDLE;
                        end
                        else
                            output_count <= output_count + 1 ;
                    end
                end
            end

            default : state <= IDLE;
        endcase
    end
end
endmodule

module main(
    input clk,start,
    input signed [15:0] x0,x1,x2,x3,
    output signed [17:0] y0r,y0i,y1r,y1i,y2r,y2i,y3r,y3i
);

wire signed [16:0] w1r,w1i,w2r,w2i,w3r,w3i,w4r,w4i; // Stage 1 to Stage 2 connections
wire signed [16:0] w4r2,w4i2;

add1 uut1 ( .start(start), .ar(x0), .ai(16'd0), .br(x2), .bi(16'd0), .yr(w1r), .yi(w1i), .clk(clk)  );
add1 uut2 ( .start(start), .ar(x1), .ai(16'd0), .br(x3), .bi(16'd0), .yr(w2r), .yi(w2i), .clk(clk)  );
sub1 uut3 ( .start(start), .ar(x0), .ai(16'd0), .br(x2), .bi(16'd0), .yr(w3r), .yi(w3i), .clk(clk)  );
sub1 uut4 ( .start(start),  .ar(x1), .ai(16'd0), .br(x3), .bi(16'd0), .yr(w4r), .yi(w4i), .clk(clk)  );
mj uut5  ( .ar(w4r), .ai(w4i), .yr(w4r2), .yi(w4i2), .clk(clk)  );
add2 uut6 ( .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y0r), .yi(y0i), .clk(clk)  );
sub2 uut7 (  .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y2r), .yi(y2i), .clk(clk)  );
add2 uut8 (  .ar(w3r), .ai(w3i), .br(w4r2), .bi(w4i2), .yr(y1r), .yi(y1i), .clk(clk) );
sub2 uut9 ( .ar(w3r), .ai(w3i), .br(w4r2), .bi(w4i2), .yr(y3r), .yi(y3i), .clk(clk) );

endmodule

module add1(
    input signed [15:0] ar,ai,br,bi,
    input clk,start,
    output reg signed [16:0] yr, yi
);
always @ (posedge clk)
begin
    if (start)
    begin
        yr <= ar + br ;
        yi <= ai + bi ;
    end
end
endmodule

module add2(
    input signed [16:0] ar,ai,br,bi,
    input clk,
    output reg signed [17:0] yr, yi
);
always @ (posedge clk)
begin
    yr <= ar + br ;
    yi <= ai + bi ;
end
endmodule

module sub1(
    input clk,start,
    input signed [15:0] ar,ai,br,bi,
    output reg signed  [16:0] yr, yi
);
always@(posedge clk)
begin
    if (start)
    begin
        yr <= ar - br ;
        yi <= ai - bi ;
    end
end
endmodule

module sub2(
    input clk,
    input signed [16:0] ar,ai,br,bi,
    output reg signed [17:0] yr, yi
);
always@(posedge clk)
begin
    yr <= ar - br ;
    yi <= ai - bi ;
end
endmodule

module mj (
    input clk,
    input signed [16:0] ar,ai,
    output reg signed [16:0] yr,yi
);
always@(posedge clk)
begin
    yr <= ai;
    yi <= -ar;
end
endmodule

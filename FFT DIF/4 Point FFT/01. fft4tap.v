`timescale 1ns/1ps
module fft4tap(
    input clk,
    input signed [15:0] x0r,x0i,x1r,x1i,x2r,x2i,x3r,x3i,
    output signed [17:0] y0r,y0i,y1r,y1i,y2r,y2i,y3r,y3i
);

//Butterfly Coefficients, just for reference, didnt used anywhere directly
localparam W40r = 1,
            W40i = 0,
            W41r = 0,
            W41i = -1;

wire signed [16:0] w1r,w1i,w2r,w2i,w3r,w3i,w4r,w4i; // Stage 1 to Stage 2 connections
wire signed [16:0] w4r2,w4i2;

add1 uut1 ( .ar(x0r), .ai(x0i), .br(x2r), .bi(x2i), .yr(w1r), .yi(w1i), .clk(clk)  );
add1 uut2 ( .ar(x1r), .ai(x1i), .br(x3r), .bi(x3i), .yr(w2r), .yi(w2i), .clk(clk)  );
sub1 uut3 ( .ar(x0r), .ai(x0i), .br(x2r), .bi(x2i), .yr(w3r), .yi(w3i), .clk(clk)  );
sub1 uut4 ( .ar(x1r), .ai(x1i), .br(x3r), .bi(x3i), .yr(w4r), .yi(w4i), .clk(clk)  );  
mj uut5  ( .ar(w4r), .ai(w4i), .yr(w4r2), .yi(w4i2), .clk(clk)  );
add2 uut6 ( .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y0r), .yi(y0i), .clk(clk)  );
sub2 uut7 ( .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y2r), .yi(y2i), .clk(clk)  );
add2 uut8 ( .ar(w3r), .ai(w3i), .br(w4r2), .bi(w4i2), .yr(y1r), .yi(y1i), .clk(clk) );
sub2 uut9 ( .ar(w3r), .ai(w3i), .br(w4r2), .bi(w4i2), .yr(y3r), .yi(y3i), .clk(clk) );

endmodule

module add1(
    input signed [15:0] ar,ai,br,bi,
    input clk,
    output reg signed [16:0] yr, yi
);
    always @ (posedge clk)
    begin
        yr <= ar + br ;
        yi <= ai + bi ;
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
    input clk,
    input signed [15:0] ar,ai,br,bi,
    output reg signed  [16:0] yr, yi
);
    always@(posedge clk) 
    begin
        yr <= ar - br ;
        yi <= ai - bi ;
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

module pj(
    input clk,
    input signed [1:0] ar,ai,
    output reg signed [16:0] yr,yi
);
always@(posedge clk)
begin
    yr <= -ai;
    yi <= ar;
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

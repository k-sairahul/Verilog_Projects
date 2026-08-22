`timescale 1ns/1ps
  module fft4tap(
      input clk, rst,
      input signed [15:0] x0r,x0i,x1r,x1i,x2r,x2i,x3r,x3i,
      output signed [17:0] y0r,y0i,y1r,y1i,y2r,y2i,y3r,y3i
  );

  //Butterfly Coefficients, just for reference, didnt used anywhere directly
  localparam W40r = 1,
              W40i = 0,
              W41r = 0,
              W41i = -1;

  wire signed [16:0] w1r,w1i,w2r,w2i,w3r,w3i,w4r,w4i; // Stage 1 to Stage 2 connections
  wire signed [16:0] w3r1,w3i1,w4r2,w4i2;
  wire signed [17:0] y0r1,y0i1,y2r1,y2i1 ;

  add1 uut1 ( .ar(x0r), .ai(x0i), .br(x2r), .bi(x2i), .yr(w1r), .yi(w1i), .clk(clk)  );
  add1 uut2 ( .ar(x1r), .ai(x1i), .br(x3r), .bi(x3i), .yr(w2r), .yi(w2i), .clk(clk)  );
  sub1 uut3 ( .ar(x0r), .ai(x0i), .br(x2r), .bi(x2i), .yr(w3r), .yi(w3i), .clk(clk)  );
  sub1 uut4 ( .ar(x1r), .ai(x1i), .br(x3r), .bi(x3i), .yr(w4r), .yi(w4i), .clk(clk)  );  
  mj uut5  ( .ar(w4r), .ai(w4i), .yr(w4r2), .yi(w4i2), .clk(clk)  );
  add2 uut6 ( .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y0r1), .yi(y0i1), .clk(clk)  );
  sub2 uut7 ( .ar(w1r), .ai(w1i), .br(w2r), .bi(w2i), .yr(y2r1), .yi(y2i1), .clk(clk)  );
  add2 uut8 ( .ar(w3r1), .ai(w3i1), .br(w4r2), .bi(w4i2), .yr(y1r), .yi(y1i), .clk(clk) );
  sub2 uut9 ( .ar(w3r1), .ai(w3i1), .br(w4r2), .bi(w4i2), .yr(y3r), .yi(y3i), .clk(clk) );

  dff uut10 (.d(w3r), .q(w3r1), .clk(clk) );
  dff uut11 (.d(w3i), .q(w3i1), .clk(clk) );
  dff uut12 (.d(y0r1), .q(y0r), .clk(clk) );
  dff uut13 (.d(y0i1), .q(y0i), .clk(clk) );
  dff uut14 (.d(y2r1), .q(y2r), .clk(clk) );
  dff uut15 (.d(y2i1), .q(y2i), .clk(clk) );
      
  endmodule

  module dff(
    input clk,
    input [17:0] d,
    output reg [17:0] q
  );
    always @ (posedge clk)
      begin q <= d; end
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

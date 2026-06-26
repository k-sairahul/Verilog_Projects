`timescale 1ns/1ps
module dotproduct(
        input [7:0]a0,a1,a2,a3,a4,a5,a6,a7,
        input [7:0]b0,b1,b2,b3,b4,b5,b6,b7,
        input clk,
        output reg [26:0]y
);

reg [15:0]r0,r1,r2,r3,r4,r5,r6,r7;
reg [20:0]r8,r9,r10,r11,r12,r13;
integer i;
always @(posedge clk)
begin
        //stage 1
        r0 <= a0*b0;
        r1 <= a1*b1;
        r2 <= a2*b2;
        r3 <= a3*b3;
        r4 <= a4*b4;
        r5 <= a5*b5;
        r6 <= a6*b6;
        r7 <= a7*b7;

        //stage 2
        r8 <= r0 +r1;
        r9 <= r2+r3 ;
        r10 <= r4+r5;
        r11 <= r6+r7;

        //stage 3
        r12 <= r8 + r9 ;
        r13 <= r10 + r11 ;

        //output stage
        y <= r12 + r13 ;

end

endmodule

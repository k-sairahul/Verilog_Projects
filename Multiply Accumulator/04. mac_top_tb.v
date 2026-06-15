`timescale 1ns/1ps
module mac_top_tb;

    reg clk, rst, valid, start;
    reg [31:0] A, B, C;
    wire [31:0] Y;
    wire mode;
    wire [7:0] cycle_count;

    mac_top uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .Y(Y),
        .mode(mode),
        .cycle_count(cycle_count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mac_top_tb);

        clk = 0;
        rst = 1;
        valid = 0;
        start = 0;

        #20 rst = 0;

        // LOW FREQUENCY (ITERATIVE)
        repeat (3) begin
            @(posedge clk);
            A = $urandom_range(1,9);
            B = $urandom_range(1,9);
            C = $urandom_range(1,9);

            start = 1;
            @(posedge clk);
            start = 0;

            #400;
        end

        // HIGH FREQUENCY (BASIC)
        repeat (12) begin
            @(posedge clk);
            valid = 1;

            A = $urandom_range(1,9);
            B = $urandom_range(1,9);
            C = $urandom_range(1,9);
        end

        // BACK TO LOW
        valid = 0;

        repeat (10) @(posedge clk);
        #50;
        $finish;
    end

endmodule

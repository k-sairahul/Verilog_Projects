`timescale 1ns/1ps
module mac_top (
    input clk,
    input rst,
    input valid,
    input start,
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    output reg [31:0] Y,
    output reg mode,
    output reg [7:0] cycle_count
);

    wire [31:0] Y_iter, Y_basic;
    wire done_iter;

    reg en_basic;
    reg start_iter;

    reg [3:0] activity_counter;
    reg requested_mode;

    reg prev_done, prev_mode;

    reg [31:0] A_reg, B_reg, C_reg;
    reg [31:0] A_d, B_d, C_d;

    reg [1:0] basic_delay;
    reg [31:0] Y_prev;

    parameter TH_HIGH = 4;
    parameter TH_LOW  = 1;

    // Activity counter
    always @(posedge clk) begin
        if (rst)
            activity_counter <= 0;
        else if (valid)
            activity_counter <= activity_counter + 1;
        else
            activity_counter <= 0;
    end

    // Mode decision
    always @(posedge clk) begin
        if (rst)
            requested_mode <= 0;
        else if (activity_counter > TH_HIGH)
            requested_mode <= 1;
        else if (activity_counter < TH_LOW)
            requested_mode <= 0;
    end

    // Mode switching
    always @(posedge clk) begin
        if (rst) begin
            mode <= 0;
            prev_mode <= 0;
            basic_delay <= 0;
        end else begin
            prev_mode <= mode;
            mode <= requested_mode;

            if (mode == 0 && requested_mode == 1)
                basic_delay <= 2;
            else if (basic_delay > 0)
                basic_delay <= basic_delay - 1;
        end
    end

    // Capture iterative inputs
    always @(posedge clk) begin
        if (start) begin
            A_reg <= A;
            B_reg <= B;
            C_reg <= C;
        end
    end

    // Delay inputs
    always @(posedge clk) begin
        A_d <= A;
        B_d <= B;
        C_d <= C;
    end

    // Control
    always @(*) begin
        if (mode == 0) begin
            start_iter = start;
            en_basic   = 0;
        end else begin
            start_iter = 0;
            en_basic   = valid;
        end
    end

    // Cycle counter
    always @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else if ((mode == 0 && start_iter) || (mode == 1 && valid))
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // Modules Instantiation
    mac_iterative u_iter (
        .clk(clk),
        .rst(rst),
        .start(start_iter),
        .A(A),
        .B(B),
        .C(C),
        .done(done_iter),
        .Y(Y_iter)
    );

    mac_basic u_basic (
        .clk(clk),
        .rst(rst),
        .en(en_basic),
        .A(A),
        .B(B),
        .C(C),
        .Y(Y_basic)
    );

    // Output + print
    always @(posedge clk) begin

        if (mode == 0) begin
            if (done_iter && !prev_done) begin
                Y <= Y_iter;
                $display("MODE=ITERATIVE | A=%0d B=%0d C=%0d | Y=%0d | CYCLES=%0d", A_reg, B_reg, C_reg, Y_iter, cycle_count);
            end
        end

        else begin
            if (valid) begin
                Y <= Y_basic;

                if (basic_delay == 0 && Y_basic != Y_prev) begin
                    $display("MODE=BASIC | A=%0d B=%0d C=%0d | Y=%0d",  A_d, B_d, C_d, Y_basic);
                end
            end
        end

        prev_done <= done_iter;
        Y_prev <= Y_basic;
    end

    // Mode switch print
    always @(posedge clk) begin
        if (!rst && (mode != prev_mode)) begin
            $display("******** MODE SWITCH → %s ********", mode ? "BASIC" : "ITERATIVE");
        end
    end

endmodule

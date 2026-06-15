`timescale 1ns / 1ps

module tb_uart_top();

    // 1. Declare variables to hook up to the module
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] data_in;
    reg rx;

    wire tx;
    wire tx_done;
    wire [7:0] data_out;
    wire rx_done;

    // 2. Instantiate the "Box" (uart_top)
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_done(tx_done),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done)
    );

    // 3. THE LOOPBACK HACK: Connect TX directly to RX
    always @(*) begin
        rx = tx;
    end

    // 4. Generate a 100MHz Clock (10ns period -> flip every 5ns)
    always #5 clk = ~clk;

    // 5. Run the Test
    initial begin
        // --- Initialization ---
        clk = 0;
        rst = 1;         // Hold system in reset
        tx_start = 0;
        data_in = 0;

        #100;            // Wait 100ns
        rst = 0;         // Release reset
        #100;            // Wait a bit for the system to stabilize

        // ===============================================
        // TEST CASE 1: Send the character 'A' (Hex: 8'h41)
        // ===============================================
        $display("Starting Test Case 1...");
        data_in = 8'h41; 
        tx_start = 1;    // Pulse the start button
        #10;             // Wait exactly 1 clock cycle (10ns)
        tx_start = 0;    // Release the start button

        // The UART is very slow compared to the 100MHz clock. 
        // Instead of guessing how long to wait, we tell the testbench to pause 
        // until the Receiver flags that it is done.
        wait(rx_done == 1'b1);
        
        // Check the result
        if (data_out == 8'h41)
            $display("SUCCESS: Sent 'A', Received 'A'");
        else
            $display("ERROR: Data mismatch. Received: %h", data_out);

        #5000; // Wait a bit before sending the next byte

        // ===============================================
        // TEST CASE 2: Send the character 'Z' (Hex: 8'h5A)
        // ===============================================
        $display("Starting Test Case 2...");
        data_in = 8'h5A; 
        tx_start = 1;
        #10;
        tx_start = 0;

        wait(rx_done == 1'b1);
        
        if (data_out == 8'h5A)
            $display("SUCCESS: Sent 'Z', Received 'Z'");
        else
            $display("ERROR: Data mismatch. Received: %h", data_out);

        // --- End Simulation ---
        #1000;
        $display("Simulation Complete.");
        $finish; // Stop the testbench
    end
      
endmodule
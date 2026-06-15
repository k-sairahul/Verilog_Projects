module fifo #(parameter WIDTH=8, DEPTH=4) (
    input clk, rst, wr_en, rd_en,
    input [WIDTH-1:0] data_in, // Width -> No.of bits per data word
    output reg [WIDTH-1:0] data_out, 
    output full, empty
);
    // 1<<4 = 5'b10000 => 16
    reg [WIDTH-1:0] mem [0:(1<<DEPTH)-1]; //Depth -> Exponential 2^4 = 16 slots storage space
    reg [DEPTH:0] wptr, rptr;

    always @(posedge clk) begin
        if (rst) wptr <= 0;
        else if (wr_en && !full) begin
            mem[wptr[DEPTH-1:0]] <= data_in;
            wptr <= wptr + 1;
        end
    end

    always @(posedge clk) begin
        if (rst)
        begin
            rptr <= 0;
        end
        else if (rd_en && !empty) begin
            data_out <= mem[rptr[DEPTH-1:0]];
            rptr <= rptr + 1;
        end
    end
    
    assign empty = (wptr == rptr);
    assign full = (wptr == {~rptr[DEPTH], rptr[DEPTH-1:0]});
endmodule
//ChatGPT Generated one
`timescale 1ns/1ps
module tb_fft4tap;

  reg clk, rst;
  reg [7:0] s_axis_config_tdata;
  reg s_axis_config_tvalid;
  wire s_axis_config_tready;
  reg signed [31:0] s_axis_data_tdata;
  reg s_axis_data_tvalid;
  wire s_axis_data_tready;
  reg s_axis_data_tlast;
  wire signed [35:0] m_axis_data_tdata;
  wire m_axis_data_tlast;
  wire m_axis_data_tvalid;
  reg m_axis_data_tready;

fft4tap dut(
    .clk(clk),  .rst(rst),
    .s_axis_config_tdata(s_axis_config_tdata),
    .s_axis_config_tvalid(s_axis_config_tvalid),
    .s_axis_config_tready(s_axis_config_tready),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tlast(s_axis_data_tlast),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready)
);

initial begin $dumpfile("new_wave.vcd");  $dumpvars(0); end
initial begin clk = 0; forever #5 clk = ~clk; end

//Stimulus
initial begin
    rst = 1;
    s_axis_config_tdata  = 0;
    s_axis_config_tvalid = 0;
    s_axis_data_tdata  = 0;
    s_axis_data_tvalid = 0;
    s_axis_data_tlast  = 0;
    m_axis_data_tready = 1;

    #20; rst = 0;

    //Configuration
    @(posedge clk);
    s_axis_config_tdata  <= 8'h01;
    s_axis_config_tvalid <= 1;

    @(posedge clk);
    s_axis_config_tvalid <= 0;

    // Wait until DUT is ready
    wait(s_axis_data_tready);

    //Send Data
    @(posedge clk);
    s_axis_data_tvalid <= 1;
    s_axis_data_tdata  <= 32'd10;
    s_axis_data_tlast  <= 0;

    @(posedge clk);
    s_axis_data_tdata <= 32'd19;

    @(posedge clk);
    s_axis_data_tdata <= 32'd412;

    @(posedge clk);
    s_axis_data_tdata <= 32'd901;
    s_axis_data_tlast <= 1;

    @(posedge clk);
    s_axis_data_tvalid <= 0;
    s_axis_data_tlast  <= 0;
    s_axis_data_tdata  <= 0;

    repeat(15)
        @(posedge clk);
    $finish;
end
endmodule

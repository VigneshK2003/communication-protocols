// SPI topmodule
`include "clock_divider.v"
`include "master.v"
`include "slave.v"


module SPI_top(
    input clk,
    input rst,
    input start_en, sclk_en, done,
  input [7:0]m_tx_data,
  input [7:0]s_tx_data,
  output [7:0]m_rx_data,
  output [7:0]s_rx_data
);
  
    wire mosi_w, miso_w;
    wire ss_w, tick_w, sclk_gen;
  
  clock_divider #(.SYS_CLK(50_000_000), .SPI_CLK(10_000_000)) c_dut (.clk(clk), .rst(rst), .tick(tick_w), .sclk_gen(sclk_gen) );
  
  SPI_master m_dut( .clk(clk), .rst(rst), .tick(tick_w), .MOSI(mosi_w), .MISO(miso_w), .SS(ss_w), .SCLK(sclk_w), .m_tx_data(m_tx_data), .start_en(start_en), .m_rx_data(m_rx_data) );
 
  SPI_slave s_dut(.clk(clk), .rst(rst), .MOSI(mosi_w), .MISO(miso_w), .SS(ss_w), .SCLK(sclk_w), .s_tx_data(s_tx_data), .s_rx_data(s_rx_data), .done(done) );
  
endmodule

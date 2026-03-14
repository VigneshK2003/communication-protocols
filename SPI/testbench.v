// SPI - Testbench

module SPI_test;
  reg clk;
  reg rst;
  reg start_en;
  reg sclk_gen;
  reg sclk_en;

  reg [7:0]m_tx_data;
  reg [7:0]s_tx_data;

  wire [7:0]m_rx_data;
  wire [7:0]s_rx_data;
  wire done;

  //   SPI_top uut(.clk(clk), .rst(rst), .m_tx_data(m_tx_data), .m_rx_data(m_rx_data), .s_tx_data(s_tx_data), .s_rx_data(s_rx_data) );

  SPI_top uut(
    .clk(clk),
    .rst(rst),
    .start_en(start_en),
    .sclk_en(sclk_en),
    .m_tx_data(m_tx_data),
    .m_rx_data(m_rx_data),
    .s_tx_data(s_tx_data),
    .s_rx_data(s_rx_data),
    .done(done)
  );


  always #5 clk = ~clk;


  initial begin

    $monitor("time = %0t | rst = %b | clk = %b | start_en = %0b | SS = %b SCLK = %0b | m_tx_data = %b | s_tx_data = %b | m_rx_data = %b | s_rx_data = %b |Master_state = %0d | slave_state = %0d", $time,rst,clk,start_en,uut.ss_w,uut.tick_w,m_tx_data,s_tx_data,m_rx_data,s_rx_data,uut.m_dut.state,uut.s_dut.state); 

    $dumpfile ("dump.vcd");
    $dumpvars;


    clk = 0; 

    rst = 1;
    sclk_gen = 0;
    start_en = 0;
    m_tx_data = 0;
    s_tx_data = 0;
    
    #10;
    start_en = 1;
    
fork
    run_task(1, 130, 56);
    run_task(1, 10, 8);
join
//     #100;
//     $finish;
  end

  task run_task( 
    input sclk_gen,
    input [7:0] m_tx_data, s_tx_data
  );

    @(negedge clk);
    sclk_en = sclk_gen;
    m_tx_data = m_tx_data;
    s_tx_data = s_tx_data;
    #20;

    //     $display("\t\t----------- NEXT DATA -----------------");
    //     $display("  [%0t] - master datain = %0d(%b) | slave datain = %0d(%b)", $time, master_tx_datain, master_tx_datain, slave_tx_datain, slave_tx_datain);

    $display(" --- spi enable done ---");

    start_en = 1;
    @(posedge clk);

    start_en = 0;
    @(posedge done);

    #10;
    $display("  [%0t] --- spi transmission and receive done ---", $time);
    if ((m_tx_data == s_rx_data) && (s_tx_data == m_rx_data)) begin
      $display("\t------------------------------------------------------------");
      $display("\t\t\t SUCCESS: Received master dataout = %0d | slave dataout = %0d correctly", m_rx_data, s_rx_data);
      $display("\t--------------------------------------------------------------\n");
    end
    else begin
      $display("\t------------------------------------------------------------");
      $display("\t\t\t ERROR: Data mismatch send and receive failed");
      $display("\t--------------------------------------------------------------\n");
    end

    #100;
  endtask

endmodule

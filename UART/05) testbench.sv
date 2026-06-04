module uart_tb;
    reg        tx_clk, rx_clk, rst_n;
    reg        tx_start;
    reg [7:0]  data_in;

    wire       tx;        
    wire       tx_busy;
    wire       rx_done;
    wire [7:0] data_out;


    // Instantiate top module
    uart_topmodule uut (
        .tx_clk(tx_clk),
        .rx_clk(rx_clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .data_in(data_in),
        .rx(tx),
        .tx(tx),
        .data_out(data_out),
        .tx_busy(tx_busy),
        .rx_done(rx_done)
    );

    // Clock generation
    always #5 tx_clk = ~tx_clk;  
    always #5  rx_clk = ~rx_clk;  

    // Stimulus
    initial begin
      $monitor("Time=%0t | rst=%b | tx_start=%b | tx_busy=%b | data_in=%b | data_out=%b | rx_done=%b | tx_state=%b | rx_state=%b",
                 $time, rst_n, tx_start, tx_busy, data_in, data_out, rx_done,
                 uut.dut1.state, uut.dut2.state);

        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);

        tx_clk   = 0;
        rx_clk   = 0;
        rst_n    = 0;
        tx_start = 0;
        data_in  = 0;

        #20 rst_n = 1;

        send_data(8'd10);
        send_data(8'd85);
        send_data(8'd50);

        #100000 $finish;
    end

    // Task to send data
    task send_data(input [7:0] data);
        begin
            wait(!tx_busy);
            @(posedge tx_clk);
            data_in  = data;
            tx_start = 1;
            @(posedge tx_clk);
            tx_start = 0;

            wait(rx_done);
          $display("Received %0b at time %0t", data_out, $time);
        end
    endtask

endmodule

module uart_topmodule(
    input        tx_clk,
    input        rx_clk,
    input        rst_n,
    input        tx_start,
    input  [7:0] data_in,
    input        rx,         

    output       tx,          
    output       tx_busy,
    output       rx_done,
    output [7:0] data_out
);

    wire tx_tick_w, rx_tick_w;

    // Baud generator
    baud_generator dut (
        .tx_clk(tx_clk),
        .rx_clk(rx_clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick_w),
        .rx_tick(rx_tick_w)
    );

    // UART Transmitter
    uart_transmitter dut1 (
        .tx_clk(tx_clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick_w),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx_busy(tx_busy),
        .tx(tx)
    );

    // UART Receiver
    uart_receiver dut2 (
        .rx_clk(rx_clk),
        .rst_n(rst_n),
        .rx(tx),
        .rx_tick(rx_tick_w),
        .data_out(data_out),
        .rx_done(rx_done)
    );

endmodule

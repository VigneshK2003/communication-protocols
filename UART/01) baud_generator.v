module baud_generator#(
    parameter tx_clk_freq = 10_000_000,
    parameter rx_clk_freq = 10_000_000,
    parameter BAUD_RATE = 9600
)(
    input tx_clk, rx_clk,
    input  wire rst_n,
    output reg  tx_tick, rx_tick  
);

  localparam tx_div = ( tx_clk_freq / BAUD_RATE );
  localparam rx_div = ( rx_clk_freq / (BAUD_RATE*16) );
  
    localparam W = $clog2(tx_div);
    localparam N = $clog2(rx_div);

    reg [W-1:0] tx_count;
    reg [N-1:0] rx_count;
    
    // tx tick generator
  
  always @(posedge tx_clk or negedge rst_n) begin
    if (!rst_n) begin
                tx_count <= 0;
                tx_tick <= 0;
         end 
      else if (tx_count == tx_div-1) begin
                tx_count <= 0;
                tx_tick <= 1;
         end 
        else begin
                tx_count <= tx_count + 1;
                tx_tick <= 0;
        end
    end
  
   // rx tick generator
  
   always @(posedge rx_clk or negedge rst_n) begin
     if (!rst_n) begin
                 rx_count <= 0;
                 rx_tick <= 0;
          end 
       else if (rx_count == rx_div-1) begin
                 rx_count <= 0;
                 rx_tick <= 1;
          end 
         else begin
                 rx_count <= rx_count + 1;
                 rx_tick <= 0;
         end
    end
endmodule

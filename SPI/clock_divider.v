// clock divider

module clock_divider #( parameter SYS_CLK = 50_000_000,parameter SPI_CLK = 10_000_000)(
         input rst, clk, sclk_gen,
//          output reg SCLK,
         output reg tick
);
  
  localparam DIVIDER = ( SYS_CLK / (2*SPI_CLK));
  
  localparam clk_width = $clog2(DIVIDER);
  
  reg [clk_width-1:0] clk_counter;
  
  always@(posedge clk or posedge rst)begin
    if(rst)begin
                tick <= 0;
           clk_counter <= 0;
    end
    else if(sclk_gen)begin
      if(clk_counter == DIVIDER - 1)begin
           tick <= 1;
            clk_counter <= 0;
      end
      else begin
          clk_counter <= clk_counter + 1;
           tick <= 0;
      end
    end
  end
endmodule

// SPI slave

module SPI_slave(
           input rst, clk,
           input SCLK,SS,
           input MOSI,
  
          input [7:0]s_tx_data,
          output reg MISO,
  output reg [7:0]s_rx_data,
          output reg done
);
  
  reg [7:0]shift_reg;
  reg [1:0]state,next_state;
  reg bit_count;
  
  parameter [1:0] IDLE = 2'b00,
                  DATA = 2'b01,
                  STOP = 2'b10;
  
  reg SCLK_d;   

always @(posedge clk or posedge rst) begin
    if (rst)
        SCLK_d <= 0;
    else
        SCLK_d <= SCLK;  
end

  wire rising_edge  = ~SCLK_d && SCLK;   
  wire falling_edge =  SCLK_d && ~SCLK;  

   
//   always@(posedge clk) begin
//      if(rst)
//         state <= IDLE;
//      else 
//         state <= next_state;
//   end
  
  always@(posedge clk)begin
    if(rst) begin
       state <= IDLE;
//         SCLK <= 0;
//           SS <= 1;
//          clk <= 0;
//          rst <= 0;
      shift_reg <= 0;
         MISO <= 0;
      bit_count <= 0;
    end
     else begin
       case(state)
         
          IDLE: begin
//               SS <= 1;
            if(SS)
               state <= DATA;
//              else 
//                next_state <= IDLE;
          end
         
         
          DATA: begin
//              SS = 0;
            
            if(rising_edge)begin
              shift_reg <= {shift_reg[6:0],MOSI};
              if(bit_count == 0)
               bit_count <= bit_count + 1;
           end
            
            else if(falling_edge)begin
              MISO <= s_tx_data[7];
          //   m_rx_data <= shift_reg;
               state <= STOP;
           end
         end
         
         STOP: begin
           if(SS) begin
                state <= IDLE;
              done <= 1;
           end
           else begin
              state <= STOP;
           end
         end
       endcase
    end
  end
endmodule

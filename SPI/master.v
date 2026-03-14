// SPI master

module SPI_master(
  input clk,
  input rst,
  input tick,
  input MISO,
  input start_en,
  input [7:0]m_tx_data,

  output reg[7:0]m_rx_data,
  output reg SS,
  output SCLK,
  output reg MOSI

);

  reg [1:0]state,next_state;
  reg [7:0]shift_reg;
  reg [3:0]bit_count;

  parameter [1:0] IDLE  = 2'b00,
  START = 2'b01,
  DATA  = 2'b10,
  STOP  = 2'b11;

  reg sclk_en;
  assign SCLK = (sclk_en)? tick : 1'b0;

  reg prev_spi_clk;

  always@(posedge clk)begin
    prev_spi_clk <= tick;
  end

  wire rising_edge = ~prev_spi_clk && tick;
  wire falling_edge = prev_spi_clk && ~tick;

  //   always@(posedge clk or posedge rst)begin
  //     if(rst)
  //        state <= IDLE;
  //     else
  //        state <= next_state;
  //    end


  always@(posedge clk or posedge rst) begin
    if(rst)begin
      state <= IDLE;
      SS  <= 1;
      sclk_en <= 0;
      MOSI <= 0;
//       m_tx_data <= 0;
      shift_reg <= 0;
    end
    else begin

      case(state)

        IDLE: begin
          SS  <= 1;
          sclk_en <= 0;
          MOSI <= 0;
//           m_tx_data <= 0;
          shift_reg <= 0;
          if(start_en && SS)begin
            state <= START;
          end
        end   


        START: begin
          SS <= 0;
          sclk_en <= 1;

          shift_reg <= {shift_reg[6:0], 1'b0};
          //   bit_count <= bit_count-1;
          //  MOSI <= shift_reg[7];	

          state <= DATA;
        end


        DATA: begin

          if(rising_edge)begin
            shift_reg <= {shift_reg[6:0],MISO};
            if(bit_count == 0)
              bit_count <= bit_count + 1;
            state <= STOP;
          end

          else if(falling_edge)begin
            MOSI <= shift_reg[7];
            //   m_rx_data <= shift_reg;
            //               next_state <= STOP;
          end
        end


        STOP: begin
          SS <= 1;
          sclk_en <= 0;

          m_rx_data <= shift_reg;
          state <= IDLE;
          MOSI <= 0;
        end

        default: state <= IDLE;

      endcase
    end
  end
endmodule

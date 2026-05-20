module uart_transmitter(
            input        tx_clk, 
            input        rst_n,
            input        tx_tick,
            input        tx_start,
            input  [7:0] data_in,
            
            output  reg  tx_busy,
            output  reg  tx
 );
  
     reg [7:0]shift_reg;
     reg [3:0]bit_count;
     reg [1:0]state, next_state;
  
  parameter [1:0]  IDLE = 2'b00,
                  START = 2'b01,
                   DATA = 2'b10,
                   STOP = 2'b11;
  
  // state register
  always@(posedge tx_clk or negedge rst_n)begin
    if(!rst_n)
          state <= IDLE;
      else
          state <= next_state;
  end
  
  
  // next state logic
  always@(*)begin
    case(state)
        IDLE:  next_state = tx_start ? START : IDLE;
        START:  next_state = tx_tick ? DATA : START;
        DATA:  next_state = (tx_tick && bit_count == 7)? STOP : DATA;
        STOP:  next_state = tx_tick? IDLE : STOP;
      default: next_state = IDLE;
    endcase
  end
  
  
  // output logic
  always@(posedge tx_clk or negedge rst_n)begin
    if(!rst_n)begin
         tx        <= 1;
         tx_busy   <= 0;
         shift_reg <= 0;
         bit_count <= 0;
    end
    
    else begin
      case(state)
          
         IDLE: begin
                 tx        <= 1'b1;
                 tx_busy   <= 1'b0;
                 bit_count <= 4'd0;

                    if (tx_start) begin
                        shift_reg <= data_in;
                        tx_busy   <= 1'b1;
                    end
                end        

        
//         START: begin
//           if(tx_tick)
//                state <= DATA;
//              tx_busy <= 1;
//           else
//               state <= START;
//         end
        
        START: begin
                  tx <= 1'b0;
                  if(tx_tick)
                      bit_count <= 0;
                end
        
//         DATA: begin
//                    tx <= 0;
//               tx_busy <= 1;
//           if(tx_tick) begin
//             tx <= shift_reg[bit_count];
//                bit_count++;
//             if( bit_count == 7)
//               state <= STOP;
//           end
//           else
//                state <= DATA;
//            bit_count <= 0;
//          end
        
        DATA: begin
           if (tx_tick) begin
                tx <= shift_reg[0];
                shift_reg <= shift_reg >> 1;

           if(bit_count == 4'd7)
                bit_count <= 0;
           else
                bit_count <= bit_count + 1'b1;
           end
        end

        STOP: begin
               tx <= 1;
           if(tx_tick)begin
              state   <= IDLE;
              tx_busy <= 0;
           end
           else
             state <= STOP;
        end
      endcase
    end
  end
endmodule

module uart_receiver(
    input        rx_clk,
    input        rst_n,
    input        rx,        // single-bit serial input line
    input        rx_tick,   // baud tick for sampling

    output reg [7:0] data_out,
    output reg       rx_done
);

    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [1:0] state, next_state;
    reg [3:0] tick_count;

    parameter [1:0] IDLE  = 2'b00,
                    START = 2'b01,
                    DATA  = 2'b10,
                    STOP  = 2'b11;

    // State register
    always @(posedge rx_clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE:  next_state = (!rx) ? START : IDLE; 
            START: next_state = (rx_tick)? DATA : START;
//             DATA:  next_state = (rx_tick && bit_count == 7)? STOP : DATA;
            DATA: next_state = (bit_count == 8)? STOP : DATA;
            STOP:  next_state = (rx_tick)? IDLE : STOP;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge rx_clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 0;
            bit_count <= 0;
            data_out  <= 0;
            rx_done   <= 0;
           tick_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done   <= 0;
                    bit_count <= 0;
                   tick_count <= 0;
                end

//                 START: begin
//                     if (rx_tick)
//                         bit_count <= 0;
//                 end
              START: begin
                  if(rx_tick) begin
                      tick_count <= tick_count + 1;
              
                      if(tick_count == 7) begin
                          tick_count <= 0;
                          bit_count <= 0;
                          next_state <= DATA;
                      end
                  end
              end
              
              
              DATA: begin
                 if(rx_tick) begin
                        tick_count <= tick_count + 1;

                 // sample in middle of bit
                   if(tick_count == 7) begin
                       shift_reg[bit_count] <= rx;

                 // last bit received
                 if(bit_count == 7) begin
                     data_out <= {rx, shift_reg[7:1]};
                 end
                     bit_count <= bit_count + 1;
                   end
           
                   // next bit period
                   if(tick_count == 15)
                       tick_count <= 0;
                   else
                      tick_count = tick_count + 1;
                  end
                end
              

                STOP: begin
                    if(rx_tick) begin
                        rx_done <= 1;
                    end
                end
            endcase
        end
    end

endmodule

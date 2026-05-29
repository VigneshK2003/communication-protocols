module uart_transmitter(
    input        tx_clk,
    input        rst_n,
    input        tx_tick,
    input        tx_start,
    input  [7:0] data_in,

    output reg   tx,
    output reg   tx_busy
);

    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [1:0] state, next_state;

    parameter [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    
   // State Register
     always @(posedge tx_clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    // Next State Logic
    always @(*) begin
        case(state)

            IDLE:
                next_state = (tx_start) ? START : IDLE;

            START:
                next_state = (tx_tick) ? DATA : START;

            DATA:
                next_state = (tx_tick && bit_count == 4'd8) ? STOP : DATA;

            STOP:
                next_state = (tx_tick) ? IDLE : STOP;

            default:
                next_state = IDLE;

        endcase
    end

   
    // Output & Datapath Logic
    always @(posedge tx_clk or negedge rst_n) begin
        if (!rst_n) begin
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            shift_reg <= 8'd0;
            bit_count <= 4'd0;
        end

        else begin

            case(state)
              
                IDLE: begin
                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    bit_count <= 4'd0;

                    if(tx_start) begin
                        shift_reg <= data_in;
                        tx_busy   <= 1'b1;
                    end
                end

               
                START: begin
                    tx      <= 1'b0;
                    tx_busy <= 1'b1;

                    if(tx_tick)
                        bit_count <= 4'd0;
                end

              
                DATA: begin
                    tx_busy <= 1'b1;
                    if(tx_tick) begin

                        tx <= shift_reg[0];

                        shift_reg <= shift_reg >> 1;

                        bit_count <= bit_count + 1'b1;
                    end
                end

                STOP: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b1;
                end

            endcase
        end
    end
endmodule

module APB_master(
         input PCLK,
         input PRSTn,
         input transfer,
         input read_write,
         input PREADY,
  
         input [8:0]apb_write_paddr,
         input [8:0]apb_read_paddr,
         input [7:0]apb_write_data,
         input [7:0]PRDATA,
  
         output reg [7:0]apb_read_data_out,
         output reg [8:0]PADDR,
         output reg [7:0]PWDATA,
         output reg PSEL1, PSEL2, PWRITE, PENABLE
);

    reg [1:0]state,next_state;

  parameter IDLE   = 2'b00,
            SETUP  = 2'b01,
            ACCESS = 2'b10;

  always @(posedge PCLK or negedge PRSTn) begin
    if (!PRSTn) begin
        state <= IDLE;
        PSEL1 <= 0;
        PSEL2 <= 0;
        PENABLE <= 0;
        PWRITE <= 0;
        apb_read_data_out <= 0;
    end
    else begin
        case(state)

        IDLE: begin
            PSEL1 <= 0;
            PSEL2 <= 0;
            PENABLE <= 0;

            if (transfer) begin
                if (!read_write) begin
                    PADDR  <= apb_write_paddr;
                    PWDATA <= apb_write_data;
                    PWRITE <= 1;

                    if (apb_write_paddr[0] == 0)
                        PSEL1 <= 1;
                    else
                        PSEL2 <= 1;
                end
                else begin
                    PADDR  <= apb_read_paddr;
                    PWRITE <= 0;

                    if (apb_read_paddr[0] == 0)
                        PSEL1 <= 1;
                    else
                        PSEL2 <= 1;
                end

                state <= SETUP;
            end
        end

        SETUP: begin
            PENABLE <= 1;
            state <= ACCESS;
        end

        ACCESS: begin
            if (PREADY) begin
                if (read_write)
                    apb_read_data_out <= PRDATA;

                PSEL1 <= 0;
                PSEL2 <= 0;
                PENABLE <= 0;
                state <= IDLE;
            end
        end

        endcase
    end
  end

endmodule

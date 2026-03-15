module APB_slave1(
         input PCLK,
         input PRSTn,  
         input PSEL1,
         input PENABLE,
         input PWRITE,
         input [8:0]PADDR,     
         input [7:0]PWDATA,
  
         output reg [7:0]PRDATA,
         output reg PREADY
);

      reg [31:0] mem [0:255];

  always @(posedge PCLK or negedge PRSTn)begin
    if (!PRSTn) begin
      PRDATA  <= 32'b0;
      PREADY  <= 1'b0;
    end
    else if (PSEL1 && PENABLE) begin
      if (PWRITE) begin
        mem[PADDR] <= PWDATA;   
        PREADY     <= 1'b1;
      end
      else begin
        PRDATA  <= mem[PADDR]; 
        PREADY  <= 1'b1;
      end
    end
    else begin
      PREADY  <= 1'b0;
    end
  end

endmodule

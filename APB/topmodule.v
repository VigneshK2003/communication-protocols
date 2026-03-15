module APB_top(
    input  PCLK,
    input  PRSTn,
    input  transfer,
    input  read_write,
  input  [7:0] apb_write_paddr,
  input  [8:0] apb_read_paddr,
  input  [8:0] apb_write_data,
  output [7:0] apb_read_data_out
);

  wire [8:0] PADDR;
  wire [7:0] PWDATA;
  wire [7:0] PRDATA1, PRDATA2;
  wire [7:0] PRDATA;
  wire PSEL1, PSEL2;
  wire PWRITE;
  wire PENABLE;
  wire PREADY1, PREADY2;
  wire PREADY;

  // Master
  APB_master master (
    .PCLK(PCLK),
    .PRSTn(PRSTn),
    .transfer(transfer),
    .read_write(read_write),
    .PREADY(PREADY),
    .apb_write_paddr(apb_write_paddr),
    .apb_read_paddr(apb_read_paddr),
    .apb_write_data(apb_write_data),
    .PRDATA(PRDATA),
    .apb_read_data_out(apb_read_data_out),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL1(PSEL1),
    .PSEL2(PSEL2),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE)
  );

  // Slave 1
  APB_slave1 slave1 (
    .PCLK(PCLK),
    .PRSTn(PRSTn),
    .PSEL1(PSEL1),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA1),
    .PREADY(PREADY1)
  );

  // Slave 2
  APB_slave2 slave2 (
    .PCLK(PCLK),
    .PRSTn(PRSTn),
    .PSEL2(PSEL2),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA2),
    .PREADY(PREADY2)
  );

  assign PRDATA = (PSEL1)? PRDATA1 :
                  (PSEL2)? PRDATA2 :
                  1'b0;

  assign PREADY = (PSEL1)? PREADY1 :
                  (PSEL2)? PREADY2 :
                  1'b0;

endmodule

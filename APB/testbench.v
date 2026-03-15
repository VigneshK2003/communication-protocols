module APB_tb;

  reg PCLK;
  reg PRSTn;
  reg transfer;
  reg read_write; 
  reg [7:0] apb_write_paddr;
  reg [7:0] apb_read_paddr;
  reg [7:0] apb_write_data;

  wire [7:0] apb_read_data_out;

  APB_top dut (
    .PCLK(PCLK),
    .PRSTn(PRSTn),
    .transfer(transfer),
    .read_write(read_write),
    .apb_write_paddr(apb_write_paddr),
    .apb_read_paddr(apb_read_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_data_out(apb_read_data_out)
  );

  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; 
  end

  initial begin
    PRSTn = 0;
    transfer = 0;
    read_write = 0;
    apb_write_paddr = 0;
    apb_read_paddr = 0;
    apb_write_data = 0;

    #20;
    PRSTn = 1;

    @(posedge PCLK);
    transfer = 1;
    read_write = 0;                 
    apb_write_paddr = 9'd3; 
    apb_write_data  = 8'd5; 

    @(posedge PCLK); // SETUP
    @(posedge PCLK); // ACCESS
    transfer = 0;

    repeat(2) @(posedge PCLK);

    @(posedge PCLK);
    transfer = 1;
    read_write = 1;                 
    apb_read_paddr = 9'd3;

    @(posedge PCLK); // SETUP
    @(posedge PCLK); // ACCESS
    transfer = 0;

    repeat(2) @(posedge PCLK);

    $display("Read Data from Slave 1 = %0d", apb_read_data_out);

   
    @(posedge PCLK);
    transfer = 1;
    read_write = 0;                 
    apb_write_paddr = 9'd2; 
    apb_write_data  = 8'd15; 

    @(posedge PCLK); 
    @(posedge PCLK); 
    transfer = 0;

    repeat(2) @(posedge PCLK);
    
    @(posedge PCLK);
    transfer = 1;
    read_write = 1;                
    apb_read_paddr = 9'd2;

    @(posedge PCLK); 
    @(posedge PCLK); 
    transfer = 0;

    repeat(2) @(posedge PCLK);

    $display("Read Data from Slave 2 = %0d", apb_read_data_out);

    #50;
    $finish;
  end

endmodule

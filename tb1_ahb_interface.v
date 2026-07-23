// ============================================================
// TB1 : AHB Slave Interface Waveform
// Signals: Hclk, Hresetn, Hwrite, Hreadyin, Htrans, Haddr,
//          Hwdata, valid, Haddr1, Haddr2, Hwdata1, Hwdata2,
//          Hwritereg, tempselx, Hrdata, Hresp
// ============================================================
`timescale 1ns/1ps
module tb_ahb_interface;

  reg  Hclk, Hresetn;
  wire Hwrite, Hreadyin;
  wire [1:0]  Htrans;
  wire [31:0] Hwdata, Haddr;
  wire [1:0]  Hresp;
  wire [31:0] Hrdata;
  wire Hreadyout;
  wire Penable, Pwrite;
  wire [2:0]  Pselx;
  wire [31:0] Paddr, Pwdata, Prdata;

  // AHB Slave internal wires (tapped from Bridge_Top via submodule)
  wire valid;
  wire [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2;
  wire Hwritereg;
  wire [2:0] tempselx;

  initial Hclk = 0;
  always #5 Hclk = ~Hclk;
  initial begin Hresetn = 0; #20 Hresetn = 1; end

  AHB_Master u_master (
    .Hclk(Hclk), .Hresetn(Hresetn),
    .Hresp(Hresp), .Hrdata(Hrdata),
    .Hwrite(Hwrite), .Hreadyin(Hreadyin),
    .Hreadyout(Hreadyout), .Htrans(Htrans),
    .Hwdata(Hwdata), .Haddr(Haddr)
  );

  // Instantiate AHB Slave directly to observe internal signals
  AHB_slave_interface u_slave (
    .Hclk(Hclk), .Hresetn(Hresetn),
    .Hwrite(Hwrite), .Hreadyin(Hreadyin),
    .Htrans(Htrans), .Haddr(Haddr), .Hwdata(Hwdata),
    .Prdata(Prdata),
    .valid(valid), .Haddr1(Haddr1), .Haddr2(Haddr2),
    .Hwdata1(Hwdata1), .Hwdata2(Hwdata2),
    .Hrdata(Hrdata), .Hwritereg(Hwritereg),
    .tempselx(tempselx), .Hresp(Hresp)
  );

  APB_FSM_Controller u_fsm (
    .Hclk(Hclk), .Hresetn(Hresetn),
    .valid(valid), .Haddr1(Haddr1), .Haddr2(Haddr2),
    .Hwdata1(Hwdata1), .Hwdata2(Hwdata2), .Prdata(Prdata),
    .Hwrite(Hwrite), .Haddr(Haddr), .Hwdata(Hwdata),
    .Hwritereg(Hwritereg), .tempselx(tempselx),
    .Pwrite(Pwrite), .Penable(Penable), .Pselx(Pselx),
    .Paddr(Paddr), .Pwdata(Pwdata), .Hreadyout(Hreadyout)
  );

  APB_Interface u_apb_if (
    .Pwrite(Pwrite), .Pselx(Pselx), .Penable(Penable),
    .Paddr(Paddr), .Pwdata(Pwdata),
    .Pwriteout(), .Pselxout(), .Penableout(),
    .Paddrout(), .Pwdataout(), .Prdata(Prdata)
  );

  initial begin
    $dumpfile("tb1_ahb_interface.vcd");
    $dumpvars(0, u_slave);   // only AHB slave signals
    wait (Hresetn == 1);
    @(posedge Hclk);
    // Single write then read to show valid, tempselx, Haddr1/2, etc.
    u_master.single_write(32'h8000_0004, 32'hDEAD_BEEF);
    @(posedge Hclk); @(posedge Hclk);
    u_master.single_read(32'h8000_0004);
    @(posedge Hclk); @(posedge Hclk);
    // Slave 2 write to show tempselx change
    u_master.single_write(32'h8400_0008, 32'hCAFE_BABE);
    @(posedge Hclk); @(posedge Hclk);
    #30;
    $display("[TB1] AHB Slave Interface waveform done.");
    $finish;
  end
endmodule

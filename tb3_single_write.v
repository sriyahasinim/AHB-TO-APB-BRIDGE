// ============================================================
// TB3 : Single Write Waveform
// Shows exactly one AHB write transaction end-to-end:
//   Haddr, Hwdata, Hwrite, Htrans, valid, tempselx,
//   Pselx, Paddr, Pwdata, Pwrite, Penable, Hreadyout
// ============================================================
`timescale 1ns/1ps
module tb_single_write;

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

  Bridge_Top u_bridge (
    .Hclk(Hclk), .Hresetn(Hresetn),
    .Hwrite(Hwrite), .Hreadyin(Hreadyin),
    .Hreadyout(Hreadyout),
    .Hwdata(Hwdata), .Haddr(Haddr), .Htrans(Htrans),
    .Prdata(Prdata),
    .Penable(Penable), .Pwrite(Pwrite),
    .Pselx(Pselx), .Paddr(Paddr), .Pwdata(Pwdata),
    .Hresp(Hresp), .Hrdata(Hrdata)
  );

  APB_Interface u_apb_if (
    .Pwrite(Pwrite), .Pselx(Pselx), .Penable(Penable),
    .Paddr(Paddr), .Pwdata(Pwdata),
    .Pwriteout(), .Pselxout(), .Penableout(),
    .Paddrout(), .Pwdataout(), .Prdata(Prdata)
  );

  initial begin
    $dumpfile("tb3_single_write.vcd");
    $dumpvars(0, tb_single_write);  // all top-level wires
    wait (Hresetn == 1);
    @(posedge Hclk);

    $display("[TB3] --- Single Write to Slave 1 ---");
    u_master.single_write(32'h8000_0010, 32'hDEAD_BEEF);
    @(posedge Hclk); @(posedge Hclk); @(posedge Hclk);

    $display("[TB3] --- Single Write to Slave 2 ---");
    u_master.single_write(32'h8400_0020, 32'hCAFE_BABE);
    @(posedge Hclk); @(posedge Hclk); @(posedge Hclk);

    #20;
    $display("[TB3] Single Write waveform done.");
    $finish;
  end
endmodule

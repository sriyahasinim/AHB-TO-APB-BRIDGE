`timescale 1ns/1ps

module tb_top;

  reg  Hclk, Hresetn;

  wire Hwrite, Hreadyin;
  wire [1:0] Htrans;
  wire [31:0] Hwdata, Haddr;
  wire [1:0] Hresp;
  wire [31:0] Hrdata;
  wire Hreadyout;

  wire Penable, Pwrite;
  wire [2:0] Pselx;
  wire [31:0] Paddr, Pwdata;
  wire [31:0] Prdata;

  initial Hclk = 0;
  always #5 Hclk = ~Hclk;

  initial begin
    Hresetn = 0;
    #20 Hresetn = 1;
  end

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
    .Hwdata(Hwdata), .Haddr(Haddr),
    .Htrans(Htrans),
    .Prdata(Prdata),
    .Penable(Penable), .Pwrite(Pwrite),
    .Pselx(Pselx), .Paddr(Paddr), .Pwdata(Pwdata),
    .Hresp(Hresp), .Hrdata(Hrdata)
  );

  APB_Interface u_apb_if (
    .Pwrite(Pwrite), .Pselx(Pselx), .Penable(Penable),
    .Paddr(Paddr), .Pwdata(Pwdata),
    .Pwriteout(), .Pselxout(), .Penableout(),
    .Paddrout(), .Pwdataout(),
    .Prdata(Prdata)
  );

 nitial begin

  wait(Hresetn == 1);

  @(posedge Hclk);

  $display("=== Single Write ===");

  u_master.single_write(
      32'h8000_0000,
      32'hAABB_1122
  );

  @(posedge Hclk);
  @(posedge Hclk);

  $display("Pselx = %b", Pselx);
  $display("Paddr = %h", Paddr);
  $display("Pwdata = %h", Pwdata);

  #50;
  $finish;

end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
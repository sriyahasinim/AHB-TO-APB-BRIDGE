// ============================================================
// TB4 : Single Read Waveform
// First writes data, then reads it back to show Hrdata/Prdata.
// Key signals: Haddr, Hwrite, Htrans, Hrdata, Prdata,
//              Pselx, Paddr, Penable, Hreadyout
// ============================================================
`timescale 1ns/1ps
module tb_single_read;

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
    $dumpfile("tb4_single_read.vcd");
    $dumpvars(0, tb_single_read);
    wait (Hresetn == 1);
    @(posedge Hclk);

    // Pre-load data so read has something to return
    $display("[TB4] --- Write then Read Slave 1 ---");
    u_master.single_write(32'h8000_0000, 32'hAABB_1122);
    @(posedge Hclk); @(posedge Hclk);

    u_master.single_read(32'h8000_0000);
    @(posedge Hclk); @(posedge Hclk);
    $display("[TB4] Hrdata = %h (expected: AABB1122)", Hrdata);

    $display("[TB4] --- Write then Read Slave 2 ---");
    u_master.single_write(32'h8400_0004, 32'h1234_5678);
    @(posedge Hclk); @(posedge Hclk);

    u_master.single_read(32'h8400_0004);
    @(posedge Hclk); @(posedge Hclk);
    $display("[TB4] Hrdata = %h (expected: 12345678)", Hrdata);

    #20;
    $display("[TB4] Single Read waveform done.");
    $finish;
  end
endmodule

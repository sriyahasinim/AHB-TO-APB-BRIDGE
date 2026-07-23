// ============================================================
// TB5 : Burst Write Waveform (INCR4 – 4 beats)
// Shows: Haddr incrementing, Htrans=NONSEQ then SEQ x3,
//        Hburst=INCR4, Hwdata pipeline, Pselx, Paddr,
//        Pwdata, Pwrite, Penable, Hreadyout
// ============================================================
`timescale 1ns/1ps
module tb_burst_write;

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
    $dumpfile("tb5_burst_write.vcd");
    $dumpvars(0, tb_burst_write);
    wait (Hresetn == 1);
    @(posedge Hclk);

    // INCR4 burst to Slave 1 (base addr 0x8000_0000)
    $display("[TB5] --- INCR4 Burst Write to Slave 1 ---");
    u_master.burst_write(
      32'h8000_0000,
      32'h1111_1111,
      32'h2222_2222,
      32'h3333_3333,
      32'h4444_4444
    );
    @(posedge Hclk); @(posedge Hclk); @(posedge Hclk);

    // Second INCR4 burst to Slave 2 (base addr 0x8400_0000)
    $display("[TB5] --- INCR4 Burst Write to Slave 2 ---");
    u_master.burst_write(
      32'h8400_0000,
      32'hAAAA_0001,
      32'hAAAA_0002,
      32'hAAAA_0003,
      32'hAAAA_0004
    );
    @(posedge Hclk); @(posedge Hclk); @(posedge Hclk);

    #30;
    $display("[TB5] Burst Write waveform done.");
    $finish;
  end
endmodule

`timescale 1ns/1ps
module AHB_Master(Hclk, Hresetn, Hresp, Hrdata, Hwrite, Hreadyin, Hreadyout, Htrans, Hwdata, Haddr);
  input  Hclk, Hresetn, Hreadyout;
  input  [1:0]  Hresp;
  input  [31:0] Hrdata;
  output reg Hwrite, Hreadyin;
  output reg [1:0]  Htrans;
  output reg [31:0] Hwdata, Haddr;
  reg [2:0] Hburst;
  reg [2:0] Hsize;

  // ─── Single Write ───────────────────────────────────────────────────────────
  task single_write;
    input [31:0] addr;
    input [31:0] data;
    begin
      @(posedge Hclk) #2;
      Hwrite   = 1;
      Htrans   = 2'b10;   // NONSEQ
      Hsize    = 3'b000;
      Hburst   = 3'b000;  // SINGLE
      Hreadyin = 1;
      Haddr    = addr;

      @(posedge Hclk) #2;
      Htrans = 2'b00;     // IDLE
      Hwdata = data;
    end
  endtask

  // ─── Single Read ────────────────────────────────────────────────────────────
  task single_read;
    input [31:0] addr;
    begin
      @(posedge Hclk) #2;
      Hwrite   = 0;
      Htrans   = 2'b10;   // NONSEQ
      Hsize    = 3'b000;
      Hburst   = 3'b000;  // SINGLE
      Hreadyin = 1;
      Haddr    = addr;

      @(posedge Hclk) #2;
      Htrans = 2'b00;     // IDLE
    end
  endtask

  // ─── Burst Write (INCR4) ────────────────────────────────────────────────────
  // Issues 4 consecutive WRITE beats at addr, addr+4, addr+8, addr+12
  task burst_write;
    input [31:0] start_addr;
    input [31:0] data0, data1, data2, data3;
    integer k;
    reg [31:0] beat_addr [0:3];
    reg [31:0] beat_data [0:3];
    begin
      beat_addr[0] = start_addr;
      beat_addr[1] = start_addr + 32'h4;
      beat_addr[2] = start_addr + 32'h8;
      beat_addr[3] = start_addr + 32'hC;
      beat_data[0] = data0;
      beat_data[1] = data1;
      beat_data[2] = data2;
      beat_data[3] = data3;

      // Beat 0 – NONSEQ (address phase of first beat)
      @(posedge Hclk) #2;
      Hwrite   = 1;
      Htrans   = 2'b10;   // NONSEQ
      Hsize    = 3'b000;
      Hburst   = 3'b011;  // INCR4
      Hreadyin = 1;
      Haddr    = beat_addr[0];

      // Beats 1-3 – SEQ (address phase of subsequent beats, data phase of previous)
      for (k = 1; k <= 3; k = k + 1) begin
        @(posedge Hclk) #2;
        Htrans = 2'b11;   // SEQ
        Haddr  = beat_addr[k];
        Hwdata = beat_data[k-1];
      end

      // Final data phase
      @(posedge Hclk) #2;
      Htrans = 2'b00;     // IDLE
      Hwdata = beat_data[3];
    end
  endtask

endmodule

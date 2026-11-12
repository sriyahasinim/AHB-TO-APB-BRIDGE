module APB_Interface(Pwrite,Pselx,Penable,Paddr,Pwdata,Pwriteout,Pselxout,Penableout,Paddrout,Pwdataout,Prdata);

input Pwrite,Penable;
input [2:0] Pselx;
input [31:0] Pwdata,Paddr;
output Pwriteout,Penableout;
output [2:0] Pselxout;
output [31:0] Pwdataout,Paddrout;
output reg [31:0] Prdata;

assign Penableout=Penable;
assign Pselxout=Pselx;
assign Pwriteout=Pwrite;
assign Paddrout=Paddr;
assign Pwdataout=Pwdata;

reg [31:0] mem1 [0:15];
reg [31:0] mem2 [0:15];
reg [31:0] mem3 [0:15];

integer i;
initial begin
  for (i=0;i<16;i=i+1) begin
    mem1[i]=0; mem2[i]=0; mem3[i]=0;
  end
end

always @(*) begin
  if (Penable && Pwrite) begin
    if (Pselx[0]) mem1[Paddr[5:2]] = Pwdata;
    else if (Pselx[1]) mem2[Paddr[5:2]] = Pwdata;
    else if (Pselx[2]) mem3[Paddr[5:2]] = Pwdata;
  end
end

always @(*) begin
  if (Penable && ~Pwrite) begin
    if (Pselx[0]) Prdata = mem1[Paddr[5:2]];
    else if (Pselx[1]) Prdata = mem2[Paddr[5:2]];
    else if (Pselx[2]) Prdata = mem3[Paddr[5:2]];
    else Prdata = 32'h0;
  end else begin
    Prdata = 32'h0;
  end
end

endmodule
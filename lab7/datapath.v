
`define OFF 1'b0
`define ON 1'b1

module datapath(shift, ALUop, write, readnum, sximm8, sximm5, writenum, mwrite,
 loadir, reset, msel, loada, loadb, loadc, asel, bsel, loads, vsel, clk, status,
 IRout,mdata, value0, value1, value2, value3, value4, value5, tsel, execb, incp, cond);

`define SW 16;

input mwrite, loadir, reset, msel, loada, loadb, loadc, asel,
 bsel, loads,write, clk;
input [1:0] vsel,shift, ALUop;
input [2:0] readnum, writenum, cond;
input [15:0] sximm8, sximm5;
input tsel, execb, incp;
output [2:0] status;
output [15:0] IRout, mdata;
output [15:0] value0, value1, value2, value3, value4, value5;

wire[7:0] PC, aOut, bOut, cOut, pctgt, pc_next, pcrel;
wire [15:0] C, data_in, data_out, ATRANS, BTRANS, BSHIFT, AIN, BIN, OUTC, mdata;
wire [2:0] OUTSTATS, status;
wire loadpc;
reg taken;

// add 4 input mux to whole project
Muxb4 #(16) part9(mdata, sximm8,{8'b0,PC}, C, vsel, data_in) ;
registerFile part1(writenum, write, data_in, clk, readnum, data_out, value0, value1, value2, value3, value4, value5);
LERegister part3(data_out, loada, clk, ATRANS);
LERegister part4(data_out, loadb, clk, BTRANS);
shifter part8(BTRANS, shift, BSHIFT);
Muxb2 #(16) part6(16'b0000000000000000, ATRANS, asel, AIN) ;
Muxb2  #(16) part7(sximm5, BSHIFT, bsel, BIN) ;
ALU part2 (AIN, BIN, ALUop, OUTC, OUTSTATS);
LERegister part5(OUTC, loadc, clk, C);
LERegister3 part10(OUTSTATS, loads, clk, status);

always @(*) begin
  casex({cond, status})
    6'b000XXX: taken = execb ? `ON : `OFF;
    6'b001XX1: taken = execb ? `ON : `OFF;
    6'b010XX0: taken = execb ? `ON : `OFF;
    6'b01110X: taken = execb ? `ON : `OFF;
    6'b01101X: taken = execb ? `ON : `OFF;
    6'b100XX1: taken = execb ? `ON : `OFF;
    6'b10001X: taken = execb ? `ON : `OFF;
    6'b10010X: taken = execb ? `ON : `OFF;
    6'b111XXX: taken = execb ? `ON : `OFF;
    default: taken  = `OFF; 
  endcase
end
//always @(*) begin
//  case ({incp, taken})
//    2'bX1: loadpc = 1'b1;
//    2'b1X: loadpc = 1'b1;
//    default: loadpc = 1'b0;
//  endcase
//end
assign loadpc = incp | taken;
assign  pcrel = PC[7:0] + sximm8[7:0];
Muxb2 #(8) muxE(pcrel, ATRANS[7:0], tsel, pctgt);
Muxb2 #(8) muxD(PC+1'b1, pctgt, incp, pc_next);
Muxb2 #(8) muxA(pc_next, PC, loadpc, aOut);
Muxb2 #(8) muxB(8'b0, aOut, reset, bOut);
vDFF #(8) PCflipflop(clk, bOut, PC);
Muxb2 #(8) muxC(C[7:0], PC, msel, cOut);
RAM #(16, 8, "test1.txt") ram1(.clk(clk), .read_address(cOut), .write_address(cOut),.write(mwrite), .din(BTRANS), .dout(mdata));
LERegister IR(.in(mdata), .load(loadir), .clk(clk), .out(IRout));
endmodule

module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32;
  parameter addr_width = 4;
  parameter filename = "data.txt";
  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;
  reg [data_width-1:0] mem [2**addr_width-1:0];
  initial $readmemb(filename, mem);
  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle
                               // (this is due to Verilog non-blocking assignment "<=")
  end
endmodule

// 4->1 multiplexer with binary select
module Muxb4(a3, a2, a1, a0, sb, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2, a3 ;  // inputs
  input [1:0]sb ;          // one bit binary select
  output[k-1:0] b ; // output
  wire  [3:0]   s ;
 
  Dec #(2,4) dec24(sb,s) ; // Decoder converts binary to one-hot   
  Muxo4 #(k)  m(a3, a2, a1, a0, s, b) ; // multiplexer selects input
endmodule

module Muxo4(a3, a2, a1, a0, s, b);
  parameter k = 1;
  input [k-1:0] a3, a2, a1, a0;
  input [3:0] s;
  output [k-1:0] b;
  assign b = ({k{s[0]}} & a0) |
                   ({k{s[1]}} & a1) |
                   ({k{s[2]}} & a2) |
                   ({k{s[3]}} & a3);
endmodule



module ALU(AIN, BIN, ALUop, OUTC, OUTSTATS);

input [15:0] AIN;
input [15:0] BIN;
input [1:0] ALUop;

output [15:0] OUTC;
output [2:0] OUTSTATS;

wire [15:0] AND_RESULT;
wire [15:0] ADD_RESULT;
wire [15:0] SUB_RESULT;
wire [15:0] NOT_RESULT;
reg overflow;
wire overflowAdd, overflowSub;
reg [15:0] OUTC;


`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define NOT 2'b11
`define ZEROS 16'b0

assign AND_RESULT= (AIN & BIN);
AddSub #(16) add(AIN, BIN, 1'b0, ADD_RESULT, overflowAdd);
AddSub #(16) sub(AIN, BIN, 1'b1, SUB_RESULT, overflowSub);
assign NOT_RESULT=( ~ BIN);

always @(*) begin
case (ALUop)
`ADD : {OUTC, overflow} = {ADD_RESULT, overflowAdd};
`SUB : {OUTC, overflow} = {SUB_RESULT, overflowSub};
`AND : {OUTC, overflow} = {AND_RESULT, 1'b0};
`NOT : {OUTC, overflow} = {NOT_RESULT, 1'b0};
default: {OUTC, overflow}=17'b11111111111111110;
endcase
end

assign OUTSTATS={(OUTC[15] == 1'b1),overflow,(`ZEROS == OUTC)};

endmodule

module AddSub(a,b,sub,s,ovf) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule

// multi-bit adder - behavioral
module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 



module ALU_tb;
reg [1:0] ALUop;
reg [15:0] AIN, BIN;
wire OUTSTATS;
wire [15:0] OUTC;
ALU dut(AIN, BIN, ALUop, OUTC, OUTSTATS);

initial begin
AIN=16'b00000000000000001;
BIN=16'b00000000000000010;
ALUop=`ADD;
#5;
$display("Output is %b, we expected %b", OUTC, (16'b00000000000000001 + 16'b00000000000000010));
$display("Output is %b, we expected 0",OUTSTATS);
#5;
AIN=16'b00000000000010001;
BIN=16'b00000000000000010;
ALUop=`SUB;
#5;
$display("Output is %b, we expected %b", OUTC, (16'b00000000000010001 - 16'b00000000000000010));
$display("Output is %b, we expected 0",OUTSTATS);

#5;
BIN=16'b00000000000010001;
AIN=16'b00000000000000000;
ALUop=`NOT;
#5;
$display("Output is %b, we expected %b", OUTC, (~16'b00000000000010001));
$display("Output is %b, we expected 0",OUTSTATS);
#5;
BIN=16'b00000000000010001;
AIN=16'b00000000000000000;
ALUop=`AND;
#5;
$display("Output is %b, we expected %b", OUTC, (16'b00000000000000000&16'b00000000000010001));
$display("Output is %b, we expected 1",OUTSTATS);

#5
AIN=16'b00000000000000000;
BIN=16'b00000000000000000;
ALUop=`ADD;
#5;
$display("Output is %b, we expected %b", OUTC, (16'b00000000000000000 + 16'b00000000000000000));
$display("Output is %b, we expected 1",OUTSTATS);
#5;

end


endmodule 
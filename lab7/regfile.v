
// writenum - which register to write to (binary)
// write - write if true, don't write if false
// data_in - number to write to register (binary)
 
module registerFile(writenum, write, data_in, clk, readnum, data_out, value0, value1, value2, value3, value4, value5);
  input [2:0] writenum, readnum;
  input write, clk;
  input [15:0] data_in;
  output [15:0] data_out;
  output [15:0] value0, value1, value2, value3, value4, value5;

  wire [15:0] data_out;

  wire [7:0] writeselect, readselect, load; // select is one hot output of the decoder, load is one hot that tells a register to change values or not
  wire [15:0] value0, value1, value2, value3, value4, value5, value6, value7; // values in each register

  // write is synchronous but clock is dealt with in the leaf modules
  Dec #(3,8) writeDec(writenum, writeselect);
  assign load = {8{write}} & writeselect;
  LERegister R0 (data_in, load[0], clk, value0);
  LERegister R1 (data_in, load[1], clk, value1);
  LERegister R2 (data_in, load[2], clk, value2);
  LERegister R3 (data_in, load[3], clk, value3);
  LERegister R4 (data_in, load[4], clk, value4);
  LERegister R5 (data_in, load[5], clk, value5);
  LERegister R6 (data_in, load[6], clk, value6);
  LERegister R7 (data_in, load[7], clk, value7);

  // read is combinational
  Dec #(3,8) readDec(readnum, readselect);
  Muxh8 #(16) mux(value7,value6,value5,value4,value3,value2,value1,value0,readselect,data_out);
endmodule

// load enable register
// in assigned to out on positive edge of the clock and load is 1
module LERegister (in, load, clk, out);
  input [15:0] in;
  input load, clk;
  output [15:0] out;

  reg [15:0] pick;

  always @(*) begin
    case (load)
      1'b0: pick = out;
      1'b1: pick = in;
    endcase
  end
  //multiplexer part of circuit
  // Muxb3 #(16) muxpick(in, out, load, pick);
  // D flip flop
  vDFF #(16) flipflop(clk, pick, out);
endmodule

module LERegister3 (in, load, clk, out);
  input [2:0] in;
  input load, clk;
  output [2:0] out;

  reg [2:0] pick;

  always @(*) begin
    case (load)
      1'b0: pick = out;
      1'b1: pick = in;
    endcase
  end
  vDFF #(3) flipflop(clk, pick, out);
endmodule


//8->1 multiplexer
module Muxh8 (a7,a6,a5,a4,a3,a2,a1,a0,sb,b);
  parameter k=1;
  input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0; // inputs
  input [7:0] sb; //one hot select
  output [k-1:0] b; //output

  assign b = ({k{sb[0]}} & a0) | 
                   ({k{sb[1]}} & a1) |
                   ({k{sb[2]}} & a2) |
                   ({k{sb[3]}} & a3) |
                   ({k{sb[4]}} & a4) |
                   ({k{sb[5]}} & a5) |
                   ({k{sb[6]}} & a6) |
                   ({k{sb[7]}} & a7) ;
endmodule

// binary 2->1 multiplexer (adapted from slide set 4)
module Muxb2(a1, a0, sb, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1 ;  // inputs
  input  sb ;          // one bit binary select
  output[k-1:0] b ; // output
  wire  [1:0]   s ;
  
  Dec #(1,2) dec12(sb,s) ; // Decoder converts binary to one-hot   
  Muxo2 #(k)  m(a1, a0, s, b) ; // multiplexer selects input 
endmodule

// one hot 2->1 mutiplexer (adapted from slide set 4)
module Muxo2(a1, a0, s, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1 ;  // inputs
  input [1:0]   s ; // one-hot select
  output[k-1:0] b ;
  reg [k-1:0] b ;

  always @(*) begin
    case(s) 
      2'b01: b = a0 ;
      2'b10: b = a1 ;
      default: b =  {k{1'bx}} ;
    endcase
  end
endmodule

// binary to one hot decoder (from slide set 4)
// a - binary input   (n bits wide)
// b - one hot output (m bits wide)
module Dec(a, b) ;
  parameter n=2 ;
  parameter m=4 ;

  input  [n-1:0] a ;
  output [m-1:0] b ;

  wire [m-1:0] b = 1<<a ;
endmodule
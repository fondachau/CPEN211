
// INSTRUCTIONS:
//
// You can use this file to demo your Lab5 on your DE1-SoC.  You should NOT
// spend ANY time looking at this file until you have first read the Lab 5
// handout completely and especially Sections 3 (Lab Procedure) and Section 4
// (which describes the marking scheme).
//
// If you prefer you can instead use your own version of lab5_top.v.
//
// You MUST submit whichever lab5_top.v you used during your demo with handin.
//
// If you DO use this file you will need to fill in the sseg module as by
// default it will just print F's on HEX0 through HEX3.  Also, the signal
// names inside the lab5_top module may need to be change to match the
// ones you use in your own datapath module.



// DE1-SOC INTERFACE SPECIFICATION for lab5_top.v code in this file:
//
// clk input to datpath has rising edge when KEY0 is *pressed*
//
// LEDR9 is the status register output
//
// HEX3, HEX2, HEX1, HEX0 are wired to datapath_out.
//
// When SW[9] is set to 1, SW[7:0] changes the lower 8 bits of datpath_in.
// (The upper 8-bits are hardwired to zero.) The LEDR[8:0] will show the
// current control inputs (LED "on" means input has logic value of 1).
//
// When SW[9] is set to 0, SW[8:0] changes the control inputs to the datapath
// as listed in the table below.  Note that the datapath has three main
// stages: register read, execute and writeback.  On any given clock cycle,
// you should only need to configure one of these stages so some switches are
// reused.  LEDR[7:0] will show the lower 8-bits of datapath_in (LED "on"
// means corresponding input has logic value of 1).
//
// control signal(s)  switch(es)
// ~~~~~~~~~~~~~~~~~  ~~~~~~~~~       
// <<register read stage>>
//           readnum  SW[3:1]
//             loada  SW[5]
//             loadb  SW[6]
// <<execute stage>>
//             shift  SW[2:1]
//              asel  SW[3]
//              bsel  SW[4]
//             ALUop  SW[6:5]
//             loadc  SW[7]
//             loads  SW[8]
// <<writeback stage>>
//             write  SW[0]      
//          writenum  SW[3:1]
//              vsel  SW[4]

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
 
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

  // wire [15:0] datapath_out, datapath_in;
  wire clk, reset, tsel, execb, incp;
  wire [15:0] IRout, sximm8, sximm5, mdata;
  wire [2:0] opcode, writenum, readnum, status, cond;
  wire [1:0] op, nsel, vsel, shift, ALUop;
  wire loadir, loada, loadb, loadc,loads, asel, bsel, write, msel, mwrite;
  wire [15:0] value0, value1, value2, value3, value4, value5;
  
  // reg [15:0] display;
  
  wire [7:0] PC;

  assign reset = ~KEY[0];
  assign clk = CLOCK_50;

  INSTRUCTIONDECODER DUTIT( .IN(IRout) ,.nsel(nsel), .opcode(opcode), .op(op), .writenum(writenum), .readnum(readnum), .shift(shift), .sximm8(sximm8), .sximm5(sximm5),
	 .ALUop(ALUop), .cond(cond));                
  CPU DUTCPU (.clk(clk),.reset(reset), .opcode(opcode), .op(op), .loadir(loadir), .loada(loada), .loadb(loadb), .loadc(loadc),.loads(loads),  .asel(asel),
	 .bsel(bsel), .write(write), .nsel(nsel), .vsel(vsel), .msel(msel), .mwrite(mwrite), .execb(execb), .incp(incp), .tsel(tsel));
  datapath DUTDP ( .clk         (clk), // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),

                // computation stage (sometimes called "execute")
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),

                // set when "writing back" to register file
                .writenum    (writenum),
                .write       (write),  
                .mwrite      (mwrite),
      	        .loadir      (loadir),
		.reset       (reset),
		.msel        (msel),
		.sximm8      (sximm8),
		.sximm5      (sximm5),

                // outputs
                // .status      (LEDR[9]),
		.status        (status),           
		.IRout       (IRout),
		.mdata       (mdata),
		.value0	     (value0),
		.value1      (value1), 
		.value2      (value2), 
		.value3      (value3), 
		.value4      (value4), 
		.value5      (value5),
		.tsel        (tsel),
		.execb       (execb),
		.incp        (incp),
		.cond        (cond)
);


// fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(value0[3:0],   HEX0);   
  sseg H1(value1[3:0],   HEX1);
  sseg H2(value2[3:0],  HEX2);
  sseg H3(value3[3:0], HEX3);
  sseg H4(value4[3:0],  HEX4);
  sseg H5(value5[3:0], HEX5);
 
endmodule // end top module


module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)
    Q = D;
endmodule


// The sseg module below can be used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit.  You
// may want to look at the code in Figure 7.20 and 7.21 in Dally but note this
// code will not work with the DE1-SoC because the order of segments used in
// the book is not the same as on the DE1-SoC (see comments below).

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
 
  reg [6:0] segs;

  // outputs
  `define zero 7'b1000000 // 0
  `define one 7'b1111001 // 1
  `define two 7'b0100100 // 2
  `define three 7'b0110000 // 3
  `define four 7'b0011001 // 4
  `define five 7'b0010010 // 5
  `define six 7'b0000010 // 6
  `define seven 7'b1111000 // 7
  `define eight 7'b0000000 // 8
  `define nine 7'b0011000 // 9

  `define ten 7'b0001000 // A (10)
  `define eleven 7'b0000011 // B (11)
  `define twelve 7'b1000110 // C (12)
  `define thirteen 7'b0100001 // d (13)
  `define fourteen 7'b0000110 // E (14)
  `define fifteen 7'b0001110 // F (15)

  always @(*) begin
    case(in)
      4'b0000: segs = `zero;
      4'b0001: segs = `one;
      4'b0010: segs = `two;
      4'b0011: segs = `three;
      4'b0100: segs = `four;
      4'b0101: segs = `five;
      4'b0110: segs = `six;
      4'b0111: segs = `seven;
      4'b1000: segs = `eight;
      4'b1001: segs = `nine;
      4'b1010: segs = `ten;
      4'b1011: segs = `eleven;
      4'b1100: segs = `twelve;
      4'b1101: segs = `thirteen;
      4'b1110: segs = `fourteen;
      4'b1111: segs = `fifteen;
      default: segs = 7'b0111111;
    endcase
  end

  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code:
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F


endmodule

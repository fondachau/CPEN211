module datapath_tb;

`define ON 1'b1
`define OFF 1'b0
`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111

`define PICKRM 2'b00
`define PICKRD 2'b01
`define PICKRN 2'b10

reg mwrite, loadir, reset, msel, loada, loadb, loadc, asel, bsel,
 loads, write, clk, tsel, incp, execb;
reg[1:0] shift, op, vsel;
reg [2:0] readnum, writenum, cond;
reg [15:0] sximm8, sximm5;
wire [15:0] IRout, mdata, value0, value1, value2, value3, value4, value5;
wire [2:0] status;

datapath dut (.shift(shift), .ALUop(op), .write(write), .readnum(readnum),
 .sximm8(sximm8), .sximm5(sximm5), .writenum(writenum), .mwrite(mwrite),
 .loadir(loadir), .reset(reset), .msel(msel), .loada(loada), .loadb(loadb),
 .loadc(loadc), .asel(asel), .bsel(bsel), .loads(loads), .vsel(vsel), .clk(clk),
 .IRout(IRout), .mdata(mdata), .status(status), .value0(value0), .value1(value1),
 .value2(value2), .value3(value3), .value4(value4), .value5(value5), .tsel(tsel),
 .execb(execb), .incp(incp), .cond(cond));

//registerFile part1(writenum, write, data_in, clk, readnum, data_out);
initial begin
  clk=0; #5;
  forever begin
    clk=1; #5;
    clk=0; #5;
  end
end

initial begin
  {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite,vsel}=
      {1'b1, `OFF,`OFF,`OFF,`OFF,`OFF,`OFF,`OFF,`OFF,`OFF,`OFF ,2'b00}; // load IR
  loads = `OFF;
  tsel = `ON;
  
  //MOV1 first time (1 into r0)
  #5 reset = `ON;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // load IR 
      op = 10; 	sximm8 = 16'b0000000000000001; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10,  `ON, `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF,  `ON,  `OFF,  `OFF,  `OFF, `OFF,`  OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // read Rn
      writenum = `R0; readnum = `R0;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,`OFF ,`OFF  ,`OFF  ,`OFF  ,`OFF ,`ON   ,`OFF , `OFF  ,2'b10, `OFF, `OFF};

  //MOV1 second time (2 into r1)
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // load IR 
      op = 10; 	sximm8 = 16'b0000000000000010; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10,  `ON, `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF,  `ON,  `OFF,  `OFF,  `OFF, `OFF,`  OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // read Rn
      writenum = `R1; readnum = `R1;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,`OFF ,`OFF  ,`OFF  ,`OFF  ,`OFF ,`ON   ,`OFF , `OFF  ,2'b10, `OFF, `OFF};

  //MOV1 third time (3 into r2)
   #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // load IR 
      op = 10; 	sximm8 = 16'b0000000000000011; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10,  `ON, `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF,  `ON,  `OFF,  `OFF,  `OFF, `OFF,`  OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // read Rn
      writenum = `R2; readnum = `R2;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,`OFF ,`OFF  ,`OFF  ,`OFF  ,`OFF ,`ON   ,`OFF , `OFF  ,2'b10, `OFF, `OFF};
  
  //MOV1 fourth time (3 into r3)
   #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // load IR 
      op = 10; 	sximm8 = 16'b0000000000000011; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10,  `ON, `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF,  `ON,  `OFF,  `OFF,  `OFF, `OFF,`  OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // read Rn
      writenum = `R3; readnum = `R3;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,`OFF ,`OFF  ,`OFF  ,`OFF  ,`OFF ,`ON   ,`OFF , `OFF  ,2'b10, `OFF, `OFF};

  //MOV1 fifth time (1 into r4)
   #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // load IR 
      op = 10; 	sximm8 = 16'b0000000000000001; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b10,  `ON, `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF,  `ON,  `OFF,  `OFF,  `OFF, `OFF,`  OFF, `OFF,   `OFF,2'b10, `OFF, `OFF}; // read Rn
      writenum = `R4; readnum = `R4;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,`OFF ,`OFF  ,`OFF  ,`OFF  ,`OFF ,`ON   ,`OFF , `OFF  ,2'b10, `OFF, `OFF};

  // CMP r0 to r1 (R0 < R1) WHAT SHOULD THE FLAGS BE????
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF};  //load IR
      op = 01; sximm8 = 16'b0000000000000000; sximm5 = 16'b0000000000000000; shift = 2'b00;cond = 3'b000;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00,  `ON,  `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,  `ON,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF}; // read Rn
      readnum = `R0; writenum = `R0;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,   `OFF, `OFF,  `ON,  `OFF,  `OFF,` OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF}; // read Rm
      readnum = `R1; writenum = `R1;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,   `ON,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF}; // update status flags
      loads = 1'b1;

  // BLE L1
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      {1'b0,    `ON, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF};  //load IR
      op = 00; sximm8 = 16'b0000000000000001; sximm5 = 16'b0000000000000000; shift = 2'b00; cond = 3'b100; loads = `OFF;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00,  `ON,  `OFF}; // update PC
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0, `OFF ,  `ON,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF}; // read Rn
      readnum = `R0; writenum = `R0;
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,   `ON}; // update PC to branch
  #10 {reset,loadir,loada, loadb, loadc,  asel, bsel, write, msel, mwrite, vsel, incp, execb}=
      { 1'b0,  `OFF, `OFF,  `OFF,  `OFF,  `OFF, `OFF,  `OFF, `OFF,   `OFF,2'b00, `OFF,  `OFF}; // wait for mdata to update (PC shouldn't be counting anymore)
  #30

  $stop;
end

endmodule

module CPU (clk, reset, opcode, op,cond, loadir, loada, loadb, loadc,loads,  asel, bsel, write, nsel, vsel, msel, mwrite,incp,execb,tsel);

input reset;
input [2:0] opcode,cond;
input [1:0]op;
input clk;
output [1:0] nsel,vsel;
reg [1:0] nsel,vsel;
output loadir, loada, loadb, loadc,loads,  asel, bsel, write, msel, mwrite,tsel, incp,execb;
reg loadir, loada, loadb, loadc,loads,  asel, bsel, write, msel, mwrite,tsel, incp,execb;

wire [2:0]step;
reg [2:0] nextstep;
`define ADD 2'b00
`define CMP 2'b01
`define AND 2'b10
`define MVN 2'b11
`define MOVimm8 2'b10
`define MOV2 2'b00
`define LDR 5'b01100
`define STR 5'b10000

`define BRANCH 5'b00100 // B BEQ BNE BLT BLE
`define BL 5'b01011
`define BLX 5'b01010
`define BX 5'b01000

`define PICKRM 2'b00
`define PICKRD 2'b01
`define PICKRN 2'b10
`define S1 3'b000 //load IR
`define S2 3'b001 //UPDATE PC
`define S3 3'b010 //DECODE READ RN
`define S4 3'b011 //READ RM
`define S5 3'b100 //ALU
`define S6 3'b101 // WRITE RD OR RN
`define S7 3'b110 //
`define S8 3'b111

`define ALUCODE 3'b101
`define MOVECODE 3'b110 

`define ON 1'b1
`define OFF 1'b0

vDFF #(3) nextit( clk, nextstep, step);
always @(*) begin
casex({reset,opcode,op,cond,step})
{`ON, 11'bXXXXXXXXXXX}:{nextstep,  loadir,  loada,  loadb,  loadc,  loads,  asel,  bsel,  write,  msel,  mwrite,  nsel,  vsel,  incp,  execb,  tsel}=
              	       {`S1,       `ON,     `OFF,   `OFF,   `OFF,   `OFF,   `OFF,  `OFF,  `OFF,   `OFF,    `OFF,    4'bXXXX,    `ON,    `OFF,    `ON};
{`OFF, `MOVECODE, 2'bXX,3'bXXX, `S1}:{nextstep,  loadir,  loada,  loadb,  loadc,  asel,  bsel,  write,  msel,  mwrite,  nsel,  vsel,  incp,  execb,  tsel,  loads}=
                                     {`S2    ,   `ON,     `OFF,   `OFF,   `OFF,   `OFF,  `OFF,  `OFF,   `OFF,  `OFF,    4'bXX00,      `OFF,  `OFF,   `ON,   `OFF};
{`OFF, `MOVECODE, 2'bXX, 3'bXXX,`S2}:{nextstep,  loadir,  loada,  loadb,  loadc,  asel,  bsel,  write,  msel,  mwrite,  nsel,  vsel,  incp,  execb,  tsel,  loads}=
                                     {`S3    ,   `ON,     `OFF,   `OFF,   `OFF,   `OFF,  `OFF,  `OFF,   `OFF,  `OFF,    4'bXX10,      `ON,   `OFF,   `ON,   `OFF};
{`OFF, `MOVECODE, 2'bXX,3'bXXX, `S3}:{nextstep,  loadir,  loada,  loadb,  loadc,  asel,  bsel,  write,  msel,  mwrite,  nsel,  vsel,  incp,  execb,  tsel,  loads}=
                                     {`S4    ,   `OFF,    `ON,    `OFF,   `OFF,   `OFF,  `OFF,  `OFF,   `OFF,  `OFF,    `PICKRN,2'b10,`OFF,  `OFF,   `ON,   `OFF};
{`OFF, `MOVECODE, `MOVimm8,3'bXXX, `S4}:{nextstep,  loadir,  loada,  loadb,  loadc,  asel,  bsel,  write,  msel,  mwrite,  nsel,  vsel,  incp,  execb,  tsel,  loads}=
                                        {`S1    ,   `OFF,    `OFF,   `OFF,   `OFF,   `OFF,  `OFF,  `ON,    `OFF,  `OFF,    `PICKRN ,2'b10,`OFF, `OFF,   `ON,   `OFF};

{`OFF, `MOVECODE, `MOV2, 3'bXXX,`S4}:{nextstep,  loadir,  loada,  loadb,  loadc,  asel,  bsel,  write,  msel,  mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                            	     {`S5,    `OFF,    `OFF,    `ON,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRM,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `MOVECODE, `MOV2, 3'bXXX,`S5}:{nextstep,loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                            	     {`S6,    `OFF,    `OFF,    `OFF,    `ON,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `MOVECODE, `MOV2, 3'bXXX,`S6}:{nextstep,loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                            	     {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};

{`OFF, `LDR, 3'bXXX,`S1}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S2    ,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX11,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `LDR, 3'bXXX,`S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	 {`S3    ,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX11,    `ON,    `OFF,    `ON,    `OFF};
{`OFF, `LDR,3'bXXX, `S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S4    ,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRN,2'b11,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `LDR, 3'bXXX,`S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S5    ,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `ON,    `OFF,    `ON,    `OFF,    `PICKRN,2'b11,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `LDR ,3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S6    ,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `ON,    `OFF,    4'bXX11,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `LDR, 3'bXXX,`S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                	 {`S1    ,    `OFF,    `OFF,	`OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRD,2'b11,    `ON,    `OFF,    `ON,    `OFF};

{`OFF, `ALUCODE, 2'bXX, 3'bXXX,`S1}:{nextstep,    loadir,    loada,    loadb,    loadc,  asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S2,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, 2'bXX,3'bXXX, `S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                            	   {`S3,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `ON,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, 2'bXX,3'bXXX, `S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S4,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRN,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, 2'bXX,3'bXXX, `S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S5,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRM,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, `ADD, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S6,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, `ADD,3'bXXX, `S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};

{`OFF, `ALUCODE, `AND, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S6,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, `AND, 3'bXXX,`S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};

{`OFF, `ALUCODE, `MVN, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S6,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, `MVN, 3'bXXX,`S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                          	   {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `ALUCODE, `CMP, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    loads, nsel,    vsel,    incp,    execb,    tsel}=
                          	   {`S1,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    4'bXX00,    `OFF,    `OFF,    `ON};

{`OFF, `STR, 3'bXXX,`S1}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S2,        `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `STR, 3'bXXX,`S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S3,        `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `ON,    `OFF,    `ON,    `OFF};
{`OFF, `STR, 3'bXXX,`S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S4,        `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRN,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `STR, 3'bXXX,`S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S5,        `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `STR,3'bXXX, `S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S6,        `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `PICKRD, 2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `STR, 3'bXXX,`S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S7,        `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `ON,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `STR,3'bXXX, `S7}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                 	 {`S1,        `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `PICKRD,2'b00,    `OFF,    `OFF,    `ON,    `OFF};

{`OFF, `BRANCH, 3'bXXX, `S1}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                    	     {`S2,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `BRANCH, 3'bXXX,`S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S3,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `ON,    `OFF,    `ON,    `OFF};
{`OFF, `BRANCH, 3'bXXX,`S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S4,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRN,2'b00,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `BRANCH, 3'bXXX,`S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S5,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `ON ,    `ON,    `OFF };
{`OFF, `BRANCH, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads    }=
                   	    {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX00,    `OFF,    `OFF,    `ON,    `OFF  };


{`OFF, `BL, 3'bXXX, `S1}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                    	     {`S2,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `BL, 3'bXXX,`S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S3,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `ON,    `OFF,    `ON,    `OFF};
{`OFF, `BL, 3'bXXX,`S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S4,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRN,2'b01,    `OFF,    `OFF,    `ON,    `OFF};
{`OFF, `BL, 3'bXXX,`S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads    }=
                   	    {`S5,    `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `ON,    `OFF,    `OFF,    `PICKRN ,2'b01,    `OFF,    `OFF,    `ON,    `OFF  };
{`OFF, `BL, 3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S6,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `OFF,    `ON ,    `ON,    `OFF };
{`OFF, `BL, 3'bXXX,`S6}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                   	    {`S1,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `OFF,    `OFF ,    `ON,    `OFF};

{`OFF, `BX,3'bXXX, `S1}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                {`S2,        `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `OFF,    `OFF,    `OFF,    `OFF};
{`OFF, `BX,3'bXXX,`S2}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
                       {`S3,        `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXX01,    `ON,    `OFF,    `OFF,    `OFF};
{`OFF, `BX,3'bXXX,`S3}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
               {`S4,        `OFF,    `ON,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRD    ,2'b01,    `OFF,    `OFF,    `OFF,    `OFF};
{`OFF, `BX,3'bXXX,`S4}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
               {`S5,        `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRD ,2'b01,    `OFF,    `ON ,    `OFF ,    `OFF};
{`OFF, `BX,3'bXXX,`S5}:{nextstep,    loadir,    loada,    loadb,    loadc,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
               {`S1,        `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `PICKRD ,2'b01,    `OFF,    `OFF,    `OFF ,    `OFF };


{9'bXXXXXXXXX,`S8}:{nextstep,    loadir,    loada,    loadb,    loadc,    loads,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
           {`S8    ,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXXXX,    `OFF,    `OFF,    `OFF,    `OFF};

default :{nextstep,    loadir,    loada,    loadb,    loadc,    loads,    asel,    bsel,    write,    msel,    mwrite,    nsel,    vsel,    incp,    execb,    tsel,loads}=
     {`S8    ,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    `OFF,    4'bXXXX,    `OFF,    `OFF,    `OFF,    `OFF};


endcase
end
endmodule

module INSTRUCTIONDECODER ( IN,nsel, opcode, op, writenum, readnum, shift, sximm8, sximm5, ALUop, cond);

input [15:0] IN;

// WIDTH TBD
input [1:0] nsel;

output [1:0] ALUop;
output [15:0] sximm5;
output [15:0] sximm8;
output [1:0] shift;
output [2:0] readnum;
output [2:0] writenum;
output [1:0] op;
output [2:0] opcode;
output [2:0] cond;

wire [2:0] muxpicked;
wire [2:0] Rn;
wire [2:0] Rd;
wire [2:0] Rm;
wire [4:0] imm5;
wire [7:0] imm8;

assign opcode= IN[15:13];
assign op= IN[ 12:11];
assign ALUop= IN [12:11];
assign shift =IN[4:3];
assign Rn= IN[10:8];
assign Rd=IN[7:5];
assign Rm= IN[2:0];
assign imm5= IN[4:0];
assign imm8= IN[7:0];
assign writenum= muxpicked;
assign readnum=muxpicked;
assign cond=IN[10:8];

Muxb3 #(3) nselmux (Rn,Rd,Rm, nsel, muxpicked);
SIGNEXTEND #(5) sximmed5 (imm5,sximm5);
SIGNEXTEND #(8) sximmed8 (imm8,sximm8);

endmodule

module SIGNEXTEND ( IN, OUT);
parameter  k=1;
input [k-1:0] IN;
output [15:0] OUT;

assign OUT[k-1:0]=IN[k-1:0];
assign OUT[15:k]= {16-k{IN[k-1]}};
endmodule






// 3-> 1 mux
module Muxb3(a2, a1, a0, sb, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2 ;  
  input [1:0]   sb ;          
  output[k-1:0] b ;
  wire  [2:0]   s ;
 
  Dec #(2,3) d(sb,s) ;  
  Mux3a #(k)  m(a2, a1, a0, s, b) ; 
endmodule

module Mux3a(a2, a1, a0, s, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2 ;  // inputs
  input [2:0]   s ; // one-hot select
  output[k-1:0] b ;
  reg [k-1:0] b ;
  always @(*) begin
    case(s)
      3'b001: b = a0 ;
      3'b010: b = a1 ;
      3'b100: b = a2 ;
      default: b =  {k{1'bx}} ;
    endcase
  end
endmodule







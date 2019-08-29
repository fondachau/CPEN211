
`define NOSHIFT 2'b00
`define LEFT 2'b01
`define RIGHT0 2'b10
`define RIGHT 2'b11

module shifter(in, shift, out);
  input [15:0] in;
  input [1:0] shift;
  output [15:0] out;

  reg [15:0] out;

  always @(*) begin
    case (shift)
      `NOSHIFT: out = in[15:0];
      `LEFT: out = {in[14],in[13],in[12],in[11],
		in[10],in[9],in[8],in[7],
		in[6],in[5],in[4],in[3],
		in[2],in[1],in[0],1'b0};
      `RIGHT0: out = {1'b0, in[15], in[14],in[13],
		in[12],in[11],in[10],in[9],
		in[8],in[7],in[6],in[5],
		in[4],in[3],in[2],in[1]};
      `RIGHT: out = {in[15], in[15], in[14],in[13],
		in[12],in[11],in[10],in[9],
		in[8],in[7],in[6],in[5],
		in[4],in[3],in[2],in[1]};
      default: out = in[15:0];
    endcase
  end
endmodule
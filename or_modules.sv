`timescale 10ps/1fs
module or_4bit(in, out);
	input logic [3:0] in;
	output logic out;
	
	or #5 (out, in[0], in[1], in[2], in[3]);
endmodule

module or_16bit(in, out);
	input logic [15:0] in;
	output logic out;
	
	wire [3:0] w;
	or_4bit or0 (in[3:0], w[0]);
	or_4bit or1 (in[7:4], w[1]);
	or_4bit or2 (in[11:8], w[2]);
	or_4bit or3 (in[15:12], w[3]);
	
	or_4bit or4 (w[3:0], out);

endmodule


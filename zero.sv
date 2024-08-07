`timescale 10ps/1fs
module zero_detector(in, zero);
	input logic [63:0] in;
	output logic zero;
	
	wire [3:0] w;
	wire not_zero;
	
	or_16bit or0 (in[15:0], w[0]);
	or_16bit or1 (in[31:16], w[1]);
	or_16bit or2 (in[47:32], w[2]);
	or_16bit or3 (in[63:48], w[3]);
	or_4bit or4 (w[3:0], not_zero);
	
	not #5 (zero, not_zero);
	
endmodule

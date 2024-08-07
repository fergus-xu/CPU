`timescale 10ps/1fs
module adder_1bit(A, B, Cin, sum, Cout);
	input logic A, B, Cin;
	output logic sum, Cout;
	
	wire [2:0] w;
	
	xor #5 (w[0], A, B);
	and #5 (w[1], A, B);
	xor #5 (sum, w[0], Cin);
	and #5 (w[2], w[0], Cin);
	or #5 (Cout, w[1], w[2]);
	
endmodule
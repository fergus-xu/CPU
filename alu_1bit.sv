`timescale 10ps/1fs
// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

//subtractor -> not b + 1


module alu_1bit(A, B, cntrl, out, Cin, Cout);
	input logic A, B, Cin;
	input logic [2:0] cntrl;
	output logic out, Cout;
	
	logic [3:0] w;
	
	//invert B if subtraction
	logic Bnot, Breal;
	xor #5 (Breal, cntrl[0], B);
	//not #5 (Bnot, B);
	//mux2_1 mux0 (B, Bnot, cntrl[0], Breal);
	
	and #5 (w[0], A, B);
	or #5 (w[1], A, B);
	xor #5 (w[2], A, B);
	
	adder_1bit add (.A(A), .B(Breal), .Cin(Cin), .sum(w[3]), .Cout(Cout)); // adder or subtractor
	
	mux8_1 mux1 (.in({1'b0, w[2:0], w[3], w[3], 1'b0, B}), .sel(cntrl), .out);
	
endmodule
	
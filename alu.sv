// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
`timescale 10ps/1fs
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic	[63:0] A, B;
	input logic	[2:0]	cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out ;
	
	//Read cntrl[0] as first Cin, 0 for addition, 1 for subtraction
	
// Unused Ripple Carry ALU	
//	logic [63:0] C;
//		
//	assign C[0] = cntrl[0]; //set first carryin to cntrl[0]
//	genvar i;
//	
//	generate
//		for (i=0; i < 63; i = i+1) begin: alus
//			alu_1bit alu (.A(A[i]), .B(B[i]), .cntrl, .out(result[i]), .Cin(C[i]), .Cout(C[i+1]));
//		end
//	endgenerate
//	
//	alu_1bit last_alu (.A(A[63]), .B(B[63]), .cntrl(cntrl[2:0]), .out(result[63]), .Cin(C[63]), .Cout(carry_out));
	

// Carry look ahead ALU
	logic [64:0] C;
	logic [63:0] G, P;
	logic [63:0] newB;
	logic [63:0] w;
	genvar i;
   generate
		for (i = 0; i < 64; i = i + 1) begin: gates
			xor #5 (newB[i], cntrl[0], B[i]); // invert if subtraction
			and #5 (G[i], A[i], newB[i]);
			xor #5 (P[i], A[i], newB[i]);
		end
	endgenerate
	assign C[0] = cntrl[0];
	generate
		for (i=0; i < 64; i=i+1) begin: carries
			and #5 (w[i], P[i], C[i]);
			or #5 (C[i+1], w[i], G[i]);
		end
	endgenerate
	
   generate
        for (i = 0; i < 64; i = i + 1) begin : alu
            alu_1bit alu (.A(A[i]), .B(B[i]), .cntrl(cntrl), .out(result[i]), .Cin(C[i]), .Cout());
        end
   endgenerate
	

	//Flags
	assign carry_out = C[64];
	zero_detector z (.in(result), .zero(zero)); //check if result is 0
	assign negative = result[63]; //if negative, msb will be 1
	xor #5 (overflow, C[63], carry_out); //xor cin and cout of msb
endmodule
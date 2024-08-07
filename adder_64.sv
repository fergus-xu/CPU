`timescale 10ps/1fs
module adder_64bit(A, B, Cin, sum, Cout); //64 bit adder/subtractor
	input logic [63:0] A, B;
	input logic Cin;
	output logic [63:0] sum;
	output logic Cout;
	logic op;
	
	logic [64:0] C;
	logic [63:0] G, P;
	logic [63:0] w;
	
	//carry look ahead
	genvar i;
   generate
		for (i = 0; i < 64; i = i + 1) begin: gates
			and #5 (G[i], A[i], B[i]);
			xor #5 (P[i], A[i], B[i]);
		end
	endgenerate
	assign C[0] = Cin;
	generate
		for (i=0; i < 64; i=i+1) begin: carries
			and #5 (w[i], P[i], C[i]);
			or #5 (C[i+1], w[i], G[i]);
		end
	endgenerate
	
	generate
        for (i = 0; i < 64; i = i + 1) begin : adder
            adder_1bit adder (.A(A[i]), .B(B[i]), .Cin(C[i]), .sum(sum[i]), .Cout());
        end
   endgenerate
	assign Cout = C[64];

endmodule
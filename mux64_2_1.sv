module mux64_2_1(in0, in1, sel, out);
	input logic [63:0] in0, in1;
	input logic sel;
	output logic [63:0] out;
	
	genvar i;
	generate
		for (i=0; i < 64; i=i+1) begin: muxes
			mux2_1 m (in0[i], in1[i], sel, out[i]);
		end
	endgenerate
endmodule
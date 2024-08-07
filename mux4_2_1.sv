module mux4_2_1(in0, in1, sel, out);
	input logic [3:0] in0, in1;
	output logic [3:0] out;
	input logic sel;
	
	genvar i;
	generate
		for (i=0; i < 4; i=i+1) begin: muxes
			mux2_1 m (in0[i], in1[i], sel, out[i]);
		end
	endgenerate
endmodule
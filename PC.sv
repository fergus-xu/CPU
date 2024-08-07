module PC(in, out, clk, reset, en);
	input logic [63:0] in;
	input logic clk, reset, en;
	output logic [63:0] out;
	
	genvar j;
	generate
		for (j = 0; j < 64; j = j + 1) begin: DFF	
			D_FF_en ff (.q(out[j]), .d(in[j]), .clk(clk), .en(en), .reset(reset)); 
		end
	endgenerate
endmodule
module registers #(parameter WIDTH = 64) (in, out, enable, reset, clk);
	input logic [WIDTH - 1:0] in;
	input logic enable, reset, clk;
	output logic [WIDTH - 1:0] out;
	genvar i;
	generate
		for (i = 0; i < WIDTH; i = i + 1) begin: DFF	
			D_FF_en ff (.q(out[i]), .d(in[i]), .clk(clk), .en(enable), .reset(reset)); 
		end
	endgenerate
endmodule
`timescale 10ps/1fs
module mux4_1(in, sel, out);
	input logic [3:0] in;
	input logic [1:0] sel;
	output logic out;

	wire [1:0] w;
	
	mux2_1 mux0 (in[0], in[1], sel[0], w[0]);
	mux2_1 mux1 (in[2], in[3], sel[0], w[1]);
	mux2_1 mux2 (w[0], w[1], sel[1], out);
endmodule


module mux4_1_testbench();
	logic [3:0] in;
	logic [1:0] sel;
	logic out;
	
	mux4_1 mux0	(in, sel, out);
	
	initial begin
		in = 4'b0000; sel = 2'b00;
		for (int i = 0; i <= 4'b1111; i = i + 1) begin
			in = i;
			for (int j = 0; j <= 2'b11; j = j + 1) begin
				sel = j;
				#100;
			end
		end
		$stop;
	end
endmodule
`timescale 10ps/1fs
module mux16_1(in, sel, out);
	input logic [15:0] in;
	input logic [3:0] sel;
	output logic out;
	
	wire [1:0] w;
	
	mux8_1 mux0 (in[7:0], sel[2:0], w[0]);
	mux8_1 mux1 (in[15:8], sel[2:0], w[1]);
	mux2_1 mux2 (w[0], w[1], sel[3], out);

endmodule

module mux16_1_testbench();
	logic [15:0] in;
	logic [3:0] sel;
	logic out;
	
	mux4_1 mux0	(in, sel, out);
	
	initial begin
		in = 16'b0000000000000000; sel = 4'b0000;
		for (int i = 0; i <= 16'b1111111111111111; i = i + 1) begin
			in = i;
			for (int j = 0; j <= 4'b1111; j = j + 1) begin
				sel = j;
				#100;
			end
		end
		$stop;
	end
endmodule
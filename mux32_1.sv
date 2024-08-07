`timescale 10ps/1fs
module mux32_1(in, sel, out);
	input logic [31:0] in;
	input logic [4:0] sel;
	output logic out;
	
	wire [1:0] w;
	
	mux16_1 mux0 (in[15:0], sel[3:0], w[0]);
	mux16_1 mux1 (in[31:16], sel[3:0], w[1]);
	mux2_1 mux2 (w[0], w[1], sel[4], out);

endmodule

module mux32_1_testbench();
	logic [31:0] in;
	logic [4:0] sel;
	logic out;
	
	mux4_1 mux0	(in, sel, out);
	
	initial begin
		in = 32'b00000000000000000000000000000000; sel = 5'b00000;
		for (int i = 0; i <= 32'b11111111111111111111111111111111; i = i + 1) begin
			in = i;
			for (int j = 0; j <= 5'b11111; j = j + 1) begin
				sel = j;
				#100;
			end
		end
		$stop;
	end
endmodule
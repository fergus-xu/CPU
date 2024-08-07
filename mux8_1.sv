`timescale 10ps/1fs
module mux8_1(in, sel, out);
	input logic [7:0] in;
	input logic [2:0] sel;
	output logic out;
	
	wire [1:0] w;
	
	mux4_1 mux0 (in[3:0], sel[1:0], w[0]);
	mux4_1 mux1 (in[7:4], sel[1:0], w[1]);
	mux2_1 mux2 (w[0], w[1], sel[2], out);

endmodule

module mux8_1_testbench();
	logic [7:0] in;
	logic [2:0] sel;
	logic out;
	
	mux4_1 mux0	(in, sel, out);
	
	initial begin
		in = 8'b00000000; sel = 3'b000;
		for (int i = 0; i <= 8'b11111111; i = i + 1) begin
			in = i;
			for (int j = 0; j <= 3'b111; j = j + 1) begin
				sel = j;
				#100;
			end
		end
		$stop;
	end
endmodule
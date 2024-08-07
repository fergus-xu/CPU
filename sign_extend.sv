module signExtend #(parameter WIDTH = 9) (instruction, out);
	input logic [WIDTH-1:0] instruction;
	output logic [63:0] out;
	
	integer i;
	always_comb begin
		for(int i = 0; i < WIDTH; i++)
			out[i] = instruction[i];
		for(int i = WIDTH; i < 64; i++)
			out[i] = instruction[WIDTH-1];
	end
endmodule

module zeroExtend #(parameter WIDTH = 9) (instruction, out);
	input logic [WIDTH-1:0] instruction;
	output logic [63:0] out;
	
	integer i;
	always_comb begin
		for(int i = 0; i < WIDTH; i++)
			out[i] = instruction[i];
		for(int i = WIDTH; i < 64; i++)
			out[i] = 1'b0;
	end
endmodule

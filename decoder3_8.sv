`timescale 10ps/1fs
module decoder3_8(in, enable, out);
	input logic [2:0] in;
	input logic enable;
	output logic [7:0] out;
	
	wire [2:0] neg;

	not #5 (neg[0], in[0]);
	not #5 (neg[1], in[1]);
	not #5 (neg[2], in[2]);
	
	and #5 (out[0], enable, neg[2], neg[1], neg[0]);
	and #5 (out[1], enable, neg[2], neg[1], in[0]);
	and #5 (out[2], enable, neg[2], in[1], neg[0]);
	and #5 (out[3], enable, neg[2], in[1], in[0]);
	and #5 (out[4], enable, in[2], neg[1], neg[0]);
	and #5 (out[5], enable, in[2], neg[1], in[0]);
	and #5 (out[6], enable, in[2], in[1], neg[0]);
	and #5 (out[7], enable, in[2], in[1], in[0]);

endmodule

module testbench3_8();
	logic [2:0] in;
	logic enable;
	logic [7:0] out;
	
	decoder3_8 dec (.in, .enable, .out);
	
	initial begin
		in = 3'b000; enable = 1'b0; #100;
		
		for (int i = 0; i < 8; i = i+1) begin
			enable = 1'b0;
			in = i;
			#100;
			
			enable = 1'b1;
			#100;
		end
		$finish;
	end
endmodule

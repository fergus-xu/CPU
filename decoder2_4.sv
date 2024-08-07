`timescale 10ps/1fs
module decoder2_4(in, enable, out);
	input logic [1:0] in;
	input logic enable;
	output logic [3:0] out;
	
	wire [1:0] neg;
	
	not #5 (neg[0], in[0]);
	not #5 (neg[1], in[1]);
	and #5 (out[0], enable, neg[0], neg[1]);
	and #5 (out[1], enable, neg[1], in[0]);
	and #5 (out[2], enable, in[1], neg[0]);
	and #5(out[3], enable, in[1], in[0]);
	

endmodule

module testbench2_4();
	logic [1:0] in;
	logic enable;
	logic [3:0] out;
	
	decoder2_4 dec (.in, .enable, .out);
	
	initial begin 
		in[0] = 0; in[1] = 0; enable = 0; #100;
		enable = 1; #100;
		in[0] = 0; in[1] = 1; enable = 0; #100;
		enable = 1; #100;
		in[0] = 1; in[1] = 0; enable = 0; #100;
		enable = 1; #100;
		in[0] = 1; in[1] = 1; enable = 0; #100;
		enable = 1; #100;
		$finish;
	end
endmodule


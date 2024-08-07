`timescale 10ps/1fs
module mux2_1(i0, i1, sel, out);
	input logic i0, i1;
	input logic sel;
	output logic out;
	
	wire w [2:0];
	
	not #5 (w[2], sel);
	and #5 (w[0], i0, w[2]);
	and #5 (w[1], i1, sel);
	or #5 (out, w[0], w[1]);
	
endmodule

module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;
	mux2_1 dut (.out, .i0, .i1, .sel);
	initial begin
		sel=0; i0=0; i1=0; #10;
		sel=0; i0=0; i1=1; #10;
		sel=0; i0=1; i1=0; #10;
		sel=0; i0=1; i1=1; #10;
		sel=1; i0=0; i1=0; #10;
		sel=1; i0=0; i1=1; #10;
		sel=1; i0=1; i1=0; #10;
		sel=1; i0=1; i1=1; #10;
		$stop;
	end
endmodule
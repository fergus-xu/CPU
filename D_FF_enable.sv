`timescale 10ps/1fs
module D_FF_en (q, d, clk, en, reset);
	output reg q;
	input d, clk;
	input logic en, reset;
	
	logic w;

	mux2_1 mux0 (q, d, en, w); //if enable, choose d, else hold q using 2:1 mux
	
	D_FF ff (q, w, reset, clk); //read input from mux
	
endmodule

module D_FF_en_testbench();
	reg q;
	logic d, clk;
	logic en;
	
	D_FF_en ff (q, d, clk, en);
	
	initial begin
		//setup clock
		clk = 0;
      forever #5 clk = ~clk;
	end
	
	initial begin
		d = 0; en = 0;
		#10 d = 1; en = 1;  
		#10 d = 0;
		#10 en = 0;
		#10 d = 1;
		#10 en = 1;
		#10 d = 0;
		#10;
		$stop;
	end
endmodule
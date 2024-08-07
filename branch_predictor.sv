//let 1 represent branch taken, 0 represent not taken
module branch_predictor(clk, branch, reset, pred);
	input logic clk, branch, reset;
	output logic pred;
	
	logic [1:0] state;
	
	//2 bit tracker
	// change to enables so that is only updated when a prediction is needed
	D_FF t1 (.q(state[1]), .d(branch), .reset(reset), .clk(clk));
	D_FF t2 (.q(state[0]), .d(state[1]), .reset(reset), .clk(clk));
	
	mux4_1 selPred (.in(4'b0101), .sel(state), .out(pred));
endmodule
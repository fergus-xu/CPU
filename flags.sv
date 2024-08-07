module flags(zero, negative, overflow, carryout, setFlags, clk, reset, zeroFlag, negativeFlag, overflowFlag, carryoutFlag);
	input logic zero, negative, overflow, carryout;
	input logic setFlags, clk, reset;
	output logic zeroFlag, negativeFlag, overflowFlag, carryoutFlag;
	
	D_FF_en zeroReg (zeroFlag, zero, clk, setFlags, reset);
	D_FF_en negativeReg (negativeFlag, negative, clk, setFlags, reset);
	D_FF_en overflowReg (overflowFlag, overflow, clk, setFlags, reset);
	D_FF_en carryoutReg (carryoutFlag, carryout, clk, setFlags, reset);

endmodule
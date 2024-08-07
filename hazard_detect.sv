// Outputs
// PCWrite - assert to pause PC value
// IFIDWrite - assert to pause IFID pipeline
// controlOff - assert to set all control values to 0
// IFFlush

module hazard_detect(IDEXMemRead, actual_branch, iszero, IDEXRd, IFIDRn, IFIDRm, PCWrite, IFIDWrite, controlOff, IFFlush);
	input logic IDEXMemRead, actual_branch, iszero;
	input logic [4:0] IDEXRd, IFIDRn, IFIDRm;
	output logic PCWrite, IFIDWrite, controlOff, IFFlush;
	
	always_comb begin
		
		if ((IDEXMemRead) & ((IDEXRd == IFIDRn) | (IDEXRd == IFIDRm))) begin //if hazard
			PCWrite = 1'b0;
			IFIDWrite = 1'b0;
			controlOff = 1'b1;
		end else begin //normally
			PCWrite = 1'b1;
			IFIDWrite = 1'b1;
			controlOff = 1'b0;
		end
		
		if (actual_branch) begin
			IFFlush = 1;
		end else
			IFFlush = 0;
		end
	
endmodule

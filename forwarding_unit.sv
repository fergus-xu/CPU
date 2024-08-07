	//Cases
//00: From register
//10: From prior ALU result
//01: From datamem or a prior alu result


module forwarding_unit(EXMEMRegWrite, MEMWBRegWrite, EXMEMRd, IDEXRn, IDEXRm, MEMWBRd, IDEXRd, IDEXRm,
							  IFIDRm, ALUSrc, ForwardA, ForwardB, forwardBR, BR, MEMMemWrite, forwardData);
	input logic EXMEMRegWrite, MEMWBRegWrite, MEMMemWrite;
	input logic [4:0] EXMEMRd, IDEXRn, IDEXRm, MEMWBRd, IDEXRd, IFIDRm;
	input logic ALUSrc, BR;
	output logic [1:0] ForwardA, ForwardB, forwardBR, forwardData;
	
	
	always_comb begin
		// EX hazard
		if ((EXMEMRegWrite) & (EXMEMRd != 5'b11111) & (EXMEMRd == IDEXRn)) begin
			ForwardA = 2'b10;
		end 
		// MEM hazard
		else if ((MEMWBRegWrite) & (MEMWBRd != 5'b11111) & (EXMEMRd != 5'b11111) & 
			(EXMEMRd != IDEXRn) & (MEMWBRd == IDEXRn)) begin
			ForwardA = 2'b01;
		end else if ((EXMEMRegWrite) & (MEMWBRd != 5'b11111) & (IDEXRn == MEMWBRd)) begin
			ForwardA = 2'b11;
		end else begin
			ForwardA = 2'b00;
		end
		
		//EX hazard
		if ((EXMEMRegWrite) & (EXMEMRd != 5'b11111) & (EXMEMRd == IDEXRm) &(!ALUSrc)) begin
			ForwardB = 2'b10;
		end  
		// Mem hazard
		else if ((MEMWBRegWrite) & (MEMWBRd != 5'b11111) & (EXMEMRd != 5'b11111) & 
			(EXMEMRd != IDEXRm) & (MEMWBRd == IDEXRm) & !(ALUSrc)) begin
			ForwardB = 2'b01;
		end else begin
			ForwardB = 2'b00;
		end
		
		//BR
		if ((EXMEMRd != 5'b11111) & (IFIDRm == IDEXRd) & (BR)) begin
			forwardBR = 2'b10;
		end else if ((MEMWBRegWrite) & (MEMWBRd != 5'b11111) & (EXMEMRd != 5'b11111) & 
			(EXMEMRd != IDEXRm) & (MEMWBRd == IFIDRm) & (BR)) begin
			forwardBR = 2'b01;
		end else if (BR) begin
			forwardBR = 2'b11;
		end else begin
			forwardBR = 2'b00;
		end
		
		
		if ((EXMEMRd == MEMWBRd) & (MEMMemWrite) & (EXMEMRd != 5'b11111)) begin
			forwardData = 2'b10;
		end else if ((MEMMemWrite) & (MEMWBRd == IDEXRd) & (MEMWBRd != 5'b11111)) begin
			forwardData = 2'b01;
		end else begin
			forwardData = 2'b00;
		end
	end
endmodule
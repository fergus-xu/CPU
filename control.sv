`timescale 10ps/1fs
module control(instruction, Reg2Loc, Branch, Uncondbranch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, 
					zero, negativeFlag, overflowFlag, setFlags, xfer_size, BR, BL, controloff);
	input logic [31:0] instruction;
	input logic controloff;
	output logic Reg2Loc, ALUSrc, MemtoReg;
	output logic RegWrite, MemRead, MemWrite;
	output logic Branch, Uncondbranch;
	output logic setFlags;
	output logic [1:0] ALUOp;
	input logic zero, negativeFlag, overflowFlag;
	output logic BR, BL;
	output logic [3:0] xfer_size;
	
	logic negCheck;
	xor #5 checkNeg (negCheck, negativeFlag, overflowFlag);
	
	always_comb begin
		case (controloff)
			1'b0: begin
				casex (instruction[31:21]) 
					default: begin
						Reg2Loc = 0;
						ALUSrc = 0;
						MemtoReg = 0;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 0;
						Branch = 0;
						Uncondbranch = 1'b0;
						ALUOp = 2'b00;
						setFlags = 0;
						xfer_size = 4'b0000;
						BR = 0;
						BL = 0;
					end
					11'b1001000100x: begin// ADDI
						Reg2Loc = 1;
						ALUSrc = 1;
						MemtoReg = 0;
						RegWrite = 1;
						MemRead = 0;
						MemWrite = 0;
						Branch = 0;
						Uncondbranch = 1'b0;
						ALUOp = 2'b10;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b1101000100x: begin// SUBI
						Reg2Loc = 1;
						ALUSrc = 1;
						MemtoReg = 0;
						RegWrite = 1;
						MemRead = 0;
						MemWrite = 0;
						Branch = 0;
						Uncondbranch = 1'b0;
						ALUOp = 2'b10;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b10101011000: begin// ADDS
						Reg2Loc = 0;
						ALUSrc = 0;
						MemtoReg = 0;
						RegWrite = 1;
						MemRead = 0;
						MemWrite = 0;
						Branch = 0; 
						Uncondbranch = 1'b0;
						ALUOp = 2'b10;
						setFlags = 1;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b11101011000: begin// SUBS
						Reg2Loc = 0;
						ALUSrc = 0;
						MemtoReg = 0;
						RegWrite = 1;
						MemRead = 0;
						MemWrite = 0;
						Branch = 0; 
						Uncondbranch = 1'b0;
						ALUOp = 2'b10;
						setFlags = 1;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b000101xxxxx: begin// B
						Reg2Loc = 1'bx;
						ALUSrc = 1'bx;
						MemtoReg = 1'bx;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 0;
						Uncondbranch = 1;
						Branch = 1; 
						ALUOp = 2'bxx;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b10110100xxx: begin// CBZ
						Reg2Loc = 1;
						ALUSrc = 0;
						MemtoReg = 1'b0;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 0;
						Branch = zero;
						Uncondbranch = 0;
						ALUOp = 2'b01;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b01010100xxx: begin// B.cond
						Reg2Loc = 1'b0;
						ALUSrc = 1'b0;
						MemtoReg = 1'b0;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 0;
						Branch = negCheck; 
						Uncondbranch = 0;
						ALUOp = 2'bxx;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b11111000010: begin// LDUR
						Reg2Loc = 1'bx;
						ALUSrc = 1;
						MemtoReg = 1;
						RegWrite = 1;
						MemRead = 1;
						MemWrite = 0;
						Branch = 0;
						Uncondbranch = 0;
						ALUOp = 2'b00;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b11111000000: begin// STUR
						Reg2Loc = 1;
						ALUSrc = 1;
						MemtoReg = 1'bx;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 1;
						Branch = 0;
						Uncondbranch = 0;
						ALUOp = 2'b00;
						setFlags = 0;
						xfer_size = 4'b1000;
						BR = 0;
						BL = 0;
					end
					11'b100101xxxxx: begin// BL
						Reg2Loc = 1'bx;
						ALUSrc = 1'bx;
						MemtoReg = 1'bx;
						RegWrite = 1;
						MemRead = 0;
						MemWrite = 0;
						Uncondbranch = 1;
						Branch = 1; 
						ALUOp = 2'bxx;
						setFlags = 0;
						BR = 0;
						BL = 1;
					end
					11'b11010110000: begin// BR
						Reg2Loc = 1'b1;
						ALUSrc = 1'bx;
						MemtoReg = 1'bx;
						RegWrite = 0;
						MemRead = 0;
						MemWrite = 0;
						Uncondbranch = 1;
						Branch = 1; 
						ALUOp = 2'bxx;
						setFlags = 0;
						BR = 1;
						BL = 0;
					end
				endcase
			end
			1'b1: begin
				Reg2Loc = 0;
				ALUSrc = 0;
				MemtoReg = 0;
				RegWrite = 0;
				MemRead = 0;
				MemWrite = 0;
				Branch = 0;
				Uncondbranch = 0;
				ALUOp = 2'b00;
				setFlags = 0;
				xfer_size = 4'b0000;
				BR = 0;
				BL = 0;
			end
		endcase
	end
			
			
			
//			
			
endmodule

//ALUSrc determines whether it is ADD or ADDI by changing the input from register to sign extend
//should follow the table, have I type as a subset of R type probably
	
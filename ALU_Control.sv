// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

//ALUOp:
//00: LDUR/STUR -> 010
//01:	CBZ -> 000
//10: R/I -> depends on op code
//11: dont care
//B: not important
`timescale 10ps/1fs
module ALU_control(ALUOp, ins, op);
	input logic [1:0] ALUOp;
	input logic [31:21] ins;
	output logic [2:0] op;

	always_comb begin
		case (ALUOp) 
			2'b10: begin
				casex(ins[31:21])
					default: op = 3'bzzz;
					11'b10001011000: op = 3'b010; //ADD
					11'b10101011000: op = 3'b010; //ADDS
					11'b1001000100x: op = 3'b010; //ADDI
					11'b1011000100x: op = 3'b010; //ADDIS
					
					11'b11001011000: op = 3'b011; //SUB
					11'b11101011000: op = 3'b011; //SUBS
					11'b1101000100x: op = 3'b011; //SUBI
					11'b1111000100x: op = 3'b011; //SUBIS
					
					11'b11001010000: op = 3'b110; //EOR
					11'b1101001000x: op = 3'b110; //EORI
					
					11'b10101010000: op = 3'b101; //ORR
					11'b1011001000x: op = 3'b101; //ORRI
					
					11'b10001010000: op = 3'b100; //AND
					11'b1001001000x: op = 3'b100; //ANDI
					
				endcase
			end
			2'b00: op = 3'b010;
			2'b01: op = 3'b000;
			default: op = 3'bzzz;
		endcase
	end
	
endmodule

module ALU_control_testbench();
	logic [1:0] ALUOp;
	logic [31:21] ins;
	logic [2:0] op;
	
	ALU_control control (ALUOp, ins, op);
	
	initial begin
		ALUOp = 2'b00; ins = 11'b0; //check behavior when ALUOp = 00 (D type)
		for (int i = 0; i < 11'b1111111111; i=i+1) begin
			ins=i;
			#5;
		end
		ALUOp = 2'b01; //check behavior when ALUOp = 01 (CBZ)
		for (int i = 0; i < 11'b1111111111; i=i+1) begin
			ins=i;
			#5;
		end
		ALUOp = 2'b10; //iterate through normal alu operations
		ins = 11'b10001011000; #10;
		ins = 11'b11001011000; #10;
		ins = 11'b10001010000; #10;
		ins = 11'b10101010000; #10;
		ins = 11'b11001010000; #10;
	end
endmodule
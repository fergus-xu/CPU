`timescale 10ps/1fs
module cpu(clk, reset);
	input logic clk, reset;
	// Control Unit
	logic [4:0] WriteRegister;
	logic IDBL, IDBR;
	logic [63:0] IFplus4, WriteData, newAddress, pcIn;

	// IF
	logic w[2:0];
	logic [63:0] IFaddress;
	logic PCWrite;
	logic [31:0] IFinstruction;

	// IF ID
	logic IFIDWrite, IFFlush;
	logic [63:0] IDaddress;
	logic [31:0] IDinstruction;

	// ID
	logic [63:0] extD;
	logic [63:0] IDplus4;
	logic [63:0] extI;
	logic [63:0] ext;
	logic [63:0] addCB;
	logic [63:0] addB;
	logic Uncondbranch;
	logic [63:0] preShift, shiftTwo, IDplusShift;
	logic [4:0] IDRn, IDRd, IDRm, Rd;
	logic Reg2Loc;
	logic [63:0] IDReadData1, IDReadData2;
	logic Reg2zero, negCheck;
	logic IDBranch, IDUncondbranch, IDMemRead, IDMemtoReg, IDMemWrite, IDALUSrc, IDRegWrite;
	logic [1:0] IDALUOp;
	logic EXnegative, EXoverflow, IDsetFlags;
	logic [3:0] IDxfer_size;
	logic controloff;

	// IDEX
	logic [1:0] EXALUOp;
	logic EXALUSrc, EXBranch, EXMemRead, EXMemWrite, EXUncondbranch;
	logic [2:0] EXcntrl, IDcntrl;
	logic [3:0] EXxfer_size;
	logic EXsetFlags, EXRegWrite, EXMemtoReg, Exnegative, Exoverflow;
	logic [63:0] EXReadData1, EXReadData2, EXext;
	logic [4:0] EXRn, EXRm, EXRd;
	logic EXBL;
	logic [63:0] EXplus4;

	// EX
	logic [63:0] preB;
	logic [1:0] ForwardA, ForwardB;
	logic [63:0] A, B;
	logic [63:0] EXaluResult;
	logic EXzero, EXcarryout;
	logic zeroFlag, negativeFlag, overflowFlag, carryoutFlag;

	// Forwarding Unit
	logic MEMRegWrite, WBRegWrite;
	logic [4:0] MEMRd, WBRd;
	logic ALUSrc;

	// EXMEM
	logic [63:0] MEMRead2, MEMaluResult;
	logic MEMBL;
	logic [63:0] MEMplus4;

	// MEM
	logic MEMMemRead, MEMMemWrite, MEMMemtoReg, MEMBranch, MEMUncondbranch;
	logic [3:0] MEMxfer_size;
	logic [63:0] MEMdataMemOut;

	// MEMWB
	logic WBMemtoReg;
	logic [63:0] WBdataMemOut, WBaluResult, WBWriteData;
	logic [63:0] WBplus4;
	logic WBBL;
	
	logic [1:0] forwardBR, forwardData;
	logic [63:0] write_data;
	
	
	//IF
	mux64_4_1 selBR (.in({IDReadData2, EXaluResult, MEMRead2, newAddress}), .sel(forwardBR), .out(pcIn));
	mux64_2_1 selAddress (.in0(IFplus4), .in1(IDplusShift), .sel(w[2]), .out(newAddress));
	
	PC pc (.in(pcIn), .out(IFaddress), .clk(clk), .reset(reset), .en(PCWrite));
	
	instructmem mem (.address(IFaddress), .instruction(IFinstruction), .clk(clk));
	
	adder_64bit add4 (.A(IFaddress), .B(64'b100), .Cin(1'b0), .sum(IFplus4), .Cout());
	
	//IF ID
	registers #(.WIDTH(64)) IFIDaddress (.in(IFaddress), .out(IDaddress), .enable(IFIDWrite), .reset(IFFlush), .clk(clk));
	registers #(.WIDTH(32)) IFIDinstruction (.in(IFinstruction), .out(IDinstruction), .enable(IFIDWrite), .reset(IFFlush), .clk(clk));
	registers #(.WIDTH(64)) IFIDplus4 (.in(IFplus4), .out(IDplus4), .enable(1'b1), .reset(), .clk(clk));
	
	//ID
	
	//sign extensions
	signExtend #(.WIDTH(9)) extDtype (.instruction(IDinstruction[20:12]), .out(extD));
	zeroExtend #(.WIDTH(12)) extImm (.instruction(IDinstruction[21:10]), .out(extI));
	mux64_2_1 selExtend (.in0(extI), .in1(extD), .sel(IDinstruction[27]), .out(ext));
	signExtend #(.WIDTH(19)) extCB (.instruction(IDinstruction[23:5]), .out(addCB)); 
	signExtend #(.WIDTH(26)) extB (.instruction(IDinstruction[25:0]), .out(addB));
	
	//add branch prediction
	
	//Branch Shifting
	mux64_2_1 selShift (.in0(addCB), .in1(addB), .sel(IDUncondbranch), .out(preShift)); //select with sign extension
		
	shifter shift (.value(preShift), .direction(1'b0), .distance(6'b10), .result(shiftTwo)); //shifts by 2
	
	adder_64bit addShift (.A(IDaddress), .B(shiftTwo), .Cin(1'b0), .sum(IDplusShift), .Cout());
	
	assign IDRn = IDinstruction[9:5];
	assign Rd = IDinstruction[4:0];
	mux5_2_1 selReg2 (.in0(IDinstruction[20:16]), .in1(IDinstruction[4:0]), .sel(Reg2Loc), .out(IDRm)); // select register 2
	mux5_2_1 selRd (.in0(Rd), .in1(5'b11110), .sel(IDBL), .out(IDRd));
	
	//Registers
	regfile registers (.ReadData1(IDReadData1), .ReadData2(IDReadData2), .WriteData(WriteData), 
					.ReadRegister1(IDRn), .ReadRegister2(IDRm), .WriteRegister(WBRd),
					.RegWrite(WBRegWrite), .clk(clk));
					
	zero_detector checkReg2 (.in(IDReadData2), .zero(Reg2zero));
	//add zero check here update
	or #5 w0 (w[0], Reg2zero, negCheck);
	and #5 w1 (w[1], IDBranch, w[0]);
	or #5 w2 (w[2], IDUncondbranch, w[1]);
	
	//Hazard Detection
	hazard_detect hazards (.IDEXMemRead(EXMemRead), .actual_branch(w[2]), .iszero(Reg2zero), .IDEXRd(EXRd), .IFIDRn(IDRn), .IFIDRm(IDRm),
					  .PCWrite(PCWrite), .IFIDWrite(IFIDWrite), .controlOff(controloff), .IFFlush(IFFlush));
	
	//Control
	control cpuControl (.instruction(IDinstruction), .Reg2Loc(Reg2Loc), .Branch(IDBranch), .Uncondbranch(IDUncondbranch), 
							  .MemRead(IDMemRead), .MemtoReg(IDMemtoReg), .ALUOp(IDALUOp), .MemWrite(IDMemWrite), .ALUSrc(IDALUSrc), 
							  .RegWrite(IDRegWrite), .zero(Reg2zero), .negativeFlag(EXnegative), .overflowFlag(EXoverflow), 
							  .setFlags(IDsetFlags), .xfer_size(IDxfer_size), .BR(IDBR), .BL(IDBL), .controloff(controloff));
	ALU_control aluControl (.ALUOp(IDALUOp), .ins(IDinstruction[31:21]), .op(IDcntrl));
	//add control off
	
	
	//IDEX
	registers #(.WIDTH(1)) IDEXRegWrite (.in(IDRegWrite), .out(EXRegWrite), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXMemtoReg (.in(IDMemtoReg), .out(EXMemtoReg), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(2)) IDEXALUOp (.in(IDALUOp), .out(EXALUOp), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXALUSrc (.in(IDALUSrc), .out(EXALUSrc), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXBranch (.in(IDBranch), .out(EXBranch), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXMemRead (.in(IDMemRead), .out(EXMemRead), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXMEmWrite (.in(IDMemWrite), .out(EXMemWrite), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXUncondbranch (.in(IDUncondbranch), .out(EXUncondbranch), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(3)) IDEXcntrl (.in(IDcntrl), .out(EXcntrl), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(4)) IDEXxfer (.in(IDxfer_size), .out(EXxfer_size), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXsetFlags (.in(IDsetFlags), .out(EXsetFlags), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) IDEXBL (.in(IDBL), .out(EXBL), .enable(1'b1), .reset(), .clk(clk));
	
	registers #(.WIDTH(64)) IDEXReg1 (.in(IDReadData1), .out(EXReadData1), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) IDEXReg2 (.in(IDReadData2), .out(EXReadData2), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) IDEXSE (.in(ext), .out(EXext), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) IDEXplus4 (.in(IDplus4), .out(EXplus4), .enable(1'b1), .reset(), .clk(clk));
	
	registers #(.WIDTH(5)) IDEXRn (.in(IDRn), .out(EXRn), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(5)) IDEXRm (.in(IDRm), .out(EXRm), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(5)) IDEXRd (.in(IDRd), .out(EXRd), .enable(1'b1), .reset(), .clk(clk));

					
	
	//EX
	mux64_4_1 selA (.in({WriteData, MEMaluResult, WriteData, EXReadData1}), .sel(ForwardA), .out(A));
	mux64_4_1 selB (.in({64'b0, MEMaluResult, WriteData, EXReadData2}), .sel(ForwardB), .out(preB));
	
	mux64_2_1 selextB (.in0(preB), .in1(EXext), .sel(EXALUSrc), .out(B)); // select input B to ALU
	
	alu ALU (.A(A), .B(B), .cntrl(EXcntrl), .result(EXaluResult), .negative(EXnegative), 
				.zero(EXzero), .overflow(EXoverflow), .carry_out(EXcarryout));
	
	flags flag (.zero(EXzero), .negative(EXnegative), .overflow(EXoverflow), .carryout(EXcarryout), .setFlags(EXsetFlags), 
					.clk(clk), .reset(reset), .zeroFlag(zeroFlag), .negativeFlag(negativeFlag), 
					.overflowFlag(overflowFlag), .carryoutFlag(carryoutFlag));
	
	xor #5 checkNeg (negCheck, EXnegative, EXoverflow);
	
	forwarding_unit forward (.EXMEMRegWrite(MEMRegWrite), .MEMWBRegWrite(WBRegWrite), .EXMEMRd(MEMRd), .IDEXRn(EXRn),
						 .IDEXRm(EXRm), .MEMWBRd(WBRd), .IDEXRd(EXRd), .IFIDRm(IDRm), .ALUSrc(EXALUSrc), .ForwardA(ForwardA), 
						 .ForwardB(ForwardB), .forwardBR(forwardBR), .BR(IDBR), .MEMMemWrite(MEMMemWrite), .forwardData(forwardData));
						 
	
	//EXMEM
	registers #(.WIDTH(64)) EXMEMRead2 (.in(preB), .out(MEMRead2), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) EXMEMResult (.in(EXaluResult), .out(MEMaluResult), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) EXMEMplus4 (.in(EXplus4), .out(MEMplus4), .enable(1'b1), .reset(), .clk(clk));
	
	registers #(.WIDTH(5)) EXMEMRd (.in(EXRd), .out(MEMRd), .enable(1'b1), .reset(), .clk(clk));
	
	registers #(.WIDTH(1)) EXMEMRegWrite (.in(EXRegWrite), .out(MEMRegWrite), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMMemtoReg (.in(EXMemtoReg), .out(MEMMemtoReg), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMBranch (.in(EXBranch), .out(MEMBranch), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMMemRead (.in(EXMemRead), .out(MEMMemRead), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMMemWrite (.in(EXMemWrite), .out(MEMMemWrite), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMUncondbranch (.in(EXUncondbranch), .out(MEMUncondbranch), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(4)) EXMEMxfer (.in(EXxfer_size), .out(MEMxfer_size), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) EXMEMBL (.in(EXBL), .out(MEMBL), .enable(1'b1), .reset(), .clk(clk));
	
	
	//MEM
	mux64_4_1 datamemMux (.in({64'b0, WBaluResult, WriteData, MEMRead2}), .sel(forwardData), .out(write_data));
	datamem datamem (.address(MEMaluResult), .write_enable(MEMMemWrite), .read_enable(MEMMemRead),
						  .write_data(write_data), .clk(clk), .xfer_size(MEMxfer_size), .read_data(MEMdataMemOut));
						  
	//MEMWB
	registers #(.WIDTH(1)) MEMWBRegWrite (.in(MEMRegWrite), .out(WBRegWrite), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) MEMWBMemtoReg (.in(MEMMemtoReg), .out(WBMemtoReg), .enable(1'b1), .reset(), .clk(clk));
	
	registers #(.WIDTH(64)) MEMWBdataMemOut (.in(MEMdataMemOut), .out(WBdataMemOut), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) MEMWBresult (.in(MEMaluResult), .out(WBaluResult), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(64)) MEMWBplus4 (.in(MEMplus4), .out(WBplus4), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(5)) MEMWBRd (.in(MEMRd), .out(WBRd), .enable(1'b1), .reset(), .clk(clk));
	registers #(.WIDTH(1)) MEMWBBL (.in(MEMBL), .out(WBBL), .enable(1'b1), .reset(), .clk(clk));
	
	
	//WB
	mux64_2_1 selWriteData (.in0(WBaluResult), .in1(WBdataMemOut), .sel(WBMemtoReg), .out(WBWriteData));
	mux64_2_1 writeBL (.in0(WBWriteData), .in1(WBplus4), .sel(WBBL), .out(WriteData));

endmodule

module cpu_testbench;
	logic clk, reset;

	cpu cpu (.clk, .reset); 
	parameter ClockDelay = 1000;
	integer i;
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);

		while(cpu.IFinstruction[31:0] != 32'b00010100000000000000000000000000) begin
			@(posedge clk);
		end
		//finish out the pipeline
		
		for (i = 0; i < 4; i = i + 1) begin
			 @(posedge clk);
		end
		$display("end reached");
		$stop;
	end
endmodule

module regfile(ReadData1, ReadData2, WriteData, 
					ReadRegister1, ReadRegister2, WriteRegister,
					RegWrite, clk);
					
	input logic	[4:0]  ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] RegEn;
	logic [63:0] RegOut [31:0];
	
	logic negclk;
	not notclk (negclk, clk);
//decoder
	decoder5_32 dec (.in(WriteRegister[4:0]), .enable(RegWrite), .out(RegEn[31:0]));
	
//64x32:1 mux
	mux64_32_1 mux0 (RegOut, ReadRegister1, ReadData1);
	mux64_32_1 mux1 (RegOut, ReadRegister2, ReadData2);
	
//register
	genvar i;
	genvar j;
	
	generate
		for (i=0; i<31; i=i+1) begin: Reg
			for (j = 0; j < 64; j = j + 1) begin: DFF	
				D_FF_en ff (.q(RegOut[i][j]), .d(WriteData[j]), .clk(negclk), .en(RegEn[i]), .reset()); 
			end
		end
	endgenerate
	
// set register 31 to 0
	genvar m;
	generate
		for (m = 0; m < 64; m++) begin : reg31
			assign RegOut[31][m] = 1'b0;
		end
	endgenerate

endmodule
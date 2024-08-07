`timescale 10ps/1fs
module decoder5_32(in, enable, out);
	input logic [4:0] in;
	input logic enable;
	output logic [31:0] out;
	
	logic [3:0] en ;
	
	decoder2_4 dec0 (.in(in[4:3]), .enable(enable), .out(en[3:0]));
	decoder3_8 dec1 (in[2:0], en[0], out[7:0]);
	decoder3_8 dec2 (in[2:0], en[1], out[15:8]);
	decoder3_8 dec3 (in[2:0], en[2], out[23:16]);
	decoder3_8 dec4 (in[2:0], en[3], out[31:24]);

endmodule

module testbench5_32();
	logic [4:0] in;
	logic enable;
	logic [31:0] out;
	
	decoder5_32 dec (.in, .enable, .out);

	initial begin
		in = 5'b00000; enable = 1'b0; #100;
		
		for (int i = 0; i < 32; i = i+1) begin
			enable = 1'b0;
			in = i;
			#100;
			
			enable = 1'b1;
			#100;
		end
		$stop;
	end
	
endmodule
module mux64_32_1 #(parameter N=64) (in, sel, out);
	input logic [63:0] in [31:0]; //32 arrays of size 64
	input logic [4:0] sel;
	output logic [63:0] out;
	
	//genvar i;
	
	//generate 
		//for (i = 0; i < N; i = i+1) begin: muxes
			//mux32_1 mux32 (.in(in[i][31:0]), .sel(sel[4:0]), .out(out[i])); //reads ith entry from each of 32
		//end
	//endgenerateg
	genvar i, j;
	generate
        for (i = 0; i < 64; i = i + 1) begin : muxes
            logic [31:0] slice; 
          
            for (j = 0; j < 32; j = j + 1) begin: slices
                assign slice[j] = in[j][i]; //stores the ith entry of each of the 32 registers
            end
            
            mux32_1 mux32 (.in(slice), .sel(sel), .out(out[i]));
        end
   endgenerate

endmodule




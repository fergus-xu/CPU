module mux64_4_1 (in, sel, out);
	input logic [63:0] in [3:0];
	input logic [1:0] sel;
	output logic [63:0] out;
	
	genvar i, j;
	generate
        for (i = 0; i < 64; i = i + 1) begin : muxes
            logic [3:0] slice; 
          
            for (j = 0; j < 4; j = j + 1) begin: slices
                assign slice[j] = in[j][i]; //stores the ith entry of each of the 32 registers
            end
            
            mux4_1 mux32 (.in(slice), .sel(sel), .out(out[i]));
        end
    endgenerate


endmodule

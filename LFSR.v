module LFSR #(parameter NUM_BITS = 10) (
	input i_Clk,
	input i_Enable,
	output [NUM_BITS-1:0] o_LFSR_Data
);

	reg [NUM_BITS:1] r_LFSR = 0;
	reg              r_XNOR;
 

	always @(posedge i_Clk) begin
		if (i_Enable == 1'b1) begin
			r_LFSR <= {r_LFSR[NUM_BITS-1:1], r_XNOR};
		end
	end

	always @(*) begin
		r_XNOR = r_LFSR[10] ^~ r_LFSR[7];
    end

	assign o_LFSR_Data = r_LFSR[NUM_BITS:1];
 
endmodule
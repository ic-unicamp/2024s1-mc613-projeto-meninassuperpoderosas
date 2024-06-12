module switches(
	input clk,
	input [9:0] SW,
	output reg abertura,
	output reg bandeira,
	output reset,
	output debug
);

	assign reset = SW[9];
	assign debug = SW[8];

	reg anterior_0;
	always @(posedge clk) begin
		if (reset) begin
			anterior_0 = SW[0];
			abertura = 0;
		end else begin
			if (SW[0] != anterior_0) begin
				abertura = 1;
			end else begin
				abertura = 0;
			end
			anterior_0 = SW[0];
		end
	end

	reg anterior_1;
	always @(posedge clk) begin
		if (reset) begin
			anterior_1 = SW[1];
			bandeira = 0;
		end else begin
			if (SW[1] != anterior_1) begin
				bandeira = 1;
			end else begin
				bandeira = 0;
			end
			anterior_1 = SW[1];
		end
	end
	
endmodule
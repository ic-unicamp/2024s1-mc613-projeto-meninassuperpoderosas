module movimentacao(
	input reset,
	input clk_50,
	input N,
	input S,
	input L, 
	input O,
	input [7:0] largura,
	input [7:0] altura,
	output reg [9:0] x_jogador,
	output reg [9:0] y_jogador
);

	always @(posedge clk_50 or posedge reset) begin
		if (reset) begin
			x_jogador = 0;
			y_jogador = 0;
		end else begin
			case ({N, S, L, O})
				4'b1000: begin
					if (y_jogador != 0) begin
						y_jogador = y_jogador - 1;
					end else begin
						y_jogador = altura - 1;
					end
				end
				4'b0100: begin
					if (y_jogador < altura - 1) begin
						y_jogador = y_jogador + 1;
					end else begin
						y_jogador = 0;
					end
				end
				4'b0010: begin
					if (x_jogador < largura - 1) begin
						x_jogador = x_jogador + 1;
					end else begin
						x_jogador = 0;
					end
				end
				4'b0001: begin
					if (x_jogador != 0) begin
						x_jogador = x_jogador - 1;
					end else begin
						x_jogador = largura - 1;
					end
				end
			endcase
		end
	end

endmodule
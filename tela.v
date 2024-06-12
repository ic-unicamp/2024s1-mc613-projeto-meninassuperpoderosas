module tela(
	input reset,
	input vga_clk,
	input [9:0] vga_x,
	input [9:0] vga_y,
	input [9:0] selecao_x,
	input [9:0] selecao_y,
	input [5:0] info_selec,
	input vga_ativo,
	input [7:0] altura,
	input [7:0] largura,
	output reg [8:0] linha,
	output reg [8:0] coluna,
	output reg [7:0] R,
	output reg [7:0] G,
	output reg [7:0] B,
	input debug_minas,
	input explodiu,
	input venceu
);

	// linha e coluna do tabuleiro
	always @(negedge vga_clk) begin
		if (reset) begin
			linha  <= 0;
			coluna <= 0;
		end else begin
			linha  <= vga_y/(480/altura);
			coluna <= vga_x/(640/largura);
		end
	end

	// linha e coluna interna ao quadrado
	reg [9:0] lin_int;
	reg [9:0] col_int;
	always @(negedge vga_clk) begin
		if (reset) begin
			lin_int <= 0;
			col_int <= 0;
		end else begin
			lin_int <= vga_y%(480/altura);
			col_int <= vga_x%(640/largura);
		end
	end

	// sprites
	reg [0:100] px_num1 = 100'b0000000000000111000000111100000110110000000011000000001100000000110000000011000001111111000000000000;
	reg [0:100] px_num2 = 100'b0000000000011111100011000111000000011100000011100000011100000011100000011100000011111111000000000000;
	reg [0:100] px_num3 = 100'b0000000000111111110011111111000000011100001111100000111110000000011100111111110011111111000000000000;
	reg [0:100] px_num4 = 100'b0000000000000111100000111110000111111000111011100011111111000111111100000011100000001110000000000000;
	reg [0:100] px_num5 = 100'b0000000000111111110011111111001100000000111111100011111111000000011100111111110011111111000000000000;
	reg [0:100] px_num6 = 100'b0000000000111111110011111111001100000000111111100011111111001100011100110001110011111111000000000000;
	reg [0:100] px_num7 = 100'b0000000000111111110011111111000000011100000011100000011100000011100000011100000001110000000000000000;
	reg [0:100] px_band = 100'b0000000000000001100000001110000001111000001111100000000110000000011000001111100011111111000000000000;
	reg [0:100] px_mina = 100'b0000000000000110000000111100000110111000111111110011111111000111111000001111000000011000000000000000;
	reg  [0:100] pixels_pos;

	wire bandeira = info_selec[5];
	wire mina = info_selec[4];
	wire aberto = info_selec[3];
	wire [3:0] num_minas = info_selec[2:0];
	wire mostrar_campo = debug_minas || explodiu || venceu;

	// determinando qual dos sprites usar
	always @(posedge vga_clk or posedge reset) begin
		if (reset) begin
			pixels_pos <= 100'b0000000000;
		// bandeira
		end else if (bandeira) begin
			pixels_pos <= px_band;
		// mina
		end else if ((mina && aberto) || (mina && mostrar_campo)) begin
			pixels_pos <= px_mina;
		// numeros
		end else if (aberto || mostrar_campo) begin
			case (num_minas)
				4'd1: pixels_pos <= px_num1;
				4'd2: pixels_pos <= px_num2;
				4'd3: pixels_pos <= px_num3;
				4'd4: pixels_pos <= px_num4;
				4'd5: pixels_pos <= px_num5;
				4'd6: pixels_pos <= px_num6;
				4'd7: pixels_pos <= px_num7;
				default: pixels_pos <= 100'b0000000000;
			endcase
		end else begin
			pixels_pos <= 100'b0000000000;
		end
	end

	// seta cor
	always @(posedge vga_clk or posedge reset) begin
		if (reset) begin
			R <= 0;
			G <= 0;
			B <= 0;
		end else if (vga_ativo) begin
			// posicao selecionada (borda vermelha)
			if (((linha == selecao_y && coluna == selecao_x) && (lin_int < 2 || col_int < 2)) ||
				((linha == selecao_y+1 && coluna == selecao_x) && lin_int < 2) ||
				((linha == selecao_y && coluna == selecao_x+1) && col_int < 2)
			) begin
				R <= 255;
				G <= 0;
				B <= 0;
			// borda preta
			end else if (lin_int < 2 || col_int < 2) begin
				R <= 0;
				G <= 0;
				B <= 0;
			// posicao tem sprite
			end else if ((bandeira || aberto || mostrar_campo) &&
				pixels_pos[(lin_int/((480/altura)/10))*10 + col_int/((640/largura)/10)] == 1
			) begin
				// bandeira
				if (bandeira) begin
					if (lin_int/((480/altura)/10) <= 4) begin
						R <= 255;
						G <= 0;
						B <= 0;
					end else if (!mostrar_campo) begin
						R <= 255;
						G <= 255;
						B <= 255;
					end else begin
						R <= 0;
						G <= 0;
						B <= 0;
					end
				// mina
				end else if ((aberto && mina) || (mina && mostrar_campo)) begin
					R <= 0;
					G <= 0;
					B <= 0;
				// numero
				end else if (aberto || mostrar_campo) begin
					case (num_minas)
						4'd0: begin
							R <= 255;
							G <= 255;
							B <= 255;
						end
						4'd1: begin
							R <= 0;
							G <= 0;
							B <= 255;
						end
						4'd2: begin
							R <= 0;
							G <= 255;
							B <= 0;
						end
						4'd3: begin
							R <= 255;
							G <= 0;
							B <= 0;
						end
						4'd4: begin
							R <= 0;
							G <= 0;
							B <= 60;
						end
						4'd5: begin
							R <= 127;
							G <= 0;
							B <= 0;
						end
						4'd6: begin
							R <= 0;
							G <= 127;
							B <= 0;
						end
						4'd7: begin
							R <= 0;
							G <= 0;
							B <= 0;
						end
						default: begin
							R <= 255;
							G <= 255;
							B <= 255;
						end
					endcase
				end
			// xadrez (posicoes nao reveladas)
			end else if (!aberto && !mostrar_campo) begin
				if ( (linha + coluna + 1) % 2 == 0) begin
					R <= 255/2;
					G <= 255/2;
					B <= 255/2;
				end else begin
					R <= 255/4;
					G <= 255/4;
					B <= 255/4;
				end
			// area vazia dentro do quadrado
			end else begin
				if (explodiu && aberto && mina) begin
					R <= 255;
					G <= 0;
					B <= 0;
				end else begin
					R <= 255;
					G <= 255;
					B <= 255;
				end
			end
		end else begin // if (!vga_ativo)
			R <= 0;
			G <= 0;
			B <= 0;
		end
	end

endmodule
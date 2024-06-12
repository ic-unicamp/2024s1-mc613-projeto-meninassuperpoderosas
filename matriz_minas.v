module matriz_minas (
	input clk,
	input reset,
	input [9:0] read_x,
	input [9:0] read_y,
	input [7:0] largura,
	input [7:0] altura,
	input [7:0] max_minas,
	output [5:0] info,
	output reg [9:0] num_minas,
	input [9:0] x_jogador,
	input [9:0] y_jogador,
	input abertura,
	input bandeira,
	output reg explodiu,
	output venceu
);

	// bit  5   : bandeira
	// bit  4   : mina
	// bit  3   : posicao revelada
	// bits 2-0 : qtd. minas ao redor

	// instancia buffer
	reg [9:0] write_addr;
	wire [5:0] y_in;
	reg write_enable;
	reg [9:0] read_addr;
	reg [5:0] y_out;
	buffer buff_inst(
		.clk(clk),
		.reset(reset),
		.altura(altura),
		.largura(largura),
		.venceu(venceu),
		.abertura(abertura),
		.done_minas(done_minas),
		.write_addr(write_addr), // endereco de escrita do buffer
		.y_in(y_out), // byte de entrada
		.write_enable(write_enable), // permite escrita no buffer
		.read_addr(read_addr), // endereco de leitura do buffer
		.y_out(y_in) // byte de saida
	);

	reg h_clk; // half clock
	always @(posedge clk) begin
		if (reset) begin
			h_clk = 0;
		end else begin
			h_clk = ~h_clk;
		end
	end

	wire [9:0] random;
	LFSR LFSR_inst (
		.i_Clk(h_clk),
		.i_Enable(1'b1),
		.o_LFSR_Data(random),
	);

	reg  done_minas;
	reg  [2:0] estado_abertura;
	reg  [2:0] estado_bandeira;
	reg  [9:0] atual;
	wire [9:0] tam = largura*altura;
	reg  [2:0] cont_lfsr;
	reg  done_clear;
	reg  [9:0] cont_random;
	wire [9:0] random_2 = (random + cont_random) % tam;
	wire leitura_vga = estado_bandeira == 0 && estado_abertura == 0 ? 1 : 0;
	assign info = leitura_vga ? y_in : 0;

	reg [9:0] wr_addr_clear;
	reg [5:0] wr_info_clear;
	reg wr_en_clear;
	reg [3:0] estado_clear;
	// limpa buffer
	always @(posedge h_clk or posedge reset) begin
		if (reset) begin
			done_clear = 0;
			wr_addr_clear = 0;
			wr_en_clear = 0;
			estado_clear = 0;
		end else if (!done_clear) begin
			case (estado_clear)
				0: begin
					wr_addr_clear = 0;
					wr_en_clear = 1;
					wr_info_clear = 6'd0;
					estado_clear = 1;
				end

				1: begin
					if (wr_addr_clear >= tam) begin
						wr_en_clear = 0;
						estado_clear = 2;
					end else begin
						wr_en_clear = 1;
					end
					wr_addr_clear = wr_addr_clear + 1;
				end

				2: begin
					done_clear = 1;
				end
			endcase
		end
	end

	reg  [9:0] wr_addr_minas; // write address
	reg  [5:0] wr_data_minas; // write data
	reg  [9:0] rd_addr_minas; // read address
	reg  wr_en_minas; // write enable
	reg  [3:0] estado_minas;
	wire [9:0] lin_minas = atual / largura;
	wire [9:0] col_minas = atual % largura;
	reg  [7:0] minas_geradas;
	// gera minas
	always @(posedge h_clk or posedge reset) begin
		if (reset) begin
			done_minas = 0;
			wr_addr_minas = 0;
			wr_data_minas = 0;
			rd_addr_minas = 0;
			cont_random = cont_random + 1;
			wr_en_minas = 0;
			atual = 0;
			estado_minas = 0;
			minas_geradas = 0;
		end else if (!done_minas && done_clear) begin
			wr_en_minas = 0;
			case (estado_minas)
				0: begin
					if (cont_lfsr == 3'b111) begin
						rd_addr_minas = random_2;
						estado_minas = 1;
						cont_lfsr = 0;
					end else begin
						cont_lfsr = cont_lfsr + 1;
					end
				end

				1: begin
					if (y_in[4] == 1'b0) begin
						wr_data_minas = {y_in[5], 1'b1, y_in[3:0]}; // seta bit 4 como 1
						minas_geradas = minas_geradas + 1;
						atual = rd_addr_minas;
						wr_addr_minas = atual;
						wr_en_minas = 1;
						rd_addr_minas = atual - largura - 1; // le proximo
						estado_minas = 2;
					end else begin
						estado_minas = 0;
					end
				end

				2: begin // (-1, -1)
					if (lin_minas >= 1 && col_minas >= 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual - largura - 1;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual - largura;
					estado_minas = 3;
				end

				3: begin // (-1, 0)
					if (lin_minas >= 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual - largura;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual - largura + 1; // proximo
					estado_minas = 4;
				end

				4: begin // (-1, 1)
					if (lin_minas >= 1 && col_minas < largura - 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual - largura + 1;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual - 1; // proximo
					estado_minas = 5;
				end

				5: begin // (0, -1)
					if (col_minas >= 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual - 1;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual + 1; // proximo
					estado_minas = 6;
				end

				6: begin // (0, 1)
					if (col_minas < largura - 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual + 1;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual + largura - 1; // proximo
					estado_minas = 7;
				end

				7: begin // (1, -1)
					if (lin_minas < altura - 1 && col_minas >= 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual + largura - 1;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual + largura; // proximo
					estado_minas = 8;
				end

				8: begin // (1, 0)
					if (lin_minas < altura - 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual + largura;
						wr_en_minas = 1;
					end
					rd_addr_minas = atual + largura + 1; // proximo
					estado_minas = 9;
				end

				9: begin // (1, 1)
					if (lin_minas < altura - 1 && col_minas < largura - 1) begin
						wr_data_minas = y_in + 1;
						wr_addr_minas = atual + largura + 1;
						wr_en_minas = 1;
					end
					estado_minas = 10;
				end

				10: begin
					estado_minas = 11;
				end

				11: begin
					if (minas_geradas >= max_minas) begin
						done_minas = 1;
					end else begin
						estado_minas = 0;
					end
				end
			endcase
		end
	end

	reg [9:0] rd_addr_abertura;
	reg [9:0] wr_addr_abertura;
	reg [5:0] wr_data_abertura;
	reg wr_en_abertura;
	// abre posicao
	always @(posedge h_clk or posedge reset) begin
		if (reset) begin
			rd_addr_abertura = 0;
			wr_addr_abertura = 0;
			wr_data_abertura = 0;
			wr_en_abertura = 0;
			estado_abertura = 0;
			explodiu = 0;
		end else if (done_clear && done_minas) begin
			if (abertura)
				estado_abertura = 1;
			case (estado_abertura)
				1: begin
					rd_addr_abertura = y_jogador*largura + x_jogador;
					estado_abertura = 2;
				end

				2: begin
					if (y_in[5] != 1) begin // n eh bandeira
						wr_data_abertura = {y_in[5:4], 1'b1, y_in[2:0]};
						wr_addr_abertura = rd_addr_abertura;
						wr_en_abertura = 1;
						if (y_in[4] == 1) begin // abriu bomba
							explodiu = 1;
						end
					end
					estado_abertura = 0;
				end
			endcase // case (estado_abertura)
		end
	end

	reg [9:0] rd_addr_bandeira;
	reg [9:0] wr_addr_bandeira;
	reg [5:0] wr_data_bandeira;
	reg wr_en_bandeira;
	// posiciona bandeira
	always @(posedge h_clk or posedge reset) begin
		if (reset) begin
			rd_addr_bandeira = 0;
			wr_addr_bandeira = 0;
			wr_data_bandeira = 0;
			wr_en_bandeira = 0;
			estado_bandeira = 0;
			num_minas = max_minas;
		end else if (done_clear && done_minas) begin
			if (bandeira)
				estado_bandeira = 1;
			case (estado_bandeira)
				1: begin
					rd_addr_bandeira = y_jogador*largura + x_jogador;
					estado_bandeira = 2;
				end

				2: begin
					if (y_in[3] != 1) begin // n esta aberto
						if (y_in[5] == 0) begin
							num_minas = num_minas - 1;
						end else begin
							num_minas = num_minas + 1;
						end
						wr_data_bandeira = {~y_in[5], y_in[4:0]};
						wr_addr_bandeira = rd_addr_bandeira;
						wr_en_bandeira = 1;
					end
					estado_bandeira = 3;
				end

				3: begin
					wr_en_bandeira = 0;
					estado_bandeira = 4;
				end

				4: begin
					estado_bandeira = 0;
				end
			endcase // case (estado_bandeira)
		end
	end

	// seleciona informacoes de entrada/saida do buffer baseado na operacao atual
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			write_enable = 0;
			write_addr = 0;
			y_out = 0;
			read_addr = 0;
		end else begin
			// clear
			if (!done_clear) begin
				write_enable = wr_en_clear;
				write_addr = wr_addr_clear;
				y_out = wr_info_clear;
			// minas
			end else if (!done_minas) begin
				write_enable = wr_en_minas;
				write_addr = wr_addr_minas;
				y_out = wr_data_minas;
				read_addr = rd_addr_minas;
			// vga
			end else if (leitura_vga) begin
				write_enable = 0;
				read_addr = read_y*largura + read_x;
			// bandeira
			end else if (!estado_abertura) begin
				write_enable = wr_en_bandeira;
				write_addr = wr_addr_bandeira;
				y_out = wr_data_bandeira;
				read_addr = rd_addr_bandeira;
			// abertura
			end else begin
				write_enable = wr_en_abertura;
				write_addr = wr_addr_abertura;
				y_out = wr_data_abertura;
				read_addr = rd_addr_abertura;
			end
		end
	end

endmodule
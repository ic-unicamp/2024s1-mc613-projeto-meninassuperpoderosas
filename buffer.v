module buffer (
	input clk,
	input reset,
	input [9:0] altura,
	input [9:0] largura,
	input done_minas,
	input abertura,
	input [9:0] write_addr, // endereco de escrita do buffer
	input [5:0] y_in,	    // byte de entrada
	input write_enable,     // permite escrita no buffer
	input [9:0] read_addr,  // endereco de leitura do buffer
	output reg venceu,
	output reg [5:0] y_out  // byte de saida
);
	// bit  5   : bandeira
	// bit  4   : mina
	// bit  3   : posicao revelada
	// bits 2-0 : qtd. minas ao redor
	reg  [5:0] buffer [0:64*48];

	wire [13:0] tam = altura*largura;

	reg varre;
	reg  [9:0] addr_varre;
	wire [9:0] lin_varre = addr_varre / largura;
	wire [9:0] col_varre = addr_varre % largura;
	reg  [3:0] estado;
	reg possivel_vitoria;
	reg abriu;

	// leitura e escrita + varredura (abertura de multiplas posicoes)
	always @(posedge clk) begin
		if (reset) begin
			addr_varre = 0;
			estado = 0;
			abriu = 0;
			venceu = 0;
			varre = 0;
		end else if (write_enable) begin
			buffer[write_addr] = y_in; // escrita
		end else if (done_minas) begin
			// seta comeco da varredura
			varre = 1;
			abriu = 1;
			addr_varre = tam;
			possivel_vitoria = 0;
		end else if (varre) begin
			case (estado)
				0: begin
					if (addr_varre >= tam) begin
						if (!abriu) begin
							varre = 0; // interrompe varredura se n abrir nenhuma posicao
						end
						abriu = 0;
						addr_varre = 0; // endereco inicial
						venceu = possivel_vitoria;
						possivel_vitoria = 1;
					end else begin
						addr_varre = addr_varre + 1;
					end
					case (buffer[addr_varre][5:3])
						3'b000: begin // posicao fechada e livre
							estado = 1;
							possivel_vitoria = 0;
						end
						3'b100: begin // bandeira em posicao q n eh mina
							possivel_vitoria = 0;
						end
					endcase
				end

				1: begin
					// dir eh posicao vazia
					if (col_varre < largura-1 &&
						buffer[addr_varre + 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 2;
					end
				end

				2: begin
					// esq eh posicao vazia
					if (col_varre >= 1 &&
						buffer[addr_varre - 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 3;
					end
				end

				3: begin
					// cima eh posicao vazia
					if (lin_varre >= 1 &&
						buffer[addr_varre - largura] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 4;
					end
				end

				4: begin
					// baixo eh posicao vazia
					if (lin_varre < altura-1 &&
						buffer[addr_varre + largura] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 5;
					end
				end

				5: begin
					// cima dir eh posicao vazia
					if (lin_varre >= 1 && col_varre < largura-1 &&
						buffer[addr_varre - largura + 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 6;
					end
				end

				6: begin
					// cima esq eh posicao vazia
					if (lin_varre >= 1 && col_varre >= 1 &&
						buffer[addr_varre - largura - 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 7;
					end
				end

				7: begin
					// baixo dir eh posicao vazia
					if (lin_varre < altura-1 && col_varre < largura-1 &&
						buffer[addr_varre + largura + 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 8;
					end
				end

				8: begin
					// baixo esq eh posicao vazia
					if (lin_varre < altura-1 && col_varre >= 1 &&
						buffer[addr_varre + largura - 1] == 6'b001000
					) begin
						estado = 9;
					end else begin
						estado = 0;
					end
				end

				9: begin
					// abre a posicao
					buffer[addr_varre] = {3'b001, buffer[addr_varre][2:0]}; // seta bit q indica q esta revelado
					abriu = 1;
					estado = 0;
				end

			endcase
		end
	end

	always @(negedge clk) begin
		y_out = buffer[read_addr];
	end

endmodule
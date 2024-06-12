/*

CONTROLES
	SW[0]: Abre a posicao quando eh flipado (tanto para cima quanto para baixo)
	SW[1]: Idem mas para bandeira
	SW[8]: Modo debug (revela todo o campo)
	SW[9]: Reset
	KEY[3..0]: Movimentacao, em ordem: cima, baixo, esquerda, direita

DISPLAYS
	Os dois displays mais a esquerda mostram o numero de minas restantes (= total - bandeiras)
	Os tres displays mais a direita mostram o tempo de jogo em segundos (max. 999)

TAMANHO DO CAMPO
	Determinado pelo wire "multiplicador". Deve ser uma potencia de 2.

*/

module top1(
	input CLOCK_50,  // 50 MHz
	input [7:0] KEY,
	input [9:0] SW,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output [6:0] HEX0, // HEX da direita
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5  // HEX da esquerda
);

	wire [5:0] multiplicador = 4; // multiplicador do campo
	wire [7:0] altura = 3*multiplicador;
	wire [7:0] largura = 4*multiplicador;

	wire abertura;
	wire bandeira;
	wire debug_minas_vga;
	wire reset;
	switches sw_inst(
		.clk(VGA_CLK),
		.SW(SW),
		.abertura(abertura),
		.bandeira(bandeira),
		.reset(reset),
		.debug(debug_minas_vga)
	);

	wire vga_ativo;
	wire [9:0] vga_x;
	wire [9:0] vga_y;
	vga vga_inst(
		.reset(reset),
		.clk_50(CLOCK_50),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.vga_x(vga_x),
		.vga_y(vga_y),
		.ativo(vga_ativo)
    );

	wire [8:0] lin_tela;
	wire [8:0] col_tela;
	tela tela_inst(
		.reset(reset),
		.vga_clk(VGA_CLK),
		.vga_x(vga_x),
		.vga_y(vga_y),
		.selecao_x(x_jogador),
		.selecao_y(y_jogador),
		.info_selec(info),
		.vga_ativo(vga_ativo),
		.altura(altura),
		.largura(largura),
		.linha(lin_tela),
		.coluna(col_tela),
		.R(VGA_R),
		.G(VGA_G),
		.B(VGA_B),
		.debug_minas(debug_minas_vga),
		.explodiu(explodiu),
		.venceu(venceu)
	);

	wire N, S, L, O;
	botoes botoes_inst(
		.key(KEY[3:0]),
		.clk_50(CLOCK_50),
		.N(N),
		.S(S),
		.L(L),
		.O(O)
	);

	wire [9:0] x_jogador;
	wire [9:0] y_jogador;
	movimentacao mov_inst(
		.reset(reset),
		.clk_50(CLOCK_50),
		.N(N),
		.S(S),
		.L(L),
		.O(O),
		.largura(largura),
		.altura(altura),
		.x_jogador(x_jogador),
		.y_jogador(y_jogador)
	);

	wire [9:0] num_minas; // num_minas = max_minas - num_bandeiras
	// max de minas = MIN(99, 20%*tamanho)
	wire [9:0] max_minas = (altura*largura)/5 > 99 ? 99 : (altura*largura)/5;
	wire [5:0] info;
	wire explodiu;
	wire venceu;
	matriz_minas mat(
		.clk(CLOCK_50),
		.reset(reset),
		.read_x(col_tela), // x vga
		.read_y(lin_tela), // y vga
		.largura(largura),
		.altura(altura),
		.max_minas(max_minas),
		.info(info), // info sobre a posicao (col_tela, lin_tela)
		.num_minas(num_minas),
		.x_jogador(x_jogador),
		.y_jogador(y_jogador),
		.abertura(abertura),
		.bandeira(bandeira),
		.explodiu(explodiu),
		.venceu(venceu)
	);

	temporizador temp_inst(
		.clk_50(CLOCK_50),
		.reset(reset),
		.stop(explodiu || venceu),
		.s0(HEX0),
		.s1(HEX1),
		.s2(HEX2)
	);

	// Display de 7 segmentos p/ o num. de minas
	wire [12:0] bcd;
	bin2bcd b2bc(
		.bin(num_minas),
		.bcd(bcd)
	);
	assign HEX3 = 7'b1111111; // apagado
	cb7s conversor4(
		.numero(bcd[3:0]),
		.segmentos(HEX4)
	);
	cb7s conversor5(
		.numero(bcd[7:4]),
		.segmentos(HEX5)
	);


endmodule
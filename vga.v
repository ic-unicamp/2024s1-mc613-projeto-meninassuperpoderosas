module vga(
	input reset,
	input clk_50,		// 50 MHz
	output reg VGA_CLK, // 25 MHz
	output reg VGA_HS,
	output reg VGA_VS,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output [9:0] vga_x, // contador de pulsos para temporizacao horizontal
	output [9:0] vga_y, // contador de linhas para temporizacao vertical
	output wire ativo
);

	// temporizacao horizontal (pulsos)
	// Ta = 96	--> 96
	// Tb = 48	--> 144
	// Tc = 640 --> 784
	// Td = 16	--> 800

	// temporizacao vertical (linhas)
	// Ta = 2   --> 2
	// Tb = 33  --> 35
	// Tc = 480 --> 515
	// Td = 10  --> 525

	assign vga_x = contador_h - 144;
	assign vga_y = contador_v - 35;

	reg [9:0] contador_h;
	reg [9:0] contador_v;
	
	reg pressionado; // flag para evitar que o quadrado se mova mais de uma vez por pressionamento de botao
	// flags constantes
	assign VGA_BLANK_N = 1;
	assign VGA_SYNC_N = 0;
	// ativo quando contadores estao no intervalo de tempo "c" do VGA
	assign ativo = (contador_h >= 144 && contador_h < 784) && (contador_v >= 35 && contador_v < 515);

	// define clock do VGA
	always @(posedge clk_50 or posedge reset) begin
		if (reset) begin
			VGA_CLK = 0;
		end
		else begin
			VGA_CLK = ~VGA_CLK; // VGA__CLK tem 25 MHz
		end
	end

	// temporizacao
	always @(posedge VGA_CLK /*or posedge reset*/) begin
		if (reset) begin // reset
			contador_h = 0;
			contador_v = 0;
		end else begin
			contador_h = contador_h + 1;
			if (contador_h >= 800) begin
				contador_h = 0;
				contador_v = contador_v + 1;
				if (contador_v >= 525) begin
					contador_v = 0;
				end 
			end
		end
	end

	// sincronizacao
	always @(posedge VGA_CLK) begin
		VGA_HS <= (contador_h < 96) ? 0 : 1;
		VGA_VS <= (contador_v < 2) ? 0 : 1;
	end

endmodule
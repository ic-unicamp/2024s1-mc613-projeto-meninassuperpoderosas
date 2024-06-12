module temporizador(
	input clk_50,
	input reset,
	input stop,
	// info p/ os displays 7 segmentos
	output [6:0] s0, 
	output [6:0] s1,
	output [6:0] s2
);

	reg [9:0] t_seg;
	reg [26:0] cont;
	
	always @(posedge clk_50 or posedge reset) begin
		if (reset) begin
			cont = 0;
			t_seg = 0;
		end else if (!stop && t_seg < 1000) begin
			cont = cont + 1;
			if (cont >= 50000000) begin
				cont = 0;
				t_seg = t_seg + 1;
			end
		end
	end

	wire [12:0] bcd;

	bin2bcd b2bcd(
		.bin(t_seg),
		.bcd(bcd)
	);
	
	cb7s dig0(
		.numero(bcd[3:0]),
		.segmentos(s0)
	);
	cb7s dig1(
		.numero(bcd[7:4]),
		.segmentos(s1)
	);
	cb7s dig2(
		.numero(bcd[11:8]),
		.segmentos(s2)
	);

endmodule
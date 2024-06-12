module botoes(
	input [3:0] key, // botoes (3: norte, 2: sul, 1: oeste, 0: leste)
	input clk_50,    // 50 MHz
	output reg N,
	output reg S,
	output reg L,
	output reg O
);

    reg [40:0] contador0;
    reg [40:0] contador1;
    reg [40:0] contador2;
    reg [40:0] contador3;

    always @(posedge clk_50) begin
        if (!key[3]) begin
            contador0 = contador0 + 1;
            if (contador0 >= 50000000/4) begin
                contador0 = 0;
                N = 1;
            end else begin
                N = 0;
            end
        end else begin
            N = 0;
        end
        if (!key[2]) begin
            contador1 = contador1 + 1;
            if (contador1 >= 50000000/4) begin
                contador1 = 0;
                S = 1;
            end
            else begin
                S = 0;
            end
        end else begin
            S = 0;
        end
        if (!key[0]) begin
            contador2 = contador2 + 1;
            if (contador2 >= 50000000/4) begin
                contador2 = 0;
                L = 1;
            end
            else begin
                L = 0;
            end
        end else begin
            L = 0;
        end
        if (!key[1]) begin
            contador3 = contador3 + 1;
            if (contador3 >= 50000000/4) begin
                contador3 = 0;
                O = 1;
            end
            else begin
                O = 0;
            end
        end else begin
            O = 0;
        end
    end

endmodule
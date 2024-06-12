module cb7s (
    input [3:0] numero,        // bcd que sera convertido
    output reg [6:0] segmentos // segmentos do display de 7 segmentos
);

always @ (numero) begin
    case(numero)
        4'b0000: segmentos = ~7'b0111111; // 0
        4'b0001: segmentos = ~7'b0000110; // 1
        4'b0010: segmentos = ~7'b1011011; // 2
        4'b0011: segmentos = ~7'b1001111; // 3
        4'b0100: segmentos = ~7'b1100110; // 4
        4'b0101: segmentos = ~7'b1101101; // 5
        4'b0110: segmentos = ~7'b1111101; // 6
        4'b0111: segmentos = ~7'b0000111; // 7
        4'b1000: segmentos = ~7'b1111111; // 8
        4'b1001: segmentos = ~7'b1101111; // 9
        default: segmentos = ~7'b0000000; // entrada invalida
    endcase
end

endmodule
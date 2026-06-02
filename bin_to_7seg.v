module bin_to_7seg (
    input [6:0] bin_in,      // Entrada binária de 7 bits (0-99)
    output [6:0] seg_dezena, // Display da dezena (segmentos a-g)
    output [6:0] seg_unidade // Display da unidade (segmentos a-g)
);

    wire [3:0] dezena;
    wire [3:0] unidade;
    
    // Conversão binária para BCD (Binary Coded Decimal)
    bin_to_bcd converter (
        .bin(bin_in),
        .dezena(dezena),
        .unidade(unidade)
    );
    
    // Decodificadores para cada display
    bcd_to_7seg dec_dezena (
        .bcd(dezena),
        .seg(seg_dezena)
    );
    
    bcd_to_7seg dec_unidade (
        .bcd(unidade),
        .seg(seg_unidade)
    );

endmodule

// Módulo para converter binário em BCD
module bin_to_bcd (
    input [6:0] bin,
    output reg [3:0] dezena,
    output reg [3:0] unidade
);

    always @(*) begin
        dezena = bin / 10;
        unidade = bin % 10;
    end

endmodule

// Decodificador BCD para display de 7 segmentos
// Configuração para ânodo comum (segmento aceso = 0)
// Se for cátodo comum, inverta a lógica
module bcd_to_7seg (
    input [3:0] bcd,
    output reg [6:0] seg  // seg = {g, f, e, d, c, b, a}
);

    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default: seg = 7'b1111111; // Apagado
        endcase
    end

endmodule
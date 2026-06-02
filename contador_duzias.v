module contador_duzias (
    input clk,
    input rst_n,
    input inc_duzia,           // pulso de incremento
    output reg [6:0] count,    // 0 a 9 (10 dúzias)
    output [6:0] seg_dezena,
    output [6:0] seg_unidade
);

	always @(posedge clk or negedge rst_n) begin
		 if (!rst_n)
			  count <= 0;
		 else if (inc_duzia) begin
			  if (count >= 3)       // 10ª dúzia completa
					count <= 0;       // zera
			  else
					count <= count + 1;
		 end
	end

	bin_to_7seg display(
		 .bin_in({1'b0, count}),
		 .seg_dezena(seg_dezena),
		 .seg_unidade(seg_unidade)
	);

endmodule
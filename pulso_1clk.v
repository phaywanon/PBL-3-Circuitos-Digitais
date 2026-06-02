module pulso_1clk(
    input clk,
    input rst_n,
    input sinal,
    output reg pulso
);
    reg sinal_delay;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sinal_delay <= 0;
            pulso <= 0;
        end else begin
            sinal_delay <= sinal;
            pulso <= sinal & ~sinal_delay;  // sobe = pulso de 1 clock
        end
    end
endmodule
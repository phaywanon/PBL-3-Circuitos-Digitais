module gerencia_rolhas (
    input clk,
    input rst_n,

    input dec_rolha, // pulso de decrementar rolha 

    // reposição manual no DISPENSADOR
    input manual_add,

    // reposição automática no DISPENSador (+15 direto)
    input auto_add15,

    // SAÍDAS
    output reg [4:0] magazine_count, // 0..20   
    output reg [5:0] dispenser_count, // 0..30
    output reg alarme_sem_rolha, // alarme de zero rolhas no SISTEMA (dispensador e magazine)
    output ready30  // dispenser >= 30
);

	assign ready30 = (dispenser_count >= 30); // para nao passar de 30

	// ---------------------------------------------------------
	// REGISTRADOR PRINCIPAL
	// ---------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
		 if (!rst_n) begin
			  // VALORES PADROES
			  magazine_count  <= 8; 
			  dispenser_count <= 10;
			  alarme_sem_rolha <= 0;
		 end
		 else begin
			  alarme_sem_rolha <= (dispenser_count == 0 && magazine_count == 0); // ALARME DE ZERO ROLHAS NO SISTEMA
			  
			  // Se tem 5 rolhas na valvula de vedacao (magazine), o dispenser libera 15 rolhas, se ele tiver esse valor ou acima no dispensador 
			  if (!dec_rolha && magazine_count == 5 && dispenser_count >= 15) begin 
					magazine_count  <= magazine_count + 15;
					dispenser_count <= dispenser_count - 15;
			  end
			  
			  // Se tem 5 rolhas na valvula de vedacao (magazine), e o dispenser tem menos de 15 rolhas, recarrega a magazine com o que tem
			  else if (!dec_rolha && magazine_count == 5 && dispenser_count < 15) begin
					magazine_count  <= magazine_count + dispenser_count;
					dispenser_count <= dispenser_count - dispenser_count;
			  end
			  
			  // Se tem menos que 5 rolhas na valvula de vedacao (magazine), e o dispenser for recarregado com 15 rolhas, ele carrega a magazine
			  else if (!dec_rolha && magazine_count < 5 && dispenser_count >= 15) begin
					magazine_count  <= magazine_count + 15;
					dispenser_count <= dispenser_count - 15;
			  end
			  
			  // Decrementa rolha ate nao ter mais no sistema
			  else if (dec_rolha && magazine_count > 0) begin
					magazine_count <= magazine_count - 1;
			  end
			  
			  // Adiciona 15 rolhas diretamente no dispensador, respeitando o limite do contador
			  else if  (auto_add15 && dispenser_count <= 15) begin
					dispenser_count <= dispenser_count + 15;
			  end
			  // ou seja, se temos 27 rolhas no dispensador e eu coloc mais 15 direto, ele so vai ate 30 rolhas (maximo)
			  else if (auto_add15 && dispenser_count > 15) begin
					dispenser_count = 30;
			  end
			  
			  // Adciona 1 rolha no dispensador manualmente, como se fosse um prorpio operador recarregando a maquina, uma a uma.
			  else if (manual_add && dispenser_count < 30) begin
					dispenser_count <= dispenser_count + 1;
			  end
		 end
	end

endmodule

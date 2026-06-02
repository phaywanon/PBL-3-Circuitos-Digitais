module fsm2_qualidade1 (
    input  clk, // clock que chegara atrasado
    input  rst_n,	 // botao de reset

    // ENTRADAS
    input  START_VED, // habilitação vinda da FSM1
    input  ALARME, // alarme de zero rolhas no sistema
    input  GARRAFA_VEDADA, // sensor diz que vedação terminou
    input  CQ_OK, // controle de qualidade aprovou
    input  CQ_NOK, // controle de qualidade rejeitou

    // SAÍDAS
    output reg E0, E1, // bits do estado

    output VE, // valvual de vedacao
    output DEC_ROLHA, // decrementa rolhas
    output REJEITA_GARRAFA, // saida que informa que rejeitou garrafa
    output INC_DUZIA, // saida que infoirma que aprovou garrafa
	 output reg DONE_FSM2_HOLD, // saida feita para indicar que saiu do estado hold, para parar o motor na fsm1 durante a vedacao
	 output EM_CQ // saida para parar o motor durante o controle de qualidade 
	 );

    // --------------------------
    // ESTADOS
    // --------------------------
    localparam S0_HOLD = 2'b00;
    localparam S1_VEDANDO = 2'b01;
    localparam S2_CQ      = 2'b10;

    reg [1:0] state, next_state;
	 
    reg rejeita_latch, inc_duzia_latch;
     
    // -------------------------------
    // SAÍDAS
    // -------------------------------
    assign VE = (state == S1_VEDANDO);
    assign DEC_ROLHA = (state == S1_VEDANDO);
	 assign EM_CQ = ((state == S2_CQ) && (next_state ==S0_HOLD));
	 
	 
	 // toda esas parte do latch poderia ser resolvido simplesmente dividindo a frequencia do clock (o que ja e feito) e
	 // associando as saidas com os estados, normalmente. No entando, isso nao foi alterado antes da  
	 // da apresentacao e foi apresentado com o latch
	 // como deveria ter sido:
	 //	 assign REJEITA_GARRAFA = ((state == S2_CQ) && CQ_NOK);
	 //	 assign INC_DUZIA = ((state == S2_CQ) && CQ_OK);
	 
	 
	 assign REJEITA_GARRAFA = rejeita_latch;
	 assign INC_DUZIA = inc_duzia_latch;
	 
	 always @(posedge clk or negedge rst_n) begin
		  if (!rst_n) begin
				rejeita_latch <= 0;
				inc_duzia_latch <= 0;
		  end
		  else if (state == S0_HOLD) begin
				rejeita_latch <= 0;
				inc_duzia_latch <= 0;
		  end
		  else if ((state == S2_CQ) && CQ_NOK)
				rejeita_latch <= 1;
		  else if ((state == S2_CQ) && CQ_OK)
				inc_duzia_latch <= 1;
    end

    // --------------------------
    // LÓGICA COMPORTAMENTAL
    // --------------------------
	 always @(*) begin
		 // valores padrao
		 next_state = state; 
		 DONE_FSM2_HOLD = 1'b0;
		 
		 // alarme para tudo
		 if (ALARME) begin
			  next_state = S0_HOLD;
		 end

		 else case(state)
			  // 00 -> ESPERANDO O TERMINO DA FSM1
			  S0_HOLD: begin
					if (START_VED)
						 next_state = S1_VEDANDO; // sinal recebido --> passa para a vedacao
					else
						 next_state = S0_HOLD;
			  end
			  
			  // 01 -> VEDANDO GARRAFA
			  S1_VEDANDO: begin
				  DONE_FSM2_HOLD = 1'b1; // DESLIGA O LED DO MOTOR DURANTE A VEDACAO
				  if (ALARME) // ALARME ATIVADO
						next_state = S0_HOLD;
				  else if (GARRAFA_VEDADA) //GARRAFA VEDADA
				      next_state = S2_CQ;
				  else
						next_state = S1_VEDANDO;
			  end
			  
			  S2_CQ: begin
				  DONE_FSM2_HOLD = 1'b0; // RELIGA O LEDO DO MOTOR INDO PARA O CQ
				  if (ALARME) // ALARME ATIVADO
						next_state = S0_HOLD;
				  else if (CQ_OK || CQ_NOK) // CONTROLE DE QUALIDADE ARPOVA OU REPROVA
				      next_state = S0_HOLD;
				  else
						next_state = S2_CQ;
					
			  end
			  
			  default: next_state = S0_HOLD;
	 	 endcase
	 end

    // --------------------------
    // REGISTRADORES DE ESTADO
    // --------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0_HOLD;
        else
            state <= next_state;
    end

    // --------------------------
    // EXPORTA OS BITS DO ESTADO
    // --------------------------
     always @(*) begin
         {E1, E0} = state;   
     end

endmodule

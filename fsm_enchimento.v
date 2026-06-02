module fsm_enchimento (
    input  clk, // clock que chegara atrasado
    input  rst_n,	 // botao de reset
	 
	 // ENTRADAS
    input  START_BTN,  // botão start/stop
    input  LIMPA_SUJEIRA,  // botão/chave para apagar o LED da esteira suja
    input  ALARME, // alarme de zero rolhas no sistema
    input  TEM_GARRAFA, // sensor indicando que tem garrafa
    input  GARRAFA_CHEIA, // sensor indicando que garrafa encheu
	 input STOP_MOTOR, // sinal para parar o motor quando entra na vedacao
	 input EM_CQ, // sinal para parar o motor quando entra no controle de qualidade (fsm2)
	 
	 //SAIDAS
    output reg E1, E0, // bits do estado
    output MOTOR, // led do motor ligado
    output EV, // valvula de enchimento (enchendo)
    output FSM1_DONE, // fim da maquina 1 para iniciar a vedacao na maquina 2
    output LED_ALARME, // led do alarme
    output reg ESTEIRA_SUJA // led indicando que a esteira tem garrafa apos o stop
);

    // -------------------------------
    // Detector de borda do botão START/STOP
    // -------------------------------
    reg start_sync0, start_sync1;
    reg start_prev;

    wire start_pulse;

    always @(posedge clk) begin
        start_sync0 <= START_BTN;
        start_sync1 <= start_sync0;
    end

    assign start_pulse = (start_prev == 1'b1) && (start_sync1 == 1'b0);

    always @(posedge clk) begin
        start_prev <= start_sync1;
    end

    // -------------------------------
    // ESTADOS
    // -------------------------------
    localparam S0_IDLE     = 2'b00;
    localparam S1_GARRAFA  = 2'b01;
    localparam S2_ENCHENDO = 2'b10;

    reg [1:0] state, next_state;

    // -------------------------------
    // MAQUINA DE RUN/STOP
    // -------------------------------
    reg running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            running <= 1'b0;
        else if (start_pulse)
            running <= ~running;
    end

    // -------------------------------
    // FLAG DE ESTEIRA SUJA
    // Acende quando operador dá STOP fora do IDLE.
    // Apaga apenas com o botão LIMPA_SUJEIRA.
    // -------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ESTEIRA_SUJA <= 1'b0;

        // operador clicou STOP durante um ciclo ativo
        else if (!running && (state != S0_IDLE))
            ESTEIRA_SUJA <= 1'b1;

        // operador limpou manualmente
        else if (LIMPA_SUJEIRA)
            ESTEIRA_SUJA <= 1'b0;
    end

    // -------------------------------
    // SAÍDAS
    // -------------------------------
    assign MOTOR = (state == S1_GARRAFA) && running && !ALARME && !STOP_MOTOR && !EM_CQ; 
    assign EV    = (state == S2_ENCHENDO) && running && !ALARME;
    assign LED_ALARME = ALARME;

	 
	 // Pulso para indicar que a garrafa esta cheia e passar para a proxima maquina de estados
    reg done_reg;
    always @(posedge clk or negedge rst_n) begin
         if (!rst_n)
              done_reg <= 1'b0;

         // Pulso exato na transição S2_ENCHENDO → S1_GARRAFA
         else if ((state == S2_ENCHENDO) && GARRAFA_CHEIA && running && !ALARME)
              done_reg <= 1'b1;
         else
              done_reg <= 1'b0;
    end

    assign FSM1_DONE = done_reg;



    // -------------------------------
    // PRÓXIMO ESTADO
    // -------------------------------
    always @(*) begin
        case(state)
				
				// 00 -> ESPERANDO O START
            S0_IDLE: begin
                if (!running || ALARME) // DEU STOP/NAO DEU START OU ALARME FOI ATIVADO
                    next_state = S0_IDLE;
                else
                    next_state = S1_GARRAFA; //DEU START
            end
				
				// 01 -> ESPERANDO GARRAFA
            S1_GARRAFA: begin
                if (!running || ALARME)
                    next_state = S0_IDLE; // DEU STOP OU ALARME FOI ATIVADO
                else if (TEM_GARRAFA)
                    next_state = S2_ENCHENDO; // GARRAFA COLOCADA NA ESTEIRA
                else
                    next_state = S1_GARRAFA;
            end
				
				// 10 -> ENCHENDO GARRAFA
            S2_ENCHENDO: begin
                if (!running || ALARME) // DEU STOP OU ALARME FOI ATIVADO
                    next_state = S0_IDLE;
                else if (GARRAFA_CHEIA)
                    next_state = S1_GARRAFA; // GARRAFA CHEIA
                else
                    next_state = S2_ENCHENDO;
            end

            default: next_state = S0_IDLE;
        endcase
    end

    // -------------------------------
    // REGISTRADOR DE ESTADO
    // -------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // expõe E1 e E0
    always @(*) begin
        {E1, E0} = state;
    end

endmodule


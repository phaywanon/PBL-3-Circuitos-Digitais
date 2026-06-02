module top_fsm_toda(
    input clk,
    input rst_n,

    // ---- Entradas gerais ----
    input START_BTN,
    input LIMPA_SUJEIRA,

    // ---- Sensores FSM1 ----
    input TEM_GARRAFA,
    input GARRAFA_CHEIA,

    // ---- Sensores FSM2 ----
    input GARRAFA_VEDADA,
    input CQ_OK,
    input CQ_NOK,
    input MAIS_15_AUTO,

	 // ---- Chave SW7 ----
	 input MANUAL_ADD,

    // ---- LEDs ----
    output MOTOR,
    output EV,
    output VE,
    output DEC_ROLHA,
    output REJEITA_GARRAFA,
    output INC_DUZIA,
    output ESTEIRA_SUJA,
    output LED_ALARME,
    output [1:0] EST1,
    output [1:0] EST2,
	 output [6:0] seg_dezena_rolhas,
	 output [6:0] seg_unidade_rolhas,
	 output [6:0] seg_unidade_disp,
	 output [6:0] seg_dezena_disp,
	 output [6:0] seg_unidade_duzias,
	 output [6:0] seg_dezena_duzias
    );
    
	 
	 // DIVISOR DE FREQUENCIA
	 divfreq (
		.clk(clk),
		.out_clk(clkfsm)
	 );
	 

    wire STOP_MOTOR; // FIO PARA PARAR O MOTOR QUANDO VEDACAO INICIA
	 
    //--------------------------------
    // FSM1 – Enchimento
    //--------------------------------
    fsm_enchimento FSM1 (
    .clk(clkfsm),
    .rst_n(rst_n),
    .START_BTN(START_BTN),
    .LIMPA_SUJEIRA(LIMPA_SUJEIRA),
    .ALARME(ALARME_SEM_ROLHAS),
    .TEM_GARRAFA(TEM_GARRAFA),
    .GARRAFA_CHEIA(GARRAFA_CHEIA),
    .E1(EST1[1]), .E0(EST1[0]),
    .MOTOR(MOTOR),
    .EV(EV),
    .FSM1_DONE(FSM1_DONE),
    .LED_ALARME(LED_ALARME),
    .ESTEIRA_SUJA(ESTEIRA_SUJA),
	 .STOP_MOTOR(STOP_MOTOR),
	 .EM_CQ(EM_CQ)
    );
	 
	 
	 // TRANSFORMA O NIVEL DE TERMINO DA FSM1 EM PULSO PARA INCIAR A VEDACAO DA FSM2
    wire FSM1_DONE;
	 wire FSM1_done_pulse;
	 pulso_1clk p_fsm1(
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .sinal(FSM1_DONE), 
		 .pulso(FSM1_done_pulse)
 	 );


    //--------------------------------
    // FSM2 – Vedação + CQ
    //--------------------------------
    fsm2_qualidade1 FSM2 (
    .clk(clkfsm),
    .rst_n(rst_n),
    .START_VED(FSM1_done_pulse),
    .ALARME(ALARME_SEM_ROLHAS),
    .GARRAFA_VEDADA(GARRAFA_VEDADA),
    .CQ_OK(cq_ok_pulse),
    .CQ_NOK(cq_nok_pulse),
    .E0(EST2[0]),
    .E1(EST2[1]),
    .VE(VE),
    .DEC_ROLHA(DEC_ROLHA),
    .REJEITA_GARRAFA(REJEITA_GARRAFA),
    .INC_DUZIA(INC_DUZIA),
	 .DONE_FSM2_HOLD (STOP_MOTOR),
	 .EM_CQ(EM_CQ)
    );
	 
	 
	 // TRANSFORMA O NIVEL DO CONTROLE DE QUALIDADE EM PULSO
	 wire cq_ok_pulse, cq_nok_pulse;
	 pulso_1clk p_cqok(
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .sinal(CQ_OK),
		 .pulso(cq_ok_pulse)
	 );

	 pulso_1clk p_cqnok(
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .sinal(CQ_NOK),
		 .pulso(cq_nok_pulse)
	 );
	 
	 // TRANSFORMA O NIVEL DE ACRESCENTAR 15 ROLHAS NO DISPENSADOR EM APENAS 1 PULSO, PARA NAO ACRESCENTAR MAIS ROLHAS DO QUE O PEDIDO
	 wire mais15_pulse;
	 pulso_1clk p15(
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .sinal(MAIS_15_AUTO),
		 .pulso(mais15_pulse)
	 );
	
	 // TRANSFORMA O NIVEL DE DECREMENTAR ROLHA EM APENAS 1 PULSO, PARA NAO DECREMENTAR MAIS DE UMA ROLHA NUM CICLO
	 wire dec_rolha_pulse;
	 pulso_1clk p_dec(
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .sinal(DEC_ROLHA),
		 .pulso(dec_rolha_pulse)
	 );


	 wire [4:0] magazine_count;
	 wire [5:0] dispenser_count;
	 wire ALARME_SEM_ROLHAS;
	 wire READY_30; 

	 gerencia_rolhas GER (
		 .clk(clkfsm),
		 .rst_n(rst_n),
		 .dec_rolha(dec_rolha_pulse),
		 .manual_add(MANUAL_ADD), // reposição manual 
		 .auto_add15(mais15_pulse), // reposiçao automática DE +15 ROLHAS NO DISPENSADOR, RESPEITANDO O LIMITE DO CONTADOR
		 .magazine_count(magazine_count),
		 .dispenser_count(dispenser_count),
		 .alarme_sem_rolha(ALARME_SEM_ROLHAS),
		 .ready30(READY_30) 
	 );
	

	 bin_to_7seg magazine_display(
		.bin_in({2'b0, magazine_count}),
		.seg_dezena(seg_dezena_rolhas),
		.seg_unidade(seg_unidade_rolhas)
	 );
	

	bin_to_7seg dispensador_display(
	.bin_in({1'b0, dispenser_count}),
	.seg_dezena(seg_dezena_disp),
	.seg_unidade(seg_unidade_disp)
	);
	
	
	wire pulso_duzia;

	contador_garrafas CONT_GAR (
	 .clk(clkfsm),
	 .rst_n(rst_n),
	 .inc_garrafa(INC_DUZIA), 
	 .pulso_duzia(pulso_duzia)
	);
	
	contador_duzias CONT_DUZ (
    .clk(clkfsm),
    .rst_n(rst_n),
    .inc_duzia(pulso_duzia),
    .count(),  
    .seg_dezena(seg_dezena_duzias),  
    .seg_unidade(seg_unidade_duzias) 
	);

endmodule

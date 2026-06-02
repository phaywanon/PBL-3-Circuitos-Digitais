module divfreq(
	input clk,
	output out_clk
	);
	
	T_flipflop (clk, 1'b1, 1'b1, q0);
	T_flipflop (q0, 1'b1, 1'b1, q1);
	T_flipflop (q1, 1'b1, 1'b1, q2);
	T_flipflop (q2, 1'b1, 1'b1, q3);
	T_flipflop (q3, 1'b1, 1'b1, q4);
	T_flipflop (q4, 1'b1, 1'b1, q5);
	T_flipflop (q5, 1'b1, 1'b1, q6);
	T_flipflop (q6, 1'b1, 1'b1, q7);
	T_flipflop (q7, 1'b1, 1'b1, q8);
	T_flipflop (q8, 1'b1, 1'b1, q9);
	T_flipflop (q9, 1'b1, 1'b1, q10);
	T_flipflop (q10, 1'b1, 1'b1, q11);
	T_flipflop (q11, 1'b1, 1'b1, q12);
	T_flipflop (q12, 1'b1, 1'b1, q13);
	T_flipflop (q13, 1'b1, 1'b1, q14);
	T_flipflop (q14, 1'b1, 1'b1, q15);
	T_flipflop (q15, 1'b1, 1'b1, q16);
	T_flipflop (q16, 1'b1, 1'b1, q17);
	T_flipflop (q17, 1'b1, 1'b1, q18);
	T_flipflop (q18, 1'b1, 1'b1, q19);
	T_flipflop (q19, 1'b1, 1'b1, q20);

	
	assign out_clk = q20;
endmodule
	
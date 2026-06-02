module d_flip_flop(
    input wire clk,
    input wire rstn, // Active-low asynchronous reset
    input wire d,
    output reg q
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin // Asynchronous reset
        q <= 1'b0;
    end else begin
        q <= d; // Capture D on positive clock edge
    end
end

endmodule
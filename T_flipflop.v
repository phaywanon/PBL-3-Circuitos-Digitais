module T_flipflop (
    input clk,
    input rst_n, // Active-low asynchronous reset
    input t,
    output reg q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // Asynchronous reset
            q <= 1'b0;
        end else begin
            if (t == 1'b1) begin // Toggle condition
                q <= ~q;
            end else begin // Hold condition
                q <= q;
            end
        end
    end

endmodule
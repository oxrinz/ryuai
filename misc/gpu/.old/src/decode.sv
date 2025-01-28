module DECODE (
    input i_Clk,
    input [7:0] instruction,
    input w_RX_DV,
    output reg o_LED_1
);

  reg w_RX_DV_prev;

  always @(posedge i_Clk) begin
    w_RX_DV_prev <= w_RX_DV;

    if (w_RX_DV && !w_RX_DV_prev) begin
      if (instruction == 8'b10101010) begin
        o_LED_1 <= 1'b1;
      end else begin
        o_LED_1 <= 1'b0;
      end
    end
  end

endmodule

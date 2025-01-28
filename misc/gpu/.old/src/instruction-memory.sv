module INSTRUCTION_MEMORY (
    input i_Clk,
    input wire [3:0] address,
    output reg [31:0] instruction
);

  reg [31:0] memory[0:15];

  initial begin
    integer i;
    for (i = 0; i < 16; i = i + 1) begin
      memory[i] = 32'h0;
    end
  end

  always @(posedge i_Clk) begin
      instruction <= memory[address];
  end

endmodule

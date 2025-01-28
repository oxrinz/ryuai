module bin_to_seg (
    input        i_Clk,
    input  [3:0] i_Binary_Num,
    output       o_Segment_A,
    output       o_Segment_B,
    output       o_Segment_C,
    output       o_Segment_D,
    output       o_Segment_E,
    output       o_Segment_F,
    output       o_Segment_G
);

  reg [6:0] r_Hex_Encoding = 7'h00;

  always @(posedge i_Clk) begin
    case (i_Binary_Num)
      4'b0000: r_Hex_Encoding <= 7'b1111110;
      4'b0001: r_Hex_Encoding <= 7'b0110000;
      4'b0010: r_Hex_Encoding <= 7'b1101101;
      4'b0011: r_Hex_Encoding <= 7'b1111001;
      4'b0100: r_Hex_Encoding <= 7'b0110011;
      
      4'b0101: r_Hex_Encoding <= 7'b1011011;
      4'b0110: r_Hex_Encoding <= 7'b1011111;
      4'b0111: r_Hex_Encoding <= 7'b1110000;
      4'b1000: r_Hex_Encoding <= 7'b1111111;
      4'b1001: r_Hex_Encoding <= 7'b1111011;
      default: r_Hex_Encoding <= 7'b0000000; 
    endcase
  end

  assign o_Segment_A = r_Hex_Encoding[6];
  assign o_Segment_B = r_Hex_Encoding[5];
  assign o_Segment_C = r_Hex_Encoding[4];
  assign o_Segment_D = r_Hex_Encoding[3];
  assign o_Segment_E = r_Hex_Encoding[2];
  assign o_Segment_F = r_Hex_Encoding[1];
  assign o_Segment_G = r_Hex_Encoding[0];


endmodule

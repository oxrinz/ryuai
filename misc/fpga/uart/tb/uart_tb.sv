`timescale 1ns/10ps

module UART_RX_TB();

  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  reg r_Clock = 0;
  reg r_RX_Serial = 1;
  wire [7:0] w_RX_Byte;
  

  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
      
      r_RX_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
      
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_RX_Serial <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
      
      r_RX_Serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask
  
  
  UART_RX UART_RX_INST
    (.i_Clock(r_Clock),
     .i_UART_RX(r_RX_Serial),
     .o_RX_DV(),
     .o_RX_Byte(w_RX_Byte)
     );
  
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

  
  initial
    begin
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h37);
      @(posedge r_Clock);
            
      if (w_RX_Byte == 8'h37)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
    $finish();
    end
  
  initial 
  begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
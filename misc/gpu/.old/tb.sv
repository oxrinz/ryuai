module testbench();
    reg i_Clk;
    
    top dut (
        .i_Clk(clk),
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, testbench);
        
        rst = 1;
        
        #20;
        
        rst = 0;
        
        #1000;
        $finish;
    end
    
endmodule
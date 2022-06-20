`timescale 1ns / 1ps

module test_cpu();
    
    reg reset;
    reg clk;
	wire [31:0] a0;
	wire [31:0] v0;
	wire [31:0] sp;
	wire [31:0] ra;
    
    MultiCycleCPU MultiCycleCPU_1(reset, clk, a0, v0, sp, ra);
    
    initial begin
        reset = 1;
        clk = 1;
        #100 reset = 0;
    end
    
    always #50 clk = ~clk;
    
endmodule

`timescale 1ns / 1ps

module RegTemp(reset, clk, Data_i, Data_o);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Data
    input [31:0] Data_i;
    //Output Data
    output reg [31:0] Data_o;
    
    always@(posedge reset or posedge clk) begin
        if (reset) begin
            Data_o <= 32'h00000000;
        end else begin
            Data_o <= Data_i;
        end
    end
endmodule

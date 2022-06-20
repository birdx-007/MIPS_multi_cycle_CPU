`timescale 1ns / 1ps

module InstAndDataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	input [31:0] Write_data;
	//Input Control Signals
	input MemRead;
	input MemWrite;
	//Output Data
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 256;
	parameter RAM_SIZE_BIT = 8;
	parameter RAM_INST_SIZE = 32;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];

	//read data
	assign Mem_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
		    // init instruction memory
			//addi $a0, $zero, 10
			RAM_data[8'd0] <= {6'h08, 5'd0, 5'd4, 16'h000a};
			//addi $v0, $zero, 0
			RAM_data[8'd1] <= {6'h08, 5'd0, 5'd2, 16'h0000};
			//loop:
			//beq $a0, $zero, end
			RAM_data[8'd2] <= {6'h04, 5'd4 , 5'd0 , 16'h000a};
			//add $t0, $a0, $a0 # 2x
			RAM_data[8'd3] <= {6'h00, 5'd4, 5'd4, 5'd8, 5'd0, 6'h20};
			//addi $t0, $t0, -8 # 2x-8
			RAM_data[8'd4] <= {6'h08, 5'd8, 5'd8, 16'hfff8};
			//slt $t1, $t0, $zero 
			RAM_data[8'd5] <= {6'h00, 5'd8, 5'd0, 5'd9, 5'd0, 6'h2a};
			//sll $t1, $t1, 31
			RAM_data[8'd6] <= {6'h00, 5'd0, 5'd9, 5'd9, 5'd31, 6'h00};
			//sra $t1, $t1, 31 # 2x-5<0?FFFFFFFF:00000000
			RAM_data[8'd7] <= {6'h00, 5'd0, 5'd9, 5'd9, 5'd31, 6'h03};
			//and $t2, $t0, $t1 # min(2x-8,0)
			RAM_data[8'd8] <= {6'h00, 5'd8, 5'd9, 5'd10, 5'd0, 6'h24};
			//addi $t2, $t2, 4 # min(2x-8,0)+4
			RAM_data[8'd9] <= {6'h08, 5'd10, 5'd10, 16'h0004};
			//add $v0, $v0, $t2
			RAM_data[8'd10] <= {6'h00, 5'd2, 5'd10, 5'd2, 5'd0, 6'h20};
			//addi $a0, $a0, -1
			RAM_data[8'd11] <= {6'h08, 5'd4, 5'd4, 16'hffff};
			//j loop
			RAM_data[8'd12] <= {6'h02, 26'd2};
			//end:
			//j end
			RAM_data[8'd13] <= {6'h02, 26'd13};
       
            //init instruction memory
            //reset data memory		  
			for (i = RAM_INST_SIZE; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		end else if (MemWrite) begin
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end

endmodule

`timescale 1ns / 1ps

module ALUControl(ALUOp, Funct, ALUConf, Sign);
	//Control Signals
	input [3:0] ALUOp;
	//Inst. Signals
	input [5:0] Funct;
	//Output Control Signals
	output reg [4:0] ALUConf;
	output Sign;

    //--------------Your code below-----------------------

	parameter ADD=5'h0;
	parameter SUB=5'h1;
	parameter AND=5'h2;
	parameter OR=5'h3;
	parameter XOR=5'h4;
	parameter NOR=5'h5;
	parameter SL=5'h6;
	parameter SR=5'h7;
	parameter SLT=5'h8;
	parameter NOP1=5'h9;
	parameter NOP2=5'h10;
	
	parameter OP_ADD=4'h0;
	parameter OP_SUB=4'h1;
	parameter OP_FUNCT=4'h2;
	parameter OP_AND=4'h3;
	parameter OP_LU=4'h4;
	parameter OP_SLT=4'h5;
	parameter OP_ADDU=4'h6;
	parameter OP_SLTU=4'h7;
	
	always@(*)begin
		case(ALUOp)
			OP_ADD:begin
				ALUConf<=ADD;
			end
			OP_SUB:begin
				ALUConf<=SUB;
			end
			OP_FUNCT:begin
				case(Funct)
					6'h20,6'h21:begin//add,addu
						ALUConf<=ADD;
					end
					6'h22,6'h23:begin//sub,subu
						ALUConf<=SUB;
					end
					6'h24:begin//and
						ALUConf<=AND;
					end
					6'h25:begin//or
						ALUConf<=OR;
					end
					6'h26:begin//xor
						ALUConf<=XOR;
					end
					6'h27:begin//nor
						ALUConf<=NOR;
					end
					6'h00:begin//sll
						ALUConf<=SL;
					end
					6'h02,6'h03:begin//srl sra
						ALUConf<=SR;
					end
					6'h2a,6'h2b:begin//slt sltu
						ALUConf<=SLT;
					end
					6'h08,6'h09:begin//jr jalr
						ALUConf<=NOP1;
					end
					default:begin
						ALUConf<=5'h0;
					end
				endcase
			end
			OP_AND:begin
				ALUConf<=AND;
			end
			OP_LU:begin
				ALUConf<=NOP2;
			end
			OP_SLT:begin
				ALUConf<=SLT;
			end
			default:begin
				ALUConf<=5'h0;
			end
		endcase
	end
	
	assign Sign=(ALUOp==OP_FUNCT && Funct==6'h21)?0://addu
				(ALUOp==OP_FUNCT && Funct==6'h23)?0://subu
				(ALUOp==OP_ADDU)?0://addiu
				(ALUOp==OP_FUNCT && Funct==6'h0)?0://sll
				(ALUOp==OP_FUNCT && Funct==6'h02)?0://srl
				(ALUOp==OP_FUNCT && Funct==6'h2b)?0://sltu
				(ALUOp==OP_SLTU)?0://sltiu
				1;
				
    //--------------Your code above-----------------------

endmodule

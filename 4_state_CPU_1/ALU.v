`timescale 1ns / 1ps

module ALU(ALUConf, Sign, In1, In2, Zero, Result);
    // Control Signals
    input [4:0] ALUConf;
    input Sign;
    // Input Data Signals
    input [31:0] In1;
    input [31:0] In2;
    // Resultput 
    output Zero;
    output reg [31:0] Result;

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
	
	assign Zero=Result==0;
	always@(*)begin
		case(ALUConf)
			NOP1:begin
				Result<=In1;
			end
			NOP2:begin
				Result<=In2;
			end
			ADD:begin
				Result<=In1+In2;
			end
			SUB:begin
				Result<=In1-In2;
			end
			AND:begin
				Result<=In1&In2;
			end
			OR:begin
				Result<=In1|In2;
			end
			XOR:begin
				Result<=In1^In2;
			end
			NOR:begin
				Result<=~(In1|In2);
			end
			SL:begin
				Result<=In2<<In1[4:0];
			end
			SR:begin
				if(Sign==1)begin
					Result<={{32{In2[31]}},In2}>>In1[4:0];
				end
				else begin
					Result<=In2>>In1[4:0];
				end
			end
			SLT:begin
				if(Sign==1)begin
					Result<=(In1-In2)>>31;
				end
				else begin
					Result<=(In1-In2+{{In1[31]},{31{1'b0}}}-{{In2[31]},{31{1'b0}}})>>31;
				end
			end
			default:;
		endcase
	end
        
    //--------------Your code above-----------------------

endmodule

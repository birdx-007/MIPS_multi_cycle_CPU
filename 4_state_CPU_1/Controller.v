`timescale 1ns / 1ps

module Controller(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
    output reg PCWrite;
    output reg PCWriteCond;
    output reg IorD;
    output reg MemWrite;
    output reg MemRead;
    output reg IRWrite;
    output reg [1:0] MemtoReg;
    output reg [1:0] RegDst;
    output reg RegWrite;
    output reg ExtOp;
    output reg LuiOp;
    output reg [1:0] ALUSrcA;
    output reg [1:0] ALUSrcB;
    output reg [3:0] ALUOp;
    output reg [1:0] PCSource;
      
	reg [1:0] state; //current state
	reg [2:0] next_state; //next_state
	parameter sIF = 2'b0 ,sID = 2'b1; 

    always @(posedge reset or posedge clk) 
    begin
        if (reset) 
            begin
                state <= 3'b0;
                next_state <=3'b0;
                PCWrite <= 1'b0;
                PCWriteCond <= 1'b0;
                IorD <= 1'b0;
                MemWrite <= 1'b0;
                MemRead <= 1'b0;
                IRWrite <= 1'b0;
                MemtoReg <= 2'b00;
                RegDst <= 2'b0;
                RegWrite <= 1'b0;
                ExtOp <= 1'b0;
                LuiOp <= 1'b0;
                ALUSrcA <= 2'b0;
                ALUSrcB <= 2'b0;
                PCSource <=2'b0;
            end
        else
        begin
            if (next_state == sIF) 
                begin
                    
                    state <= next_state;
                    next_state <= next_state + 2'b1;
                    
                    MemRead <= 1'b1;
                    IRWrite <= 1'b1;
                    PCWrite <= 1'b1;
                    PCSource <= 2'b00;
                    ALUSrcA <= 2'b00;
                    IorD <= 1'b0;
                    ALUSrcB <= 2'b01;
        
                    PCWriteCond <= 1'b0;
                    MemWrite <= 1'b0;
                    MemtoReg <= 2'b00;
                    RegDst <= 2'b0;
                    RegWrite <= 1'b0;
                    ExtOp <= 1'b0;
                    LuiOp <= 1'b0;
                end
                
            else if (next_state == sID) 
                begin
                    state <= next_state;
                    next_state <= next_state + 2'b1;
                    ALUSrcA <= 2'b00;
                    ALUSrcB <= 2'b11;    
                    ExtOp <= 1'b1;
                    
                    PCWrite <= 1'b0;
                    PCWriteCond <= 1'b0;
                    IorD <= 1'b0;
                    MemWrite <= 1'b0;
                    MemRead <= 1'b0;
                    IRWrite <= 1'b0;
                    MemtoReg <= 2'b00;
                    RegDst <= 2'b0;
                    RegWrite <= 1'b0;
                    LuiOp <= 1'b0;
                    PCSource <=2'b0;
                end
            else if (next_state == 2'd2) 
                begin
                    state <= next_state;
                    case(OpCode)
                        6'h00: 
                            begin
                                ALUSrcA <= (Funct==6'h00 || Funct==6'h02 || Funct==6'h03 ) ? 2'b10 : 2'b01; 
                                ALUSrcB <= 2'b00;
								//
								RegWrite <= 1'b1;
                                RegDst <= 2'b01;
                                MemtoReg <= 2'b11;
								next_state <= sIF;
								//
                                case(Funct)
                                    6'h08:      
                                        begin
                                            PCSource <= 2'b00;
                                            PCWrite  <= 1'b1;
                                        end
                                    6'h09:        
                                        begin
                                            PCSource <= 2'b00;
                                            PCWrite  <= 1'b1;
                                            
                                            RegDst <= 2'b01;   
                                            MemtoReg <= 2'b10;
                                            RegWrite <= 1'b1;
                                        end
                                    default:;
                                endcase
                            end
						6'h23,6'h2b://lw sw
							begin
								ALUSrcA <= 2'b01;
                                ALUSrcB <= 2'b10;
                                ExtOp <=((OpCode==6'h0c)? 0 : 1);
                                LuiOp <=((OpCode==6'h0f)? 1 : 0);
                                next_state <= next_state +2'b1;
							end
                        6'h0f,6'h08,6'h09,6'h0c,6'h0b,6'h0a://andi other I
                            begin
                                ALUSrcA <= 2'b01;   
                                ALUSrcB <= 2'b10;   
                                ExtOp <=((OpCode==6'h0c)? 0 : 1);      
                                LuiOp <=((OpCode==6'h0f)? 1 : 0);
								//
								RegWrite <= 1'b1;
                                RegDst <= 2'b00;
                                MemtoReg <= 2'b11;
                                next_state <= sIF;
								//
                            end
                        6'h04://beq
                            begin
                                PCWriteCond <= 1'b1;
                                ALUSrcA <= 2'b01;
                                ALUSrcB <= 2'b00;
                                PCSource <= 2'b01;
                                next_state <= sIF;
                            end
                        6'h02://j
                            begin
                                PCWrite <= 1'b1;
                                PCSource <= 2'b10;
                                next_state <= sIF;
                            end
                        6'h03://jal
                            begin
                                PCWrite <= 1'b1;
                                PCSource <= 2'b10;
                                                               
                                RegDst <=  2'b10;   
                                MemtoReg <= 2'b10;
                                RegWrite <= 1'b1;
                                
                                next_state <= sIF;
                            end 
                        default: 
                            begin
                                next_state <= sIF;
                            end
                    endcase
                end
            else if (next_state == 2'd3) 
                begin
                    state<=next_state;
                    case(OpCode)
                        6'h2b:      
                            begin
                                MemWrite<=1'b1;
                                IorD <=1'b1;
                                next_state <= sIF;
                            end
                        6'h23:      
                            begin
                                MemRead <= 1'b1;
                                IorD <= 1'b1;
                                IRWrite <=1'b0;
								//
								RegWrite <= 1'b1;
                                RegDst <= 2'b00;
                                MemtoReg <= 2'b00;
                                next_state <= sIF;
								//
                            end
                        default:;
                    endcase
                end
         end
    end
    
    
    //--------------Your code below-----------------------
    //ALUOp

	parameter ADD=4'h0;
	parameter SUB=4'h1;
	parameter FUNCT=4'h2;
	parameter AND=4'h3;
	parameter LU=4'h4;
	parameter SLT=4'h5;
	parameter ADDU=4'h6;
	parameter SLTU=4'h7;
	
    always @(posedge reset or posedge clk) 
    begin
        if (reset) 
            begin
                ALUOp<=4'h0;
            end
        else
        begin
			if (next_state == sIF)begin
				ALUOp<=ADD;
			end
			else if (next_state == sID)begin
				ALUOp<=ADD;
			end
			else if (next_state == 2'd2)begin
				case(OpCode)
					6'h04:begin//beq
						ALUOp<=SUB;
					end
					6'h00:begin//R(jr jalr included)
						ALUOp<=FUNCT;
					end
					6'h0c:begin//andi
						ALUOp<=AND;
					end
					6'h0f:begin//lui
						ALUOp<=LU;
					end
					6'h0a:begin//slti
						ALUOp<=SLT;
					end
					6'h0b:begin//sltiu
						ALUOp<=SLTU;
					end
					6'h23,6'h2b,6'h08:begin//lw sw addi
						ALUOp<=ADD;
					end
					6'h09:begin//addiu
						ALUOp<=ADDU;
					end
					default:begin
						ALUOp<=4'h0;
					end
				endcase
			end
			else ALUOp<=4'h0;
		end
	end

    //--------------Your code above-----------------------

endmodule
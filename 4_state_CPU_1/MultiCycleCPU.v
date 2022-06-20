`timescale 1ns / 1ps

module MultiCycleCPU (reset, clk, a0, v0, sp, ra);
    //Input Clock Signals
    input reset;
    input clk;
    
    //--------------Your code below-----------------------

	output [31:0] a0,v0,sp,ra;

	wire [5:0] OpCode;
	wire [5:0] Funct;
	wire PCWrite;
    wire PCWriteCond;
    wire IorD;
    wire MemWrite;
    wire MemRead;
    wire IRWrite;
    wire [1:0] MemtoReg;
    wire [1:0] RegDst;
    wire RegWrite;
    wire ExtOp;
    wire LuiOp;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [3:0] ALUOp;
    wire [1:0] PCSource;
	
	wire [31:0] PC;
	wire [31:0] PCnew;
	wire [31:0] Instruction;
	wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] Shamt;
	wire [4:0] RF_Write_register;
	wire [31:0] RF_Write_data;
	wire [31:0] RF_Read_data1;
	wire [31:0] RF_Read_data2;
	wire [15:0] Imm;
	wire [31:0] ImmExt_shift;
	wire [31:0] Imm_in;
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [4:0] ALU_Conf;
	wire ALU_Sign;
	wire [31:0] ALU_OUT;
	wire [31:0] MEM_Address;
	wire [31:0] MEM_Read_data;
	wire Zero;
	
	wire [31:0] A_Out;
	wire [31:0] B_Out;
	wire [31:0] ALUOut_Out;
	
	PC pc(
		.reset(reset),
		.clk(clk),
		.PCWrite(PCWrite|PCWriteCond&Zero),
		.PC_i(PCnew),
		.PC_o(PC)
	);
	
	RegTemp a(
		.reset(reset),
		.clk(clk),
		.Data_i(RF_Read_data1),
		.Data_o(A_Out)
	);
	
	RegTemp b(
		.reset(reset),
		.clk(clk),
		.Data_i(RF_Read_data2),
		.Data_o(B_Out)
	);
	
	RegTemp aluout(
		.reset(reset),
		.clk(clk),
		.Data_i(ALU_OUT),
		.Data_o(ALUOut_Out)
	);
	
	Controller ctr(
		.reset(reset),
		.clk(clk),
		.OpCode(OpCode),
		.Funct(Funct), 
        .PCWrite(PCWrite),
		.PCWriteCond(PCWriteCond),
		.IorD(IorD),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
        .IRWrite(IRWrite),
		.MemtoReg(MemtoReg),
		.RegDst(RegDst),
		.RegWrite(RegWrite),
		.ExtOp(ExtOp),
		.LuiOp(LuiOp),
        .ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ALUOp(ALUOp),
		.PCSource(PCSource)
	);
	
	InstAndDataMemory mem(
		.reset(reset),
		.clk(clk),
		.Address(MEM_Address),
		.Write_data(B_Out),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.Mem_data(MEM_Read_data)
	);
	
	InstReg ir(
		.reset(reset),
		.clk(clk),
		.IRWrite(IRWrite),
		.Instruction(MEM_Read_data),
		.OpCode(OpCode),
		.rs(rs),
		.rt(rt),
		.rd(rd),
		.Shamt(Shamt),
		.Funct(Funct)
	);
	
	RegisterFile rf(
		.reset(reset),
		.clk(clk),
		.RegWrite(RegWrite),
		.Read_register1(rs),
		.Read_register2(rt),
		.Write_register(RF_Write_register),
		.Write_data(RF_Write_data),
		.Read_data1(RF_Read_data1),
		.Read_data2(RF_Read_data2)
	);
	
	ImmProcess immprocess(
		.ExtOp(ExtOp),
		.LuiOp(LuiOp),
		.Immediate(Imm),
		.ImmExtOut(Imm_in),
		.ImmExtShift(ImmExt_shift)
	); 
	
	ALUControl aluctr(
		.ALUOp(ALUOp),
		.Funct(Funct),
		.ALUConf(ALU_Conf),
		.Sign(ALU_Sign)
	);
	
	ALU alu(
		.ALUConf(ALU_Conf),
		.Sign(ALU_Sign),
		.In1(ALU_in1),
		.In2(ALU_in2),
		.Zero(Zero),
		.Result(ALU_OUT)
	);
    
	assign MEM_Address=IorD?ALUOut_Out:PC;
	assign RF_Write_register=(RegDst==2'b10)?5'd31:
							 (RegDst==2'b01)?rd:
							 rt;
	assign RF_Write_data=(MemtoReg==2'b11)?ALU_OUT:
						 (MemtoReg==2'b10)?PC:
						 (MemtoReg==2'b01)?ALUOut_Out:
						 MEM_Read_data;
	assign ALU_in1=(ALUSrcA==2'b10)?Shamt:
				   (ALUSrcA==2'b01)?A_Out:
				   PC;
	assign ALU_in2=(ALUSrcB==2'b11)?ImmExt_shift:
				   (ALUSrcB==2'b10)?Imm_in:
				   (ALUSrcB==2'b01)?32'd4:
				   B_Out;
	assign PCnew=(PCSource==2'b10)?{PC[31:28],rs,rt,rd,Shamt,Funct,2'b00}:
				 (PCSource==2'b01)?ALUOut_Out:
				 ALU_OUT;
	
	assign Imm={rd,Shamt,Funct};
	
	assign a0=rf.RF_data[4];
	assign v0=rf.RF_data[2];
	assign sp=rf.RF_data[29];
	assign ra=rf.RF_data[31];
	
    //--------------Your code above-----------------------

endmodule
`include "global_def.h"

module Execute(
  I_CLOCK,
  I_LOCK,
  I_PC,
  I_Opcode,
  I_Src1Value,
  I_Src2Value,
  I_DestRegIdx,
  I_Imm,
  I_DestValue,
  I_FetchStall,
  I_DepStall,
  O_LOCK,
  O_ALUOut,
  O_Opcode,
  O_DestRegIdx,
  O_DestValue,
  O_FetchStall,
  O_DepStall
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the decode stage
input I_CLOCK;
input I_LOCK;
input [`PC_WIDTH-1:0] I_PC;
input [`OPCODE_WIDTH-1:0] I_Opcode;
input [3:0] I_DestRegIdx;
input [`REG_WIDTH-1:0] I_Src1Value;
input [`REG_WIDTH-1:0] I_Src2Value;
input [`REG_WIDTH-1:0] I_Imm;
input [`REG_WIDTH-1:0] I_DestValue;
input I_FetchStall;
input I_DepStall;

// Outputs to the memory stage
output reg O_LOCK;
output reg [`REG_WIDTH-1:0] O_ALUOut;
output reg [`OPCODE_WIDTH-1:0] O_Opcode;
output reg [3:0] O_DestRegIdx;
output reg [`REG_WIDTH-1:0] O_DestValue;
output reg O_FetchStall;
output reg O_DepStall;

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////
//

/////////////////////////////////////////
// ## Note ##
// - Do the appropriate ALU operations.
/////////////////////////////////////////
always @(negedge I_CLOCK)
begin
  O_LOCK <= I_LOCK;
  O_FetchStall <= I_FetchStall;

  if (I_LOCK == 1'b1) 
  begin
    /////////////////////////////////////////////
    // TODO: Complete here 
    /////////////////////////////////////////////
	 
	 if (I_Opcode == `OP_ADD_D)  O_ALUOut <= I_Src1Value + I_Src2Value;
	 if (I_Opcode == `OP_ADDI_D) O_ALUOut <= I_Src1Value + I_Imm;
	 if (I_Opcode == `OP_AND_D)  O_ALUOut <= I_Src1Value & I_Src2Value;
	 if (I_Opcode == `OP_ANDI_D) O_ALUOut <= I_Src1Value & I_Imm;
	 if (I_Opcode == `OP_MOV)    O_ALUOut <= I_Src1Value;
	 if (I_Opcode == `OP_MOVI_D) O_ALUOut <= I_Imm;
	 if (I_Opcode == `OP_BRN)    O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRP)    O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRNZ)   O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRNP)   O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRNZP)  O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRZP)   O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_BRZ)    O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_JSR)    O_ALUOut <= I_PC + I_Imm << 2;
	 if (I_Opcode == `OP_LDW)    O_ALUOut <= I_Src1Value + I_Imm;
	 if (I_Opcode == `OP_STW)    O_ALUOut <= I_Src1Value + I_Imm;
	 
	 O_DestValue <= I_DestValue;
	 
  end // if (I_LOCK == 1'b1)
end // always @(negedge I_CLOCK)

endmodule // module Execute

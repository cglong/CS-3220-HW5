`include "global_def.h"

module Decode(
  I_CLOCK,
  I_LOCK,
  I_PC,
  I_IR,
  I_FetchStall,
  I_WriteBackEnable,
  I_WriteBackRegIdx,
  I_WriteBackData,
  O_LOCK,
  O_PC,
  O_Opcode,
  O_Src1Value,
  O_Src2Value,
  O_DestRegIdx,
  O_DestValue,
  O_Imm,
  O_FetchStall,
  O_DepStall,
  O_BranchStallSignal,
  O_DepStallSignal
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the fetch stage
input I_CLOCK;
input I_LOCK;
input [`PC_WIDTH-1:0] I_PC;
input [`IR_WIDTH-1:0] I_IR;
input I_FetchStall;

// Inputs from the writeback stage
input I_WriteBackEnable;
input [3:0] I_WriteBackRegIdx;
input [`REG_WIDTH-1:0] I_WriteBackData;

// Outputs to the execude stage
output reg O_LOCK;
output reg [`PC_WIDTH-1:0] O_PC;
output reg [`OPCODE_WIDTH-1:0] O_Opcode;
output reg [`REG_WIDTH-1:0] O_Src1Value;
output reg [`REG_WIDTH-1:0] O_Src2Value;
output reg [3:0] O_DestRegIdx;
output reg [`REG_WIDTH-1:0] O_DestValue;
output reg [`REG_WIDTH-1:0] O_Imm;
output reg O_FetchStall;

/////////////////////////////////////////
// ## Note ##
// O_DepStall: Asserted when current instruction should be waiting for data dependency resolves. 
// - Like O_FetchStall, the instruction with O_DepStall == 1 will be treated as NOP in the following stages.
/////////////////////////////////////////
output reg O_DepStall;  

// Outputs to the fetch stage
output O_DepStallSignal;
output O_BranchStallSignal;

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//
// Architectural Registers
reg [`REG_WIDTH-1:0] RF[0:`NUM_RF-1]; // Scalar Register File (R0-R7: Integer, R8-R15: Floating-point)
reg [`VREG_WIDTH-1:0] VRF[0:`NUM_VRF-1]; // Vector Register File

// Valid bits for tracking the register dependence information
reg RF_VALID[0:`NUM_RF-1]; // Valid bits for Scalar Register File
reg VRF_VALID[0:`NUM_VRF-1]; // Valid bits for Vector Register File

wire [`REG_WIDTH-1:0] Imm32; // Sign-extended immediate value
reg [2:0] ConditionalCode; // Set based on the written-back result

/////////////////////////////////////////
// INITIAL/ASSIGN STATEMENT GOES HERE
/////////////////////////////////////////
//
reg[7:0] trav;

initial
begin
  for (trav = 0; trav < `NUM_RF; trav = trav + 1'b1)
  begin
    RF[trav] = 0;
    RF_VALID[trav] = 1;  
  end 

  for (trav = 0; trav < `NUM_VRF; trav = trav + 1'b1)
  begin
    VRF[trav] = 0;
    VRF_VALID[trav] = 1;  
  end 

  ConditionalCode = 0;

  O_PC = 0;
  O_Opcode = 0;
  O_DepStall = 0;
end // initial

/////////////////////////////////////////////
// ## Note ##
// __DepStallSignal: Data dependency detected (1) or not (0).
// - Keep in mind that since valid bit is only updated in negative clock
//   edge, you need to take currently written-back information, if there is, into account
//   when asserting this signal as well as valid-bit information.
/////////////////////////////////////////////
wire __DepStallSignal;
assign __DepStallSignal = 
  (I_LOCK == 1'b1) ? 
    ((I_IR[31:24] == `OP_ADDI_D    ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) : 
     (I_IR[31:24] == `OP_MOVI_D    ) ? (1'b0) : 
     (I_IR[31:24] == `OP_BRN       ) ? (ConditionalCode != 3'b100) : 
     /////////////////////////////////////////////
     // TODO: Complete other instructions
     /////////////////////////////////////////////
	  
	  //left for now
	  
	  (I_IR[31:24] == `OP_BRZ       ) ? (ConditionalCode != 3'b010) : 
	  (I_IR[31:24] == `OP_BRP       ) ? (ConditionalCode != 3'b001) : 
	  (I_IR[31:24] == `OP_BRNZ      ) ? (ConditionalCode != 3'b110) : 
	  (I_IR[31:24] == `OP_BRNP      ) ? (ConditionalCode != 3'b101) : 
	  (I_IR[31:24] == `OP_BRZP      ) ? (ConditionalCode != 3'b011) : 
	  (I_IR[31:24] == `OP_BRNZP     ) ? (ConditionalCode != 3'b111) :
	  (I_IR[31:24] == `OP_ADD_D     ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16] || I_WriteBackRegIdx == I_IR[11:8]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_AND_D     ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16] || I_WriteBackRegIdx == I_IR[11:8]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_ANDI_D    ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) : 
	  (I_IR[31:24] == `OP_ADDI_D    ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) : 
	  (I_IR[31:24] == `OP_MOV       ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) : 
	  (I_IR[31:24] == `OP_LDW       ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_STW       ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_JSR       ) ? (1'b0) :
	  (I_IR[31:24] == `OP_JSRR      ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_RET       ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
	  (I_IR[31:24] == `OP_JMP       ) ? ((I_WriteBackEnable == 1) ? ((I_WriteBackRegIdx == I_IR[19:16]) ? (1'b0) : (RF_VALID[I_IR[19:16]] != 1)) : (RF_VALID[I_IR[19:16]] != 1)) :
     (1'b0)
    ) : (1'b0);

assign O_DepStallSignal = (__DepStallSignal & !I_WriteBackEnable);

// O_BranchStallSignal: Branch instruction detected (1) or not (0).
assign O_BranchStallSignal = 
  (I_LOCK == 1'b1) ? 
    ((I_IR[31:24] == `OP_BRN  ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRZ  ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRP  ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRNZ ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRNP ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRZP ) ? (1'b1) : 
     (I_IR[31:24] == `OP_BRNZP) ? (1'b1) : 
     (I_IR[31:24] == `OP_JMP  ) ? (1'b1) : 
     (I_IR[31:24] == `OP_JSR  ) ? (1'b1) : 
     (I_IR[31:24] == `OP_JSRR ) ? (1'b1) : 
     (1'b0)
    ) : (1'b0);

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////
//

/////////////////////////////////////////
// ## Note ##
// First half clock cycle to write data back into the register file 
// 1. To write data back into the register file
// 2. Update Conditional Code to the following branch instruction to refer
/////////////////////////////////////////
always @(posedge I_CLOCK)
begin
  if (I_LOCK == 1'b1)
  begin
    /////////////////////////////////////////////
    // TODO: Complete here 
    /////////////////////////////////////////////
	 if (I_WriteBackEnable) begin
		RF[I_WriteBackRegIdx] <= I_WriteBackData;
		if (I_WriteBackData > 0) ConditionalCode <= 1;
		if (I_WriteBackData == 0) ConditionalCode <= 2;
		if (I_WriteBackData < 0) ConditionalCode <= 4;
	 end
  end // if (I_LOCK == 1'b1)
end // always @(posedge I_CLOCK)

/////////////////////////////////////////
// ## Note ##
// Second half clock cycle to read data from the register file
// 1. To read data from the register file
// 2. To update valid bit for the corresponding register (for both writeback instruction and current instruction) 
/////////////////////////////////////////
always @(negedge I_CLOCK)
begin
  O_LOCK <= I_LOCK;

  if (I_LOCK == 1'b1)
  begin
    /////////////////////////////////////////////
    // TODO: Complete here 
    /////////////////////////////////////////////
	 O_Src1Value <= I_IR[19:16];
	 O_Src2Value <= I_IR[11:8];
	 O_Opcode <= 	 I_IR[31:24];
	 O_DepStall <= __DepStallSignal;
	 O_FetchStall <= I_FetchStall;
	 O_PC <= I_PC;
	 

	 if (I_IR[31:24] == `OP_MOV || I_IR[31:24] == `OP_MOVI_D) 
		O_DestRegIdx <= O_Src1Value;
	 else
		O_DestRegIdx <= I_IR[23:20];
		
	 O_DestValue <= RF[O_DestRegIdx];
	 O_Imm <= I_IR[15:0];
	 RF_VALID[I_WriteBackRegIdx] <= 1;
	 if (I_IR[31:24] == `OP_ADD_D || I_IR[31:24] == `OP_AND_D || I_IR[31:24] == `OP_ADDI_D || I_IR[31:24] == `OP_ANDI_D || I_IR[31:24] == `OP_LDW || 
		I_IR[31:24] == `OP_JSR || I_IR[31:24] == `OP_JSRR || I_IR[31:24] == `OP_MOVI_D || I_IR[31:24] == `OP_MOV)
		RF_VALID[I_IR[23:20]] <= 0;
	 else
		RF_VALID[I_IR[23:20]] <= 1;
	 
  end // if (I_LOCK == 1'b1)
end // always @(negedge I_CLOCK)

/////////////////////////////////////////
// COMBINATIONAL LOGIC GOES HERE
/////////////////////////////////////////
//
SignExtension SE0(.In(I_IR[15:0]), .Out(Imm32));

endmodule // module Decode

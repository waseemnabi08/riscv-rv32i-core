`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 05:48:50 PM
// Design Name: 
// Module Name: SingleCycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SingleCycle(input clk, rst,
 output [31:0] ReadData
    );
    
    //instatiate PC:
    logic [31:0] PC;
    PC_32bit PCinst(.clk(clk), .rst(rst), .count(PC));
    
    // PC + jump
    
    logic [31:0] PC_Target;
    Add_32bit instBranch(.in1(PC), .in2(immExt), .res(PC_Target));
    
    //sel b/w PC normal vs PC_Target
    
    logic PCSrc = Branch & z;
    
    Mux2x1 Muxinst0(.in1(PC), .in2(PC_Target), .sel(Branch&z),  .dataout(PC));
    
    //instatitate instrMem
    logic [31:0] instr;
    
    inst_mem instmem_inst(.PC(PC), .Instr(instr));
    
    //instatiate decoder module
     logic [2:0] func3;       
    logic [6:0] func7;      
    logic [4:0] rs1, rs2, rd;
    
    Decoder  Decoderinst(.instr(instr), .func3(func3), .func7(func7), .rs1(rs1), .rs2(rs2), .rd(rd));
    
    //Controlor inst
    logic      RegWrite;
    logic[1:0] ImmSrc;  
    logic      ALUSrc;  
    logic      MemWrite;
    logic      ResultSrc;
    logic      Branch;  
    logic[1:0] ALUOp;
    
    ControlUnit instContr(.Op(instr[6:0]), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc),
                          .MemWrite(MemWrite), .ResultSrc(ResultSrc), .Branch(Branch), .ALUOp(ALUOp));    
  //ALU Control instantiate
  logic [2:0] ALUControl;                        
       ALU_Control ALUCtrlinst(
         ALUOp, 
         func3, 
         func7,
         ALUControl
    );
    //ImmExt instantiation
    logic [31:0] immExt;
    
    SignExt instSignExt(.instr(instr), .immSrc(ImmSrc), .imm_out(immExt));
    
    //RegFile instantiation
    logic [31:0] outdata1;
    logic [31:0] outdata2;
    
    Reg_File instRegFile(
    .clk(clk),
    .rst(rst),
    .rs1(rs1),       
    .rs2(rs2),
    .rd(rd),
    .wdata(Result),
    .RegWrite(RegWrite),
    .outdata1(outdata1),  
    .outdata2(outdata2)
);
  
  
  // sel b/w dataout2 and immExt
  
  logic [31:0] SrcB;
  
  Mux2x1 muxinst1(.in1(outdata2), .in2(immExt), .sel(ALUSrc), .dataout(SrcB));
  
  
  
  //instantiating ALU
  
  logic [31:0] ALUresult;
      logic        z;
      
  ALU ALUinst(
     .num1(outdata1), .num2(SrcB),
     .ALUCtrl(ALUControl),
     .result(ALUresult),
     .z(z)
);

   //instantiate DataMemory
   
   logic [31:0] ReadData;
   
   
   data_mem instDM(.clk(clk), 
    .mem_read(1'b1),
    .mem_write(MemWrite), 
    .address(ALUresult),
    .data_in(outdata2),
     .data_out(ReadData)
    );
    
    
    //Sel b/w ALUOut and ReadData
    logic [31:0] Result;
    Mux2x1 Muxinst2(.in1(ALUresult), .in2(ReadData), .sel(ResultSrc), .dataout(Result));
    
    
endmodule

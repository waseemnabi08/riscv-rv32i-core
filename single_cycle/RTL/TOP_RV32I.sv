`timescale 1ns / 1ps

module Top_RV32I (
    input  logic clk,
    input  logic rst
);

    // PC & Instruction Memory
    logic [31:0] PC, Next_PC, PC_Plus_4, PC_Target;
    logic [31:0] Instr;
    logic        PCSrc;
    
    // Decoder & Control
    logic [6:0]  opcode, func7;
    logic [2:0]  func3;
    logic [4:0]  rs1, rs2, rd;
    logic        RegWrite, ALUSrc, MemWrite, MemRead, Branch, Jump;
    logic [1:0]  ImmSrc, ALUOp, ResultSrc; // FIXED: ResultSrc is now 2-bit
    
    // Immediates
    logic [31:0] Imm_Ext;
    
    // Register File
    logic [31:0] Result; // Write-back data
    logic [31:0] RD1, RD2;
    
    // ALU
    logic [31:0] SrcB;
    logic [2:0]  ALUControl;
    logic [31:0] ALUResult;
    logic        Zero;
    
    // Data Memory
    logic [31:0] ReadData;

    // Next PC Multiplexer (PCSrc = 1 means Branch/Jump taken)
    Mux2x1 mux_pc (
        .in1(PC_Plus_4), 
        .in2(PC_Target), 
        .sel(PCSrc), 
        .dataout(Next_PC)
    );

    // Program Counter
    PC_32bit pc_unit (
        .clk(clk), 
        .rst(rst), 
        .next_pc(Next_PC), 
        .pc(PC)
    );

    // PC Adders
    Add_32bit add_pc4 (
        .in1(PC), 
        .in2(32'd4), 
        .res(PC_Plus_4)
    );
    
    Add_32bit add_pctarget (
        .in1(PC), 
        .in2(Imm_Ext), 
        .res(PC_Target)
    );

    // Instruction Memory
    inst_mem imem (
        .PC(PC), 
        .Instr(Instr)
    );

    // Instruction Decoder
    Decoder id (
        .instr(Instr), 
        .opcode(opcode), 
        .func3(func3), 
        .func7(func7), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd)
    );

    // Main Control Unit
    ControlUnit ctrl (
        .Op(opcode), 
        .RegWrite(RegWrite), 
        .ImmSrc(ImmSrc), 
        .ALUSrc(ALUSrc), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ResultSrc(ResultSrc), 
        .Branch(Branch), 
        .ALUOp(ALUOp),
        .Jump(Jump)
    );

    // Immediate Generator
    ImmGen ig (
        .instr(Instr), 
        .ImmSrc(ImmSrc), 
        .imm_ext(Imm_Ext)
    );

    // Register File
    Reg_File rf (
        .clk(clk), 
        .rst(rst), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd), 
        .wdata(Result), 
        .RegWrite(RegWrite), 
        .outdata1(RD1), 
        .outdata2(RD2)
    );

    // ALU Operand B Multiplexer
    Mux2x1 mux_alu (
        .in1(RD2), 
        .in2(Imm_Ext), 
        .sel(ALUSrc), 
        .dataout(SrcB)
    );

    // ALU Control
    ALU_Control alu_ctrl (
        .ALUOp(ALUOp), 
        .func3(func3), 
        .func7(func7), 
        .ALUControl(ALUControl)
    );

    // ALU
    ALU alu_unit (
        .num1(RD1), 
        .num2(SrcB), 
        .ALUCtrl(ALUControl), 
        .result(ALUResult), 
        .z(Zero)
    );

    // Branch Logic (Jump OR (Branch AND Zero))
    assign PCSrc = Jump | (Branch & Zero);

    // Data Memory
    data_mem dmem (
        .clk(clk), 
        .mem_read(MemRead), 
        .mem_write(MemWrite), 
        .address(ALUResult), 
        .data_in(RD2), 
        .data_out(ReadData)
    );

    // Write-Back Multiplexer (3x1)
    Mux3x1 mux_wb (
        .in1(ALUResult), 
        .in2(ReadData), 
        .in3(PC_Plus_4),
        .sel(ResultSrc), 
        .dataout(Result)
    );

endmodule
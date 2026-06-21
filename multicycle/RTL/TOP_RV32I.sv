`timescale 1ns / 1ps

module Top_RV32I (
    input  logic clk,
    input  logic rst
);
    // PC & Memory Buses
    logic [31:0] PC, Next_PC, Adr;
    logic [31:0] Instr, Data, ReadData;
    
    // Decoder & Fields
    logic [6:0]  opcode, func7;
    logic [2:0]  func3;
    logic [4:0]  rs1, rs2, rd;
    
    // Control Flags
    logic        RegWrite, MemWrite, MemRead, Branch, Jump, IRWrite, PCUpdate, AdrSrc;
    logic [1:0]  ImmSrc, ALUOp, ResultSrc, ALUSrcA, ALUSrcB;
    
    // Interconnects
    logic [31:0] Imm_Ext;
    logic [31:0] Result; 
    logic [31:0] RD1, RD2;
    logic [31:0] A, WriteData;
    logic [31:0] SrcA, SrcB;
    logic [2:0]  ALUControl;
    logic [31:0] ALUResult, ALUOut;
    logic        Zero;
    
    logic PCWriteEnable;
    assign PCWriteEnable = PCUpdate | Jump | (Branch & Zero);

    // Program Counter Unit
    PC_32bit pc_unit (
        .clk(clk), 
        .rst(rst), 
        .EN(PCWriteEnable),
        .next_pc(Result), 
        .pc(PC)
    );

    // Address Source Multiplexer
    Mux2x1 AdrMux (
        .in1(PC), 
        .in2(ALUOut), // Routes from ALUOut register output per block diagram
        .sel(AdrSrc), 
        .dataout(Adr)
    );

    // Unified Instruction & Data Memory
    Inst_DataMem idmem (
        .clk(clk),            
        .rst(rst),            
        .WE(MemWrite), // Connected to Control Unit output            
        .Adr(Adr),     
        .WD(WriteData), // Connected to non-architectural WriteData register output     
        .RD(ReadData)
    );

    // Non-Architectural Pipeline Registers (Instr & Data)
    Instr ir (
        .ReadData(ReadData),
        .clk(clk), 
        .EN(IRWrite), 
        .outData(Instr)
    );
    
    Data dr (
        .ReadData(ReadData), 
        .clk(clk), 
        .outData(Data)
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

    // Old PC Pipeline Register
    logic [31:0] OldPC;
    always_ff @(posedge clk) begin
        if (IRWrite) OldPC <= PC;
    end

    // Non-Architectural Source Registers (A & WriteData)
    WriteReg wr (
        .ReadData1(RD1), 
        .ReadData2(RD2),  
        .clk(clk), 
        .outData1(A), 
        .outData2(WriteData)
    );

    // ALU Operand A Multiplexer
    Mux3x1 srcAmux (
        .in1(PC), 
        .in2(OldPC), 
        .in3(A), 
        .sel(ALUSrcA), 
        .dataout(SrcA)
    );

    // ALU Operand B Multiplexer
    Mux3x1 srcBMux (
        .in1(WriteData), 
        .in2(Imm_Ext),
        .in3(32'd4), 
        .sel(ALUSrcB), 
        .dataout(SrcB)
    );

    // ALU Control
    ALU_Control alu_ctrl (
        .ALUOp(ALUOp), 
        .func3(func3), 
        .func7(func7), 
        .ALUControl(ALUControl)
    );

    // Execution Core ALU
    ALU alu_unit (
        .num1(SrcA), 
        .num2(SrcB), 
        .ALUCtrl(ALUControl), 
        .result(ALUResult), 
        .z(Zero)
    );

    // Non-Architectural ALU Output Register
    ALUResult AluR (
        .AluResult(ALUResult), 
        .clk(clk), 
        .ALUOut(ALUOut)
    );

    // Write-Back Multiplexer (3x1)
    Mux3x1 mux_wb (
        .in1(ALUOut), 
        .in2(Data), 
        .in3(ALUResult),
        .sel(ResultSrc), 
        .dataout(Result)
    );

    // FSM Control Unit - Fully integrated with Clock, Reset and updated flags
    ControlUnit ctrl (
        .clk(clk),
        .rst(rst),
        .Op(opcode), 
        .RegWrite(RegWrite), 
        .ImmSrc(ImmSrc), 
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ResultSrc(ResultSrc), 
        .Branch(Branch), 
        .ALUOp(ALUOp),
        .Jump(Jump),
        .IRWrite(IRWrite),
        .PCUpdate(PCUpdate),
        .AdrSrc(AdrSrc)
    );

endmodule
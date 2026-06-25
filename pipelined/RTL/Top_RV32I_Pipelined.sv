`timescale 1ns / 1ps
//
// Pipelined RV32I Processor - Top Level

module Top_RV32I_Pipelined (
    input logic clk,
    input logic rst
);

    // =========================================================
    // FETCH STAGE
    // =========================================================
    logic [31:0] PC, Next_PC, PC_Plus_4;
    logic [31:0] InstrF;         // instruction direct from inst_mem
    logic        PCSrcE;         // branch/jump taken signal (from Execute)

    // Hazard Unit outputs
    logic StallF, StallD, FlushD, FlushE;

    // PC source: PC+4 (normal) or PCTargetE (branch/jump taken)
    Mux2x1 mux_pc (
        .in1(PC_Plus_4),
        .in2(PCTargetE),
        .sel(PCSrcE),
        .dataout(Next_PC)
    );

    // Program Counter (stalls when StallF=1)
    PC_32bit pc_unit (
        .clk(clk),
        .rst(rst),
        .EN(StallF),       // active-high stall
        .next_pc(Next_PC),
        .pc(PC)
    );

    // PC + 4 adder
    Add_32bit add_pc4 (
        .in1(PC),
        .in2(32'd4),
        .res(PC_Plus_4)
    );

    // Instruction Memory (combinational / async read)
    inst_mem imem (
        .PC(PC),
        .Instr(InstrF)
    );

    // =========================================================
    // FETCH ? DECODE PIPELINE REGISTER
    // =========================================================
    logic [31:0] InstrD, PCD, PCPlus4D;

    FetchStage_Reg FetchReg (
        .clk(clk),
        .rst(rst),
        .EN(StallD),       // hold when stalling
        .CLR(FlushD),      // flush on control hazard
        .instr_in(InstrF),
        .PC_old(PC),
        .PC_Plus4(PC_Plus_4),
        .Instr_D(InstrD),
        .PC_D(PCD),
        .PC_Plus4D(PCPlus4D)
    );

    // =========================================================
    // DECODE STAGE
    // =========================================================

    // Decode fields from D-stage instruction
    logic [6:0]  opcode, func7;
    logic [2:0]  func3;
    logic [4:0]  Rs1D, Rs2D, RdD;   // D-stage register addresses

    Decoder id (
        .instr(InstrD),    
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .rs1(Rs1D),        
        .rs2(Rs2D),
        .rd(RdD)
    );

    // Control signals decoded from D-stage opcode
    logic        RegWriteD, ALUSrcD, MemWriteD, BranchD, JumpD;
    logic [1:0]  ImmSrcD, ALUOpD, ResultSrcD;
    logic [2:0]  ALUControlD;

    ControlUnit ctrl (
        .Op(opcode),
        .RegWrite(RegWriteD),
        .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .MemRead(),          // not needed in pipeline; mem always reads
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .ALUOp(ALUOpD),
        .Jump(JumpD)
    );

    // ALU Control produces D-stage ALUControl, registered to ALUControlE
    ALU_Control alu_ctrl (
        .ALUOp(ALUOpD),
        .func3(func3),
        .func7(func7),
        .ALUControl(ALUControlD)  
    );

    logic [31:0] ImmExtD;

    ImmGen ig (
        .instr(InstrD),    
        .ImmSrc(ImmSrcD),
        .imm_ext(ImmExtD)
    );

    logic [31:0] RD1, RD2;
    logic        RegWriteW;
    logic [4:0]  RdW;
    logic [31:0] ResultW;

    Reg_File rf (
        .clk(clk),
        .rst(rst),
        .rs1(Rs1D),        
        .rs2(Rs2D),
        .rd(RdW),
        .wdata(ResultW),
        .RegWrite(RegWriteW),
        .outdata1(RD1),
        .outdata2(RD2)
    );

    // =========================================================
    // DECODE ? EXECUTE PIPELINE REGISTER
    // =========================================================
    logic        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
    logic [1:0]  ResultSrcE, ImmSrcE;    // FIXED: ImmSrcE is [1:0]
    logic [2:0]  ALUControlE;
    logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
    logic [4:0]  Rs1E, Rs2E, RdE;

    DecodeStage_Reg DecodeReg (
        .clk(clk),
        .rst(rst),
        .EN(StallD),
        .CLR(FlushE),             
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD), 
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD),
        .RD1(RD1),
        .RD2(RD2),
        .PCD(PCD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),
        .Rs1D(Rs1D),              
        .Rs2D(Rs2D),
        .RdD(RdD),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .ImmSrcE(ImmSrcE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE)
    );

    // =========================================================
    // EXECUTE STAGE
    // =========================================================
    logic [1:0]  ForwardAE, ForwardBE;
    logic [31:0] SrcAE, WriteDataE, SrcBE;
    logic [31:0] ALUResultE;
    logic        ZeroE;
    logic [31:0] PCTargetE;

    // Forward A mux: 00=RD1E, 01=ResultW(WB), 10=ALUResultM(MEM)
    logic [31:0] ALUResultM;   

    Mux3x1 muxAE (
        .in1(RD1E),
        .in2(ResultW),
        .in3(ALUResultM),
        .sel(ForwardAE),
        .dataout(SrcAE)
    );

    // Forward B mux:
    Mux3x1 muxBE (
        .in1(RD2E),
        .in2(ResultW),
        .in3(ALUResultM),
        .sel(ForwardBE),
        .dataout(WriteDataE)
    );

    // ALU Src B mux: register/forwarded data (0) or immediate (1)
    Mux2x1 mux_srcB (
        .in1(WriteDataE),
        .in2(ImmExtE),
        .sel(ALUSrcE),
        .dataout(SrcBE)
    );

    // Branch/jump target adder: PCE + ImmExtE
    Add_32bit add_target (
        .in1(PCE),
        .in2(ImmExtE),
        .res(PCTargetE)
    );

    // PCSrc: unconditional jump OR branch taken
    assign PCSrcE = JumpE | (BranchE & ZeroE);  

    ALU alu_unit (
        .num1(SrcAE),
        .num2(SrcBE),
        .ALUCtrl(ALUControlE),   
        .result(ALUResultE),
        .z(ZeroE)
    );

    // =========================================================
    // EXECUTE ? MEMORY PIPELINE REGISTER
    // =========================================================
    logic        RegWriteM, MemWriteM;
    logic [1:0]  ResultSrcM;
    logic [31:0] WriteDataM, PCPlus4M;
    logic [4:0]  RdM;

    ExecuteStage_Reg ExecReg (
        .clk(clk),
        .rst(rst),
        .CLR(1'b0),             
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .ALUResult(ALUResultE),
        .WriteDataE(WriteDataE),
        .PCPlus4E(PCPlus4E),
        .RdE(RdE),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM),
        .WriteDateM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM)
    );

    // =========================================================
    // MEMORY STAGE
    // =========================================================
    logic [31:0] ReadDataM;

    data_mem dmem (
        .clk(clk),
        .mem_write(MemWriteM),
        .address(ALUResultM),
        .data_in(WriteDataM),
        .data_out(ReadDataM)
    );

    // =========================================================
    // MEMORY ? WRITEBACK PIPELINE REGISTER
    // =========================================================
    logic [1:0]  ResultSrcW;
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;

    MemoryStage_Reg MemReg (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),  
        .ALUResultM(ALUResultM),
        .RD(ReadDataM),           
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),  
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .PCPlus4W(PCPlus4W),
        .RdW(RdW)
    );

    // =========================================================
    // WRITEBACK STAGE
    // =========================================================
    Mux3x1 mux_wb (
        .in1(ALUResultW),
        .in2(ReadDataW),
        .in3(PCPlus4W),
        .sel(ResultSrcW),
        .dataout(ResultW)
    );

    // =========================================================
    // HAZARD UNIT
    // =========================================================
    HazardUnit Hu (
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RdW(RdW),
        .Rs1D(Rs1D),         
        .Rs2D(Rs2D),         
        .RdE(RdE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcEo(ResultSrcE[0]),  
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),     
        .FlushE(FlushE)
    );

endmodule
`timescale 1ns / 1ps

module DecodeStage_Reg( 
    input clk, rst, EN, CLR,
    input RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
    input [2:0] ALUControlD,
    input [1:0] ResultSrcD, ImmSrcD,
    input [31:0] RD1, RD2, PCD, ImmExtD, PCPlus4D,
    input [4:0] Rs1D, Rs2D, RdD,
    output logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, 
    output logic [1:0] ResultSrcE, ImmSrcE,
    output logic [2:0] ALUControlE,
    output logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E,
    output logic [4:0] Rs1E, Rs2E, RdE
);
    always_ff @(posedge clk) begin
        if (rst || CLR) begin
            RegWriteE   <= 0;
            ResultSrcE  <= 0; 
            MemWriteE   <= 0;
            JumpE       <= 0;
            BranchE     <= 0;
            ALUControlE <= 0;
            ALUSrcE     <= 0;
            ImmSrcE     <= 0;
            RD1E        <= 32'd0;
            RD2E        <= 32'd0;
            PCE         <= 32'd0;
            ImmExtE     <= 32'd0;
            PCPlus4E    <= 32'd0;
            Rs1E        <= 5'd0;
            Rs2E        <= 5'd0;
            RdE         <= 5'd0;
        end
        else if (!EN) begin // FIXED: Standard active-high enable implementation
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;     
            MemWriteE   <= MemWriteD;      
            JumpE       <= JumpD;      
            BranchE     <= BranchD;      
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;       
            ImmSrcE     <= ImmSrcD;       
            RD1E        <= RD1;   
            RD2E        <= RD2;
            PCE         <= PCD;
            ImmExtE     <= ImmExtD;
            PCPlus4E    <= PCPlus4D;
            Rs1E        <= Rs1D;
            Rs2E        <= Rs2D;
            RdE         <= RdD;
        end
    end
endmodule
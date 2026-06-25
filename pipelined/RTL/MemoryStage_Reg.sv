`timescale 1ns / 1ps


module MemoryStage_Reg (
    input  logic        clk, rst,
    input  logic        RegWriteM,
    input  logic [1:0]  ResultSrcM,
    input  logic [31:0] ALUResultM,
    input  logic [31:0] RD,           // ReadData from data memory
    input  logic [31:0] PCPlus4M,
    input  logic [4:0]  RdM,
    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW,   
    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic [31:0] PCPlus4W,
    output logic [4:0]  RdW
);

    always_ff @(posedge clk) begin
        if (rst) begin
            RegWriteW  <= 1'b0;
            ResultSrcW <= 2'b00;
            ALUResultW <= 32'd0;
            ReadDataW  <= 32'd0;
            PCPlus4W   <= 32'd0;
            RdW        <= 5'd0;
        end else begin
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            ALUResultW <= ALUResultM;
            ReadDataW  <= RD;
            PCPlus4W   <= PCPlus4M;
            RdW        <= RdM;
        end
    end

endmodule
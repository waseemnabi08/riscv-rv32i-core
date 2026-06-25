`timescale 1ns / 1ps

module ControlUnit (
    input  logic [6:0] Op,
    output logic       RegWrite,
    output logic [1:0] ImmSrc,
    output logic       ALUSrc,
    output logic       MemWrite,
    output logic       MemRead,
    output logic [1:0] ResultSrc,
    output logic       Branch,
    output logic       Jump,
    output logic [1:0] ALUOp
);

    always_comb begin
        case (Op)
            // lw
            7'b0000011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                MemRead   = 1'b1;
                ResultSrc = 2'b01;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
                Jump      = 1'b0;
            end
            // I-type ALU (addi, etc.)
            7'b0010011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                MemRead   = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                ALUOp     = 2'b10;
                Jump      = 1'b0;
            end
            // sw
            7'b0100011: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b01;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b1;
                MemRead   = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
                Jump      = 1'b0;
            end
            // R-type
            7'b0110011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                MemRead   = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                ALUOp     = 2'b10;
                Jump      = 1'b0;
            end
            // beq
            7'b1100011: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b10;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                MemRead   = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b1;
                ALUOp     = 2'b01;
                Jump      = 1'b0;
            end
            // jal
            7'b1101111: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b11;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                MemRead   = 1'b0;
                ResultSrc = 2'b10;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
                Jump      = 1'b1;
            end
            default: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                MemRead   = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
                Jump      = 1'b0;
            end
        endcase
    end

endmodule
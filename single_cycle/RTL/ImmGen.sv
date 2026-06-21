`timescale 1ns / 1ps

module ImmGen(
    input  logic [31:0] instr,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] imm_ext
);

    always_comb begin
        case(ImmSrc)
            2'b00: imm_ext = {{20{instr[31]}}, instr[31:20]}; // I-Type
            2'b01: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-Type
            2'b10: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-Type
            2'b11: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-Type (jal)
            default: imm_ext = 32'bx;
        endcase
    end

endmodule
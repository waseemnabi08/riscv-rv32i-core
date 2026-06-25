`timescale 1ns / 1ps

// Fetch/Decode Pipeline Register
// EN  = StallD  : active-high stall; when 1, hold all outputs (do NOT update)
// CLR = FlushD  : active-high flush; when 1, clear to NOP (overrides EN)
module FetchStage_Reg (
    input  logic        clk, rst,
    input  logic        EN,           // StallD  - hold register on load-use stall
    input  logic        CLR,          // FlushD  - flush to NOP on control hazard
    input  logic [31:0] instr_in,
    input  logic [31:0] PC_old,
    input  logic [31:0] PC_Plus4,
    output logic [31:0] Instr_D,
    output logic [31:0] PC_D,
    output logic [31:0] PC_Plus4D
);

    always_ff @(posedge clk) begin
        if (rst || CLR) begin
            // Flush: insert NOP (all-zero instruction = addi x0,x0,0)
            Instr_D   <= 32'd0;
            PC_D      <= 32'd0;
            PC_Plus4D <= 32'd0;
        end else if (!EN) begin
            // Normal operation (no stall): capture Fetch stage values
            Instr_D   <= instr_in;
            PC_D      <= PC_old;
            PC_Plus4D <= PC_Plus4;
        end
        // EN=1 (stall): implicitly hold all outputs unchanged
    end

endmodule
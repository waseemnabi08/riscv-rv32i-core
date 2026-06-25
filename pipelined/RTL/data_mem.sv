`timescale 1ns / 1ps


module data_mem (
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] data_in,
    output logic [31:0] data_out
);

    logic [7:0] memory [1023:0];

    // Asynchronous read - always outputs word at address (no MemRead gate)
    assign data_out = {memory[address+3], memory[address+2],
                       memory[address+1], memory[address]};

    // Synchronous write - only when MemWrite asserted
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[address]   <= data_in[7:0];
            memory[address+1] <= data_in[15:8];
            memory[address+2] <= data_in[23:16];
            memory[address+3] <= data_in[31:24];
        end
    end

endmodule
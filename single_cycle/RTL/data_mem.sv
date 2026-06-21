`timescale 1ns / 1ps

module data_mem ( 
    input  logic        clk, 
    input  logic        mem_read,
    input  logic        mem_write, 
    input  logic [31:0] address,
    input  logic [31:0] data_in,
    output logic [31:0] data_out
);

    // 1 KB byte-addressable memory
    logic [7:0] memory [1023:0];

    // Synchronous Write
    always_ff @(posedge clk) begin
        if(mem_write) begin
            memory[address]     <= data_in[7:0];
            memory[address + 1] <= data_in[15:8];
            memory[address + 2] <= data_in[23:16];
            memory[address + 3] <= data_in[31:24];
        end
    end
        
    // Asynchronous Read
    always_comb begin
        if(mem_read) begin
            data_out[7:0]   = memory[address];
            data_out[15:8]  = memory[address + 1]; 
            data_out[23:16] = memory[address + 2];
            data_out[31:24] = memory[address + 3]; 
        end else begin
            data_out = 32'd0;
        end
    end

endmodule
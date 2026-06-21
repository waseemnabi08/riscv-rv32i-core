`timescale 1ns / 1ps

module PC_32bit ( 
    input  logic        clk,
    input  logic        rst,
    input  logic        EN,       // Enable signal used to control when PC updates
    input  logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0;          // Reset PC to address 0
        end else if (EN) begin
            pc <= next_pc;        // Capture next PC value only when EN is active
        end
    end
    
endmodule
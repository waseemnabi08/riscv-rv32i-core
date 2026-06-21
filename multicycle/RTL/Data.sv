`timescale 1ns / 1ps

module Data( 
    input  logic [31:0] ReadData,
    input  logic        clk,
    output logic [31:0] outData
);
    // Changed from invalid always_comb configuration to sequential register behavior
    always_ff @(posedge clk) begin
        outData <= ReadData;
    end
endmodule
`timescale 1ns / 1ps

module Reg_File (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  rs1,       
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wdata,
    input  logic        RegWrite,
    output logic [31:0] outdata1,  
    output logic [31:0] outdata2
);

    logic [31:0] regFile [31:0];

    // Hardwire x0 to 0
    assign outdata1 = (rs1 == 5'd0) ? 32'd0 : regFile[rs1];
    assign outdata2 = (rs2 == 5'd0) ? 32'd0 : regFile[rs2];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i = i + 1) begin
                regFile[i] <= 32'd0;
            end
        end else if (RegWrite && (rd != 5'd0)) begin
            regFile[rd] <= wdata;
        end
    end
     
endmodule
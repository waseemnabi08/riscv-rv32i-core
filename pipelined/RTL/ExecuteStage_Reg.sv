`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 03:46:48 PM
// Design Name: 
// Module Name: ExecuteStage_Reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ExecuteStage_Reg(input clk, rst, CLR,
                        input RegWriteE, MemWriteE,
                        input logic [1:0]  ResultSrcE,
                        input [31:0] ALUResult, WriteDataE,PCPlus4E,
                        input [4:0] RdE,
                        output logic RegWriteM, MemWriteM,
                        output logic [1:0] ResultSrcM,
                        output logic [31:0] ALUResultM, WriteDateM,PCPlus4M,
                        output logic [4:0] RdM                            
    );
    
    always_ff @(posedge clk) begin
        if(rst || CLR) begin
        RegWriteM <= 0;
        ResultSrcM <= 0;
        MemWriteM   <= 0;
        
        ALUResultM <= 32'd0;
        WriteDateM <= 32'd0;
        PCPlus4M   <= 32'd0;
        
        RdM  <= 5'd0; end
        
        
        else begin
        
        RegWriteM <= RegWriteE; 
        ResultSrcM <= ResultSrcE;
        MemWriteM   <= MemWriteE;
        
        ALUResultM <= ALUResult;
        WriteDateM <= WriteDataE;
        PCPlus4M   <= PCPlus4E;
        
        RdM  <= RdE; end
        
        end
        
        
    
endmodule

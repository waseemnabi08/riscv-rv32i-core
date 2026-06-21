`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 10:19:25 AM
// Design Name: 
// Module Name: ALUResult
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


module ALUResult(input [31:0] AluResult,
                 input clk,
                 output logic [31:0] ALUOut
    );
    
    always_ff  @(posedge clk) begin
        ALUOut <= AluResult; end
endmodule

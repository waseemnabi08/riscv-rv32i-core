`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 10:16:33 AM
// Design Name: 
// Module Name: WriteReg
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


module WriteReg(input [31:0] ReadData1, ReadData2,
                input clk,
                output logic [31:0] outData1, outData2
    );
    
    always_ff @(posedge clk) begin
        outData1 <= ReadData1;
        outData2 <= ReadData2;  
        end
endmodule

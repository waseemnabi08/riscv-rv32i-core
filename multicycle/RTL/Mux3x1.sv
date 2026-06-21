`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 12:30:51 AM
// Design Name: 
// Module Name: Mux3x1
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


module Mux3x1(input [31:0] in1, in2, in3,
              input [1:0] sel,
              output logic [31:0] dataout
    );
    
    always_comb begin
        case(sel)
            2'b00: dataout = in1;
            2'b01: dataout = in2;
            2'b10: dataout = in3;
            default: dataout = in1;
            endcase
         end
endmodule

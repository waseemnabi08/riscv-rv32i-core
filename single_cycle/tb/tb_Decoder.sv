`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 04:11:43 PM
// Design Name: 
// Module Name: tb_Decoder
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


module tb_Decoder;

    logic [31:0] instr;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [4:0] rs1, rs2, rd;
    logic [11:0] imm;
    
    Decoder uut(instr, func3, func7, rs1, rs2, rd, imm);
    
    initial begin        
        //R_type 
        instr = 32'h0x00940333;
        
        #5
        
        //S_type
        instr = 32'h0x0064a423;
        #5
        //I_type : lw
        instr = 32'h0xffc403a303;
        #5
        //b_type beq x0, x0, l1
        instr = 32'h0xFE000EE3;
        #5
        
        $finish;

        
    end

endmodule

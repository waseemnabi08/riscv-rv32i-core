`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 02:53:30 PM
// Design Name: 
// Module Name: tb_SignExt
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


module tb_SignExt;

    logic [31:0] instr;
    logic [31:0] imm_out;
    
    SignExt uut(.instr(instr), .imm_out(imm_out));
    
    initial begin
    
    instr = 32'h0x0064a423;  // S_Type
    
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 02:34:20 PM
// Design Name: 
// Module Name: SignExt
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


module SignExt( input [31:0] instr, 
                input [1:0] immSrc,
                output logic [31:0] imm_out
    );
    
//    parameter s_type = 7'b0100011;
//    parameter i_type = 7'b0000011;
//    parameter b_type = 7'b1100011;
    
//    logic [6:0] opcode;
//    assign opcode = instr[6:0];
    
    logic [11:0] i_imm;
    logic [11:0] store_im;
    logic [12:0] branch_im;
    
    assign i_imm = instr[31:20];
    assign store_im = {instr[31:25], instr[11:7]};
    assign branch_im = {instr[31],instr[7],instr[30:25], instr[11:8], 1'b0};
    
    
    //Immediate generation
    always_comb begin
        case(immSrc) 
            2'b01:
              imm_out = {{20{store_im[11]}}, store_im};
            2'b00:
               imm_out = {{20{i_imm[11]}}, i_imm};
            2'b10:
                imm_out = {{19{branch_im[12]}}, branch_im};
             default: 
                imm_out = 32'd0;
        endcase
        
      end
    
    
endmodule

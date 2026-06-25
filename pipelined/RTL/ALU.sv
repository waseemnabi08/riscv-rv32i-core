`timescale 1ns / 1ps

module ALU (
    input  logic [31:0] num1, num2,
    input  logic [2:0]  ALUCtrl,
    output logic [31:0] result,
    output logic        z
);

    always_comb begin
        case(ALUCtrl)
            3'b000: result = num1 + num2; // ADD
            3'b001: result = num1 - num2; // SUB
            3'b010: result = num1 & num2; // AND
            3'b011: result = num1 | num2; // OR
            3'b101: result = ($signed(num1) < $signed(num2)) ? 32'd1 : 32'd0; // SLT (Signed)
            default: result = 32'd0;
        endcase
        
        // Zero flag if the final ALU result is zero
        z = (result == 32'd0);
    end
        
endmodule
`timescale 1ns / 1ps

module ALU_Control(
    input  logic [1:0] ALUOp, 
    input  logic [2:0] func3, 
    input  logic [6:0] func7,
    output logic [2:0] ALUControl
);

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // Load/Store: ADD
            2'b01: ALUControl = 3'b001; // Branch: SUB
            2'b10: begin                // R-type / I-type Arithmetic
                case (func3)
                    3'b000: begin
                        if (func7[5] == 1'b1) ALUControl = 3'b001; // SUB
                        else                  ALUControl = 3'b000; // ADD
                    end
                    3'b111:  ALUControl = 3'b010; // AND
                    3'b110:  ALUControl = 3'b011; // OR
                    3'b100:  ALUControl = 3'b011; // XOR (Assuming mapped to OR temporarily)
                    3'b010:  ALUControl = 3'b101; // SLT
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
    
endmodule
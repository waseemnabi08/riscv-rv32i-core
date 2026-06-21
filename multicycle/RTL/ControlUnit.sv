`timescale 1ns / 1ps

module ControlUnit( 
    input  logic       clk,
    input  logic       rst,
    input  logic [6:0] Op,
    output logic       RegWrite,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic       MemWrite, IRWrite, AdrSrc, PCUpdate,
    output logic       MemRead,
    output logic [1:0] ResultSrc,
    output logic       Branch,
    output logic       Jump,
    output logic [1:0] ALUOp
);

    // State Parameter Declarations
    typedef enum logic [3:0] {
        Fetch     = 4'd0,
        Decode    = 4'd1,
        MemAdr    = 4'd2,
        Mem_Read  = 4'd3,
        MemWB     = 4'd4,
        Mem_Write = 4'd5,
        ExecuteR  = 4'd6,
        ALUWB     = 4'd7,
        ExecuteI  = 4'd8,
        JAL       = 4'd9,
        BEQ       = 4'd10
    } state_t;

    state_t current_S, next_S;
   
    // Synchronous State Transition
    always_ff @(posedge clk) begin
        if (rst) current_S <= Fetch; 
                else     current_S <= next_S;
    end
    
    // Combinational State Transition Logic
    always_comb begin
        next_S = Fetch; // Default fallback state
        case (current_S)
            Fetch: next_S = Decode;
            
            Decode: begin
                case (Op)
                    7'b0110011: next_S = ExecuteR;  // R-type
                    7'b0010011: next_S = ExecuteI;  // I-type ALU (addi)
                    7'b0000011: next_S = MemAdr;    // lw
                    7'b0100011: next_S = MemAdr;    // sw
                    7'b1100011: next_S = BEQ;       // beq
                    7'b1101111: next_S = JAL;       // jal
                    default:    next_S = Fetch;
                endcase
            end
            
            MemAdr: begin
                case (Op) 
                    7'b0000011: next_S = Mem_Read;  // lw 
                    7'b0100011: next_S = Mem_Write; // sw
                    default:    next_S = Fetch;
                endcase  
            end
             
            Mem_Read:  next_S = MemWB;
            MemWB:     next_S = Fetch;
            Mem_Write: next_S = Fetch;
            ExecuteR:  next_S = ALUWB;
            ALUWB:     next_S = Fetch;
            ExecuteI:  next_S = ALUWB;
            JAL:       next_S = ALUWB;
            BEQ:       next_S = Fetch;
            default:   next_S = Fetch;
        endcase
    end
                            
    // Combinational Output Control Logic
    always_comb begin
        RegWrite  = 1'b0;
        case (Op)
            7'b0100011: ImmSrc = 2'b01; // S-Type (sw)
            7'b1100011: ImmSrc = 2'b10; // B-Type (beq)
            7'b1101111: ImmSrc = 2'b11; // J-Type (jal)
            default:    ImmSrc = 2'b00; // I-Type (lw, addi, etc.)
        endcase
        ALUSrcA   = 2'b00;
        ALUSrcB   = 2'b00;
        MemWrite  = 1'b0;
        MemRead   = 1'b0;
        IRWrite   = 1'b0;
        AdrSrc    = 1'b0;
        PCUpdate  = 1'b0;
        ResultSrc = 2'b00;
        Branch    = 1'b0;
        Jump      = 1'b0;
        ALUOp     = 2'b00;

        case (current_S)
            Fetch: begin
                AdrSrc    = 1'b0;
                IRWrite   = 1'b1;
                ALUSrcA   = 2'b00;
                ALUSrcB   = 2'b10; // Selects constant value 4
                ALUOp     = 2'b00;
                ResultSrc = 2'b10; // Selects ALUResult directly
                PCUpdate  = 1'b1;
                MemRead   = 1'b1;
            end
             
            Decode: begin           
                ALUSrcA   = 2'b01; // Selects OldPC
                ALUSrcB   = 2'b01; // Selects ImmExt
                ALUOp     = 2'b00;
            end 

            MemAdr: begin           
                ALUSrcA   = 2'b10; // Selects register A
                ALUSrcB   = 2'b01; // Selects ImmExt
                ALUOp     = 2'b00;
            end    
                
            Mem_Read: begin           
                AdrSrc    = 1'b1;  // Selects ALUOut address source
                MemRead   = 1'b1;
            end 
                
            MemWB: begin           
                ResultSrc = 2'b01; // Selects Data register
                RegWrite  = 1'b1;
            end 
         
            Mem_Write: begin           
                AdrSrc    = 1'b1;  // Selects ALUOut address source
                MemWrite  = 1'b1; 
            end
            
            ExecuteR: begin           
                ALUSrcA   = 2'b10; // Selects register A
                ALUSrcB   = 2'b00; // Selects WriteData (register B)
                ALUOp     = 2'b10; // R-type control decoding
            end
            
            ALUWB: begin
                ResultSrc = 2'b00; // Selects ALUOut register
                RegWrite  = 1'b1; 
            end  
            
            ExecuteI: begin
                ALUSrcA   = 2'b10; // Selects register A
                ALUSrcB   = 2'b01; // Selects ImmExt
                ALUOp     = 2'b10; // I-type control decoding
            end
            
            JAL: begin
                ALUSrcA   = 2'b01; // Selects OldPC
                ALUSrcB   = 2'b10; // Selects constant value 4
                ALUOp     = 2'b00;
                ResultSrc = 2'b00; // Selects ALUOut
                PCUpdate  = 1'b1;  // PC <- jump target; OldPC+4 latched into ALUOut for ALUWB
            end

            BEQ: begin
                ALUSrcA   = 2'b10; // Selects register A
                ALUSrcB   = 2'b00; // Selects WriteData (register B)
                ALUOp     = 2'b01; // Subtraction check
                ResultSrc = 2'b00; // ALUOut = branch target (OldPC+ImmExt from Decode)
                Branch    = 1'b1;
            end    
        endcase
    end       
        
endmodule
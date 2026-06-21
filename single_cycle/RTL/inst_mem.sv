`timescale 1ns / 1ps

module inst_mem( 
    input  logic [31:0] PC,
    output logic [31:0] Instr
);

// PRogram : 

    //        addi t0, x0, 5      # 1. addi : Load 5 into t0
    //        addi t1, x0, 7      #    addi : Load 7 into t1
    //        add  t2, t0, t1     # 2. add  : t2 = 5 + 7 = 12
    //        sw   t2, 0(x0)      # 3. sw   : Store 12 into Memory[0]
    //        lw   t3, 0(x0)      # 4. lw   : Load Memory[0] into t3
    //        beq  t2, t3, pass   # 5. beq  : If t2(12) == t3(12), branch forward
    //    fail:
    //        jal  x0, fail       # 6. jal  : Trap here if branch failed
    //    pass:
    //        jal  x0, pass       # 7. jal  : Trap here if successful
    
    // PRogram Ends .........

    // Expanded to 32 bytes to hold 8 instructions
    logic [7:0] InstrMem [31:0];
    
    initial begin 
        // 1. 0x00500293 (addi t0, x0, 5)
        InstrMem[0] = 8'h93; InstrMem[1] = 8'h02; InstrMem[2] = 8'h50; InstrMem[3] = 8'h00; 
        
        // 2. 0x00700313 (addi t1, x0, 7) -> NEW
        InstrMem[4] = 8'h13; InstrMem[5] = 8'h03; InstrMem[6] = 8'h70; InstrMem[7] = 8'h00;
        
        // 3. 0x006283B3 (add t2, t0, t1) -> MODIFIED
        InstrMem[8] = 8'hB3; InstrMem[9] = 8'h83; InstrMem[10]= 8'h62; InstrMem[11]= 8'h00;
        
        // 4. 0x00702023 (sw t2, 0(x0))
        InstrMem[12]= 8'h23; InstrMem[13]= 8'h20; InstrMem[14]= 8'h70; InstrMem[15]= 8'h00;
        
        // 5. 0x00002E03 (lw t3, 0(x0))
        InstrMem[16]= 8'h03; InstrMem[17]= 8'h2E; InstrMem[18]= 8'h00; InstrMem[19]= 8'h00;
        
        // 6. 0x01C38463 (beq t2, t3, pass) -> Offset shifted to accommodate new instruction
        InstrMem[20]= 8'h63; InstrMem[21]= 8'h84; InstrMem[22]= 8'hC3; InstrMem[23]= 8'h01;
        
        // 7. 0x0000006F (jal x0, fail)
        InstrMem[24]= 8'h6F; InstrMem[25]= 8'h00; InstrMem[26]= 8'h00; InstrMem[27]= 8'h00;   

        // 8. 0x0000006F (jal x0, pass)
        InstrMem[28]= 8'h6F; InstrMem[29]= 8'h00; InstrMem[30]= 8'h00; InstrMem[31]= 8'h00;   
    end
    
    // Fetch 32-bit instruction (concatenating 4 bytes)
    assign Instr = {InstrMem[PC+3], InstrMem[PC+2], InstrMem[PC+1], InstrMem[PC]};

endmodule
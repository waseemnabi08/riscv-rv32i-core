`timescale 1ns / 1ps

module tb_Top_RV32I();

    // Testbench stimuli
    logic clk;
    logic rst;

    // Instantiate your Top-Level Multicycle Processor
    Top_RV32I dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation Sequence
    initial begin
        $display("==================================================");
        $display("   STARTING MULTICYCLE RISC-V CORE SIMULATION     ");
        $display("==================================================");
        
        // Pulse Reset to initialize the FSM to Fetch state and clear PC
        rst = 1;
        #15; 
        rst = 0;

        // Run the simulation for 40 clock cycles to allow the FSM 
        // to fully step through the instruction sequences.
        repeat (40) begin
            @(posedge clk);
            #1; // Brief settle delay to capture steady-state values post clock-edge
            
            // Track and display the controller state and execution details
            $display("Time: %0t | PC: 0x%h | State: %0d | Instr: 0x%h | ALUOut: 0x%h", 
                     $time, dut.PC, dut.ctrl.current_S, dut.Instr, dut.ALUOut);
                     
            // Optional: Trace Register File Writes
            if (dut.RegWrite && (dut.rd != 5'd0)) begin
                $display(">>> [REGISTER WRITE] Reg x%0d <= Data: 0x%h", dut.rd, dut.Result);
            end
            
            // Optional: Trace Memory Writes
            if (dut.MemWrite) begin
                $display(">>> [MEMORY WRITE] Addr: 0x%h <= Data: 0x%h", dut.Adr, dut.WriteData);
            end
        end

        $display("==================================================");
        $display("          SIMULATION TIMEOUT COMPLETE             ");
        $display("==================================================");
        $finish;
    end

    initial begin
        $dumpfile("multicycle_rv32i.vcd");
        $dumpvars(0, tb_Top_RV32I);
    end

endmodule
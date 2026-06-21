# 32-bit RV32I Processor Core Design & Verification

A comprehensive SystemVerilog realization of a 32-bit RISC-V processor core, demonstrating structural hardware design variations, pipeline optimizations, and verification methodologies across different execution models.

## Repository Architecture

This repository contains two distinct architectural implementations of the RV32I base integer instruction set, allowing for direct comparison of timing, area, and control complexity.

```
riscv-rv32i-core/
├── README.md               # Main documentation landing page
├── single_cycle/           # Single-Cycle Datapath Implementation
│   ├── RTL/
│   │   ├── Top_RV32I.sv
│   │   ├── ALU.sv
│   │   ├── ALU_Control.sv
│   │   ├── Reg_File.sv
│   │   ├── inst_mem.sv
│   │   ├── data_mem.sv
│   │   ├── Decoder.sv
│   │   └── ImmGen.sv
│   └── tb/
│       └── tb_Top_RV32I.sv
└── multicycle/             # Multicycle (Von Neumann) Datapath Implementation
    ├── RTL/
    │   ├── Top_RV32I.sv
    │   ├── ControlUnit.sv  # FSM Controller
    │   ├── Inst_DataMem.sv # Unified Memory Block
    │   ├── Instr.sv
    │   ├── Data.sv
    │   └── ... (Shared arithmetic units)
    └── tb/
        └── tb_Top_RV32I.sv
```

##  Supported Instruction Set Architecture (ISA)

Both processor implementations decode and execute a core foundational subset of the RV32I unprivileged specification, covering integer arithmetic, memory load/store operations, and conditional/unconditional control-flow tracking:

| Instruction | Type   | Opcode    | Functionality                                            |
|-------------|--------|-----------|----------------------------------------------------------|
| `add`       | R-Type | `0110011` | 32-bit register-to-register addition                     |
| `addi`      | I-Type | `0010011` | 32-bit addition with a sign-extended immediate           |
| `lw`        | I-Type | `0000011` | Load 32-bit word from memory array to Register File      |
| `sw`        | S-Type | `0100011` | Store 32-bit word from Register File to memory array     |
| `beq`       | B-Type | `1100011` | Conditional branch if source operand registers match     |
| `jal`       | J-Type | `1101111` | Unconditional jump to relative offset; stores PC+4 in `rd` |

## Implementation Architectures

### 1. Single-Cycle Implementation

The single-cycle core maps the entire instruction cycle (Fetch, Decode, Execute, Memory, Writeback) into a single long clock period ($CPI = 1.0$).

-   **Memory Structure**: Split Harvard architecture utilizing independent, dedicated Instruction Memory and Data Memory arrays.
-   **Memory Optimization**: Data Memory features highly optimized combinational (asynchronous) read behavior to prevent mid-cycle structural stalls, ensuring read data is written back to the Register File on the same rising clock edge.
-   **Arithmetic Core**: Employs an explicitly cast signed operator matrix (`$signed()`) within the ALU to handle correct evaluation metrics for RISC-V signed comparison instructions (`slt`).

### 2. Multicycle Implementation (Von Neumann)

The multicycle design refactors the datapath boundaries to run at a significantly higher maximum clock frequency ($F_{max}$) by splitting instruction execution into 3 to 5 clock steps depending on the instruction class.

-   **Memory Structure**: Shared, unified single-memory array handling both instructions and operational payloads over a single bidirectional data bus.
-   **Resource Reusability**: Optimizes hardware utilization by leveraging a single centralized ALU core to sequentially perform program counter increments, memory target calculations, and arithmetic transformations.
-   **Control Unit**: Driven by a robust combinational-to-sequential Finite State Machine (FSM) that sequences through Fetch, Decode, MemAdr, MemRead, MemWB, MemWrite, Execute, and ALUWB states while preventing hazardous latch inferences.
-   **Pipeline Buffers**: Uses non-architectural staging registers (`Instr`, `Data`, `A`, `WriteData`, `ALUOut`) to preserve signal values between discrete clock ticks.

## Single-Cycle vs. Multicycle Comparison

| Metric / Attribute          | Single-Cycle Core Model                  | Multicycle Core Model                        |
|-----------------------------|------------------------------------------|----------------------------------------------|
| **Memory Architecture**     | Split (Harvard Design)                   | Unified (Von Neumann Design)                 |
| **Shared ALU Utilization**  | Low (Requires multiple distinct adders)  | High (Single ALU reused across states)       |
| **CPI (Cycles Per Instruction)** | Fixed at exactly 1.0 CPI              | Variable (3 to 5 cycles per instruction)     |
| **Critical Path Delays**    | Bound by the complete sequential loop (`lw`) | Bound by the single longest execution stage  |
| **Target Clock Frequency**  | Lower (Constrained by single-cycle limits) | Significantly Higher                         |

## Verification & Test Simulation Matrix

Both core microarchitectures are functionally validated using custom SystemVerilog testbenches driving specialized machine-code program payloads pre-compiled to test resource constraints.

**Test Program Sequence Flow:**

1.  **State 1 & 2 (addi Verification)**: Initializes multiple individual registers sequentially with distinct non-zero values (`t0 = 5`, `t1 = 7`).
2.  **State 3 (add Verification)**: Tests register-file structural read ports by computing a sum of two separate registers (`t2 = t0 + t1 = 12`).
3.  **State 4 & 5 (sw / lw Cross-Verification)**: Writes the computed sum out to memory address index 0, clears interim lines, and reads the value back into register `t3` to confirm alignment and interface timing.
4.  **State 6 (beq Conditional Logic)**: Performs a dynamic equality check on the source register data (`t2 == t3`). If verification passes, it forces a forward PC shift over the error routine.
5.  **State 7 & 8 (jal Control Trap)**: Forces the execution path into a terminal infinite branch trap (`jal x0, pass`), locking the Program Counter in a successful execution loop to verify branch handling and target calculations.

### How to Run Simulation

1.  Create a new project in your EDA simulation utility.
2.  Add all design components found within the target directory's `RTL/` folder.
3.  Set the respective testbench inside the `tb/` directory as the top-level verification wrapper.
4.  Run the simulation. The output logs will track internal register modifications and flag hardware events via terminal printouts.

## Project Insights & Issues Resolved

-   **Synchronous vs. Asynchronous Reads**: Resolved a critical single-cycle structural delay where a clocked data-memory read delayed data-bus arrival by one step. Refactored memory architectures to use combinational assignment queries.
-   **FSM Optimization**: Eliminated racing conditions inside the multicycle controller block by structurally partitioning the sequential state update (`always_ff`) from the combinational control line decoder (`always_comb`).
-   **Signal Truncation Fixes**: Resolved structural truncation warnings by aligning control bus bit-widths (e.g., `ResultSrc` and `ALUControl`) across modules to prevent synthesis tool optimizations from pruning required lines.


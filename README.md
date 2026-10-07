# Single-Cycle RV32I Processor Core

A fully functional **32-bit Single-Cycle RISC-V Processor Core** designed and implemented in **SystemVerilog**.

The processor implements a subset of the **RISC-V RV32I Base Integer ISA** and includes a complete single-cycle datapath, instruction decoding, register file, ALU, immediate generation, instruction memory, data memory, and branch/jump control logic.

The design has been verified using **Verilator** and **Icarus Verilog (`iverilog`)** by executing compiled RISC-V machine-code instructions directly from simulated memory.

---

## Architecture

The processor follows a classic **single-cycle CPU architecture**, where each instruction is fetched, decoded, executed, and completed within a single clock cycle.

**CPI = 1.0**

```text
                         ┌──────────────────┐
                         │     PC + 4       │
                         │      Adder       │
                         └────────┬─────────┘
                                  │
                                  ▼
                            ┌───────────┐
                            │    MUX    │◄──────────────┐
                            │  PC Next  │               │
                            └─────┬─────┘               │
                                  │                     │
                                  ▼                     │
                         ┌─────────────────┐            │
                         │  PC Register    │            │
                         └────────┬────────┘            │
                                  │                     │
                                  ▼                     │
                         ┌─────────────────┐            │
                         │ Instruction     │            │
                         │ Memory          │            │
                         └────────┬────────┘            │
                                  │                     │
                                  ▼                     │
                         ┌─────────────────┐
                         │  Control Unit   │
                         └────────┬────────┘
                                  │
                ┌─────────────────┼──────────────────┐
                │                 │                  │
                ▼                 ▼                  ▼
        ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
        │ Register File│   │  Immediate   │   │ ALU Control  │
        │   x0 - x31   │   │   Generator  │   │              │
        └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
               │                  │                  │
               └──────────────────┼──────────────────┘
                                  ▼
                            ┌─────────────┐
                            │     ALU     │
                            └──────┬──────┘
                                   │
                                   ▼
                            ┌─────────────┐
                            │ Data Memory │
                            └──────┬──────┘
                                   │
                                   ▼
                            ┌─────────────┐
                            │ Writeback   │
                            │    MUX      │
                            └──────┬──────┘
                                   │
                                   └──────────► Register File
```

---

## Key Features

### 1. Strongly Typed SystemVerilog Design

The design uses SystemVerilog `enum` types for instruction opcodes and ALU operations.

This improves:

- Type safety
- Readability
- Maintainability
- Protection against accidental net-width mismatches

---

### 2. Two-Level Instruction Decoding

The control logic is divided into two stages.

#### Main Control Unit

The main control unit decodes the instruction opcode:

```text
inst[6:0]
```

and generates the primary datapath control signals:

- `reg_write`
- `alu_src`
- `mem_to_reg`
- `mem_read`
- `mem_write`
- `branch`
- `jump`

#### ALU Control Unit

The ALU control logic further decodes:

- ALU operation type
- `funct3`
- `funct7[5]`
- Instruction type

to generate the required ALU operation.

This allows the processor to correctly differentiate operations such as:

```text
ADD
SUB
ADDI
SLL
SRL
SRA
SLT
SLTU
```

---

## Processor Components

### ALU

The 32-bit ALU supports:

- Addition
- Subtraction
- Logical left shift (`SLL`)
- Logical right shift (`SRL`)
- Arithmetic right shift (`SRA`)
- Signed comparison (`SLT`)
- Unsigned comparison (`SLTU`)
- Bitwise AND
- Bitwise OR
- Bitwise XOR

The ALU also generates status information including:

- `zero`
- `sign`
- `overflow`
- `carry`
- `ltu`

---

### Register File

The processor contains:

```text
32 × 32-bit registers
```

from:

```text
x0 - x31
```

Register `x0` is hardwired to zero according to the RISC-V specification.

Therefore:

```text
x0 = 32'h00000000
```

regardless of attempted writes.

The register file supports:

- Two simultaneous read ports
- One write port
- Synchronous register writes

---

### Immediate Generator

The immediate generator supports the following RISC-V instruction formats:

- I-Type
- S-Type
- B-Type
- U-Type
- J-Type

Immediate values are extracted from the instruction and appropriately sign-extended to 32 bits.

---

### Instruction Memory

The instruction memory is implemented as a byte-addressed memory with word-aligned instruction access.

Instructions are loaded automatically using:

```systemverilog
$readmemh
```

The processor fetches instructions using the program counter:

```text
PC → Instruction Memory → Instruction
```

---

### Data Memory

The data memory provides:

- Asynchronous read access
- Synchronous write access
- Word-based data storage

This allows load/store instructions to operate within the single-cycle datapath.

---

# Supported RV32I Instructions

| Type | Instructions | Description |
|------|--------------|-------------|
| **R-Type** | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` | Register-register operations |
| **I-Type** | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI` | Register-immediate operations |
| **Load** | `LW` | Load word from memory |
| **Store** | `SW` | Store word to memory |
| **Branch** | `BEQ`, `BNE` | Conditional branching |
| **Jump** | `JAL` | Jump and link |
| **Upper Immediate** | `LUI` | Load upper immediate |

---

# Repository Structure

```text
risc-v/
│
├── rtl/
│   ├── alu.sv
│   ├── control_unit.sv
│   ├── imm.sv
│   ├── reg_file.sv
│   ├── instruction_mem.sv
│   ├── data_mem.sv
│   └── riscv_top.sv
│
├── tb/
│   ├── alu_tb.sv
│   ├── control_unit_tb.sv
│   ├── imm_tb.sv
│   ├── reg_file_tb.sv
│   └── riscv_top_tb.sv
│
├── program.hex
├── Makefile
└── README.md
```

### Directory Description

| Directory/File | Purpose |
|----------------|---------|
| `rtl/` | Processor RTL implementation |
| `tb/` | Unit and integration testbenches |
| `program.hex` | Machine-code program executed by the processor |
| `Makefile` | Build and simulation automation |
| `README.md` | Project documentation |

---

# Verification

The processor is verified using both:

- **Verilator**
- **Icarus Verilog**

The integration testbench loads machine-code instructions from:

```text
program.hex
```

and executes them directly through the processor.

---

## Verification Program

The test program performs the following sequence.

### 1. Load 10 into `x1`

```text
ADDI x1, x0, 10
```

Result:

```text
x1 = 10
```

### 2. Load 20 into `x2`

```text
ADDI x2, x0, 20
```

Result:

```text
x2 = 20
```

### 3. Add `x1` and `x2`

```text
ADD x3, x1, x2
```

Result:

```text
x3 = 30
```

### 4. Store the result into memory

```text
SW x3, 4(x0)
```

Result:

```text
MEM[4] = 30
```

### 5. Load the value back

```text
LW x4, 4(x0)
```

Result:

```text
x4 = 30
```

### 6. Test conditional branching

```text
BEQ x3, x4, 8
```

Since:

```text
x3 == x4
```

the branch is taken.

### 7. Execute the next instruction

```text
ADDI x5, x0, 42
```

Result:

```text
x5 = 42
```

---

# Running the Simulation

## Prerequisites

Install:

- SystemVerilog-compatible simulator
- Verilator
- Icarus Verilog
- GTKWave (optional, for waveform analysis)

The project was developed and tested under:

```text
Linux / WSL
Ubuntu
VS Code
```

---

## Verilator

Run:

```bash
verilator --binary -j 0 -Wall \
  -Wno-DECLFILENAME \
  -Wno-IMPORTSTAR \
  -Wno-UNUSEDSIGNAL \
  -Wno-UNUSEDPARAM \
  rtl/alu.sv \
  rtl/imm.sv \
  rtl/reg_file.sv \
  rtl/control_unit.sv \
  rtl/instruction_mem.sv \
  rtl/data_mem.sv \
  rtl/riscv_top.sv \
  tb/riscv_top_tb.sv \
  --top-module riscv_top_tb
```

Then run the generated simulation:

```bash
./obj_dir/Vriscv_top_tb
```

---

## Icarus Verilog

Compile the design:

```bash
iverilog -g2012 \
  rtl/alu.sv \
  rtl/imm.sv \
  rtl/reg_file.sv \
  rtl/control_unit.sv \
  rtl/instruction_mem.sv \
  rtl/data_mem.sv \
  rtl/riscv_top.sv \
  tb/riscv_top_tb.sv \
  -o sim_cpu
```

Run:

```bash
vvp sim_cpu
```

---

# Expected Verification Output

A successful simulation produces output similar to:

```text
=======================================================================
               STARTING SINGLE-CYCLE RISC-V CPU SIMULATION
=======================================================================

[Cycle 1] PC: 0x00000004 | Inst: 0x01400113 | x1:10 x2:0  x3:0  x4:0  x5:0
[Cycle 2] PC: 0x00000008 | Inst: 0x002081b3 | x1:10 x2:20 x3:0  x4:0  x5:0
[Cycle 3] PC: 0x0000000c | Inst: 0x00302223 | x1:10 x2:20 x3:30 x4:0  x5:0
[Cycle 4] PC: 0x00000010 | Inst: 0x00402203 | x1:10 x2:20 x3:30 x4:0  x5:0
[Cycle 5] PC: 0x00000014 | Inst: 0x00418463 | x1:10 x2:20 x3:30 x4:30 x5:0
[Cycle 6] PC: 0x0000001c | Inst: 0x00000000 | x1:10 x2:20 x3:30 x4:30 x5:0

=======================================================================
                       VERIFYING FINAL CPU STATE
=======================================================================

[SUCCESS] All Register, ALU, Memory (LW/SW), and Branch (BEQ) tests PASSED!

=======================================================================
```

---

# Verification Strategy

The project uses multiple levels of verification.

### Unit-Level Verification

Individual modules are tested independently:

```text
ALU
│
├── Arithmetic operations
├── Logical operations
├── Shift operations
├── Comparison operations
└── Status flags
```

```text
Register File
│
├── Register reads
├── Register writes
└── x0 hardwired-zero behavior
```

```text
Immediate Generator
│
├── I-Type
├── S-Type
├── B-Type
├── U-Type
└── J-Type
```

```text
Control Unit
│
└── Opcode → Control Signal verification
```

### Integration-Level Verification

The complete processor is tested by executing actual RISC-V machine instructions through the entire datapath:

```text
Machine Code
     ↓
Instruction Memory
     ↓
Instruction Decode
     ↓
Register File
     ↓
Immediate Generator
     ↓
ALU
     ↓
Data Memory
     ↓
Writeback
     ↓
Register File
```

This verifies that the individual modules work correctly together as a processor.

---

# Tools & Technologies

| Category | Tool |
|----------|------|
| HDL | SystemVerilog |
| ISA | RISC-V RV32I |
| Simulation | Verilator |
| Simulation | Icarus Verilog |
| Waveform Analysis | GTKWave |
| Development Environment | VS Code |
| OS | Linux / WSL Ubuntu |

---

# Design Highlights

Some of the key concepts implemented in this project include:

- Single-cycle CPU datapath
- RISC-V instruction decoding
- SystemVerilog `enum` types
- Two-level control decoding
- Register file design
- Immediate generation
- ALU design
- Branch decision logic
- Program counter logic
- Instruction memory
- Data memory
- Load/store operations
- Synchronous memory writes
- Asynchronous memory reads
- Machine-code execution
- RTL simulation and verification

---

# Future Work

The current processor provides a functional single-cycle RV32I implementation. Planned improvements include:

- [ ] Add `JALR`
- [ ] Add `AUIPC`
- [ ] Add additional branch instructions:
  - `BLT`
  - `BGE`
  - `BLTU`
  - `BGEU`
- [ ] Add byte and halfword loads:
  - `LB`
  - `LH`
  - `LBU`
  - `LHU`
- [ ] Add byte and halfword stores:
  - `SB`
  - `SH`
- [ ] Add official RISC-V architecture compliance testing
- [ ] Run the `riscv-arch-test` compliance suite
- [ ] Improve memory subsystem
- [ ] Add more comprehensive automated testbenches
- [ ] Add waveform-based debugging
- [ ] Convert the single-cycle processor into a **5-stage pipelined RV32I processor**
- [ ] Implement pipeline registers
- [ ] Add hazard detection
- [ ] Add data forwarding
- [ ] Handle control hazards and pipeline flushing

---

# Learning Outcomes

This project provided hands-on experience with:

- RISC-V ISA and instruction encoding
- Computer architecture
- Datapath and control-path design
- RTL design using SystemVerilog
- Hardware modularization
- Synchronous digital design
- Memory modeling
- Instruction decoding
- CPU verification
- Simulation and waveform debugging
- Linux/WSL-based HDL development

---

## Project Status

**Status: Functional and Verified**

The processor successfully executes the implemented RV32I instructions and has been verified through both unit-level and processor-level simulation.

---

## Author

**Ravi Teja**

Electronics & Communication Engineering

Interested in:

- Digital Design
- RTL Design
- Computer Architecture
- RISC-V
- SystemVerilog
- Verification
- VLSI
- Machine Learning / AI

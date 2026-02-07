# UVM Testbench Architecture Plan
**Project:** AXI4 → AXI-Lite → APB Bridge Verification  
**Author:** Nathan Carter  
**Date:** 2026-01-27  
**Status:** Architecture Planning Phase

---

## 1. Executive Summary

### Vision
Build a modular, scalable UVM verification environment that supports:
1. **Individual module verification** (`axi_lite_to_apb`, `axi_to_axi_lite`)
2. **Integration testing** (daisy-chained full path)
3. **Reusable verification components** for future projects

### Strategy
- **Phase 1:** Build standalone UVM TB for `axi_lite_to_apb` bridge
- **Phase 2:** Build standalone UVM TB for `axi_to_axi_lite` converter
- **Phase 3:** Integrate both with full AXI4 → APB4 verification

---

## 2. System Architecture

### 2.1 Target Design Modules

```
┌─────────────────────────────────────────────────────────────────┐
│                    FULL INTEGRATED SYSTEM                       │
│                                                                 │
│  ┌──────────┐      ┌──────────┐      ┌─────────────────┐     │
│  │   AXI4   │─────→│   AXI    │─────→│   AXI-Lite      │     │
│  │  Master  │ AXI4 │    to    │ Lite │      to         │ APB4│
│  │          │      │ AXI-Lite │      │      APB        │─────→
│  └──────────┘      └──────────┘      └─────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Module Breakdown:
├── axi_to_axi_lite      (deps/axi/src/axi_to_axi_lite.sv)
│   ├── Converts AXI4 Full → AXI4-Lite
│   ├── Handles burst splitting
│   ├── Filters ATOPs
│   └── ID reflection/management
│
└── axi_lite_to_apb      (dut_axi_lite/axi_lite_to_apb.sv) ⭐ PRIMARY DUT
    ├── Converts AXI4-Lite → APB4
    ├── Supports multiple APB slaves
    ├── Address decoding
    └── Request/response pipelining
```

### 2.2 Verification Phases

| Phase | DUT | Input Protocol | Output Protocol | Status |
|-------|-----|----------------|-----------------|--------|
| **1** | `axi_lite_to_apb` | AXI4-Lite | APB4 | **START HERE** ⭐ |
| **2** | `axi_to_axi_lite` | AXI4 Full | AXI4-Lite | Future |
| **3** | Integrated System | AXI4 Full | APB4 | Future |

---

## 3. UVM Directory Structure

### 3.1 Recommended Layout (AMD/Industry Standard Style)

```
AXI_TO_APB_BRIDGE_UVM/
├── tb/                              # Testbench root
│   ├── agents/                      # Reusable UVM agents/VCs
│   │   ├── axi_lite_agent/          # AXI4-Lite agent
│   │   │   ├── axi_lite_pkg.sv                    # Package file (includes all below)
│   │   │   ├── axi_lite_if.sv                     # Interface (outside package)
│   │   │   ├── axi_lite_transaction.sv            # Transaction class ⭐
│   │   │   ├── axi_lite_config.sv                 # Agent configuration
│   │   │   ├── axi_lite_sequencer.sv              # Sequencer
│   │   │   ├── axi_lite_driver.sv                 # Driver
│   │   │   ├── axi_lite_monitor.sv                # Monitor
│   │   │   ├── axi_lite_coverage.sv               # Coverage collector (optional)
│   │   │   ├── axi_lite_agent.sv                  # Agent (top-level)
│   │   │   └── sequences/                         # Sequence library
│   │   │       ├── axi_lite_base_seq.sv
│   │   │       ├── axi_lite_random_seq.sv
│   │   │       ├── axi_lite_write_seq.sv
│   │   │       ├── axi_lite_read_seq.sv
│   │   │       └── axi_lite_directed_seq.sv
│   │   │
│   │   ├── apb_agent/               # APB4 agent
│   │   │   ├── apb_pkg.sv                         # Package file
│   │   │   ├── apb_if.sv                          # Interface (outside package)
│   │   │   ├── apb_transaction.sv                 # Transaction class ⭐
│   │   │   ├── apb_config.sv                      # Agent configuration
│   │   │   ├── apb_sequencer.sv                   # Sequencer
│   │   │   ├── apb_driver.sv                      # Driver (slave/master modes)
│   │   │   ├── apb_monitor.sv                     # Monitor
│   │   │   ├── apb_coverage.sv                    # Coverage collector (optional)
│   │   │   ├── apb_agent.sv                       # Agent (top-level)
│   │   │   └── sequences/                         # Sequence library
│   │   │       ├── apb_slave_seq.sv
│   │   │       ├── apb_master_seq.sv
│   │   │       └── apb_error_seq.sv
│   │   │
│   │   └── axi_agent/               # AXI4 Full agent (Phase 2)
│   │       └── [similar structure]
│   │
│   ├── env/                         # Test environments
│   │   ├── axi_lite_to_apb_env/     # Phase 1 environment ⭐
│   │   │   ├── axi_lite_to_apb_env_pkg.sv
│   │   │   ├── axi_lite_to_apb_env.sv
│   │   │   ├── axi_lite_to_apb_virtual_sequencer.sv  # Coordinates sequences
│   │   │   ├── axi_lite_to_apb_scoreboard.sv
│   │   │   ├── axi_lite_to_apb_predictor.sv          # Uses golden model
│   │   │   ├── axi_lite_to_apb_golden_model.sv       # DPI-C wrapper
│   │   │   └── axi_lite_to_apb_coverage.sv
│   │   │
│   │   ├── axi_to_axi_lite_env/     # Phase 2 environment
│   │   │   └── [similar structure]
│   │   │
│   │   └── integrated_env/          # Phase 3 full system
│   │       ├── integrated_virtual_sequencer.sv  # Top-level coordination
│   │       └── [combines both envs]
│   │
│   ├── tests/                       # Test library
│   │   ├── axi_lite_to_apb_tests/   # Phase 1 tests
│   │   │   ├── axi_lite_to_apb_base_test.sv
│   │   │   ├── axi_lite_to_apb_sanity_test.sv
│   │   │   ├── axi_lite_to_apb_random_test.sv
│   │   │   ├── axi_lite_to_apb_stress_test.sv
│   │   │   ├── axi_lite_to_apb_error_test.sv
│   │   │   └── axi_lite_to_apb_pipeline_test.sv
│   │   │
│   │   ├── axi_to_axi_lite_tests/   # Phase 2 tests
│   │   └── integrated_tests/        # Phase 3 tests
│   │
│   ├── top/                         # Top-level testbench files
│   │   ├── tb_axi_lite_to_apb_top.sv
│   │   ├── tb_axi_to_axi_lite_top.sv
│   │   └── tb_integrated_top.sv
│   │
│   ├── common/                      # Shared utilities
│   │   ├── tb_pkg.sv
│   │   ├── tb_params.sv
│   │   └── tb_utils.sv
│   │
│   ├── ral/                         # Register Abstraction Layer (Optional)
│   │   ├── apb_reg_model.sv         # RAL for APB slave registers
│   │   ├── apb_reg_adapter.sv       # APB RAL adapter
│   │   └── reg_sequences/           # Register access sequences
│   │       ├── reg_hw_reset_seq.sv
│   │       ├── reg_bit_bash_seq.sv
│   │       └── reg_access_seq.sv
│   │
│   └── dpi/                         # DPI-C Components
│       ├── memory/                  # Memory model (for APB slave)
│       │   ├── dpi_memory.sv
│       │   ├── dpi_memory.h
│       │   └── dpi_memory.c
│       └── golden_model/            # Golden reference model ⭐
│           ├── bridge_golden_model.sv   # SV wrapper
│           ├── bridge_golden_model.h    # C header
│           ├── bridge_golden_model.c    # C implementation
│           └── Makefile                 # Compile C code
│
├── sim/                             # Simulation scripts
│   ├── Makefile.uvm                 # UVM-specific Makefile
│   ├── compile_uvm.f                # UVM compilation filelist
│   ├── files/
│   │   └── uvm/
│   │       ├── agents.f
│   │       ├── env.f
│   │       └── tests.f
│   └── scripts/
│       ├── run_uvm_test.sh
│       └── regression.sh
│
└── docs/
    ├── UVM_TESTBENCH_ARCHITECTURE.md  # This document
    ├── VERIFICATION_PLAN.md
    └── COVERAGE_PLAN.md
```

---

## 4. Advanced UVM Components: When and How to Use

### 4.1 Virtual Sequencer

**What is it?**
A virtual sequencer coordinates multiple sequencers to orchestrate complex, multi-agent scenarios.

**Where it fits in your project:**

```
Environment
├── AXI-Lite Agent (with sequencer)
├── APB Agent (with sequencer)
└── Virtual Sequencer  ← Coordinates both
    ├── Reference to AXI-Lite sequencer
    └── Reference to APB sequencer (for verification sequences)
```

**When to use:**
- ✅ **Phase 1 (Optional but recommended):** Coordinate AXI-Lite stimulus with expected APB responses
- ✅ **Phase 2:** Coordinate AXI4 burst sequences with expected AXI-Lite splits
- ✅ **Phase 3 (Essential):** Coordinate full AXI4 → APB4 end-to-end scenarios

**Example Use Case:**
```systemverilog
class axi_lite_to_apb_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_lite_to_apb_virtual_sequencer)
  
  // Handles to sub-sequencers
  axi_lite_sequencer  axi_lite_seqr;
  apb_sequencer       apb_seqr;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

// Virtual sequence using it
class coordinated_seq extends uvm_sequence;
  `uvm_object_utils(coordinated_seq)
  
  axi_lite_to_apb_virtual_sequencer v_seqr;
  
  task body();
    // Start APB slave responsive sequence
    apb_responsive_seq apb_seq = apb_responsive_seq::type_id::create("apb_seq");
    apb_seq.start(v_seqr.apb_seqr);
    
    // Now send AXI-Lite transactions
    axi_lite_random_seq axi_seq = axi_lite_random_seq::type_id::create("axi_seq");
    axi_seq.start(v_seqr.axi_lite_seqr);
  endtask
endclass
```

**Benefits:**
- Synchronize stimulus across multiple interfaces
- Create complex test scenarios
- Centralized control of test flow

---

### 4.2 Register Abstraction Layer (RAL)

**What is it?**
RAL provides an abstraction for reading/writing registers, with built-in checking and coverage.

**Where it fits in your project:**

```
Your DUT (axi_lite_to_apb) is NOT a register block, it's a protocol converter.
However, RAL is useful for:
├── Verifying APB slave devices with registers (e.g., apb_regs from deps/apb)
├── Testing with register-based APB slaves
└── Phase 3: Accessing iDMA configuration registers
```

**When to use:**
- ❌ **Phase 1 (Not needed):** Your bridge DUT has no registers - it's pure protocol conversion
- ⚠️ **Phase 1 (Optional):** If you want to test with `apb_regs` module as an APB slave
- ✅ **Phase 2/3:** When integrating with iDMA (which has configuration registers)

**If you add RAL for APB slave registers:**

```systemverilog
// Register model for an APB slave register block
class apb_reg_block extends uvm_reg_block;
  rand uvm_reg control_reg;
  rand uvm_reg status_reg;
  rand uvm_reg data_reg;
  
  function new(string name = "apb_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    // Define register map
    control_reg = uvm_reg::type_id::create("control_reg");
    control_reg.configure(this, null, "");
    control_reg.build();
    // ... define fields, addresses, etc.
  endfunction
endclass

// RAL adapter to convert register operations to APB transactions
class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)
  
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_transaction apb_txn = apb_transaction::type_id::create("apb_txn");
    apb_txn.addr = rw.addr;
    apb_txn.data = rw.data;
    apb_txn.is_write = (rw.kind == UVM_WRITE);
    return apb_txn;
  endfunction
  
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_transaction apb_txn;
    $cast(apb_txn, bus_item);
    rw.addr = apb_txn.addr;
    rw.data = apb_txn.data;
    rw.status = UVM_IS_OK;
  endfunction
endclass
```

**Integrated into environment:**
```systemverilog
class axi_lite_to_apb_env extends uvm_env;
  // Agents
  axi_lite_agent  axi_agt;
  apb_agent       apb_agt;
  
  // RAL (optional - for register-based APB slaves)
  apb_reg_block   reg_model;
  apb_reg_adapter reg_adapter;
  uvm_reg_predictor#(apb_transaction) reg_predictor;
  
  virtual function void connect_phase(uvm_phase phase);
    if (cfg.use_ral) begin
      // Connect RAL to APB agent
      reg_adapter = apb_reg_adapter::type_id::create("reg_adapter");
      reg_model.default_map.set_sequencer(apb_agt.sequencer, reg_adapter);
      
      // Connect predictor
      reg_predictor.map = reg_model.default_map;
      reg_predictor.adapter = reg_adapter;
      apb_agt.monitor.ap.connect(reg_predictor.bus_in);
    end
  endfunction
endclass
```

**Benefits:**
- Built-in register access sequences (bit bash, walking 1s/0s, etc.)
- Automatic coverage of register fields
- Abstraction from protocol details
- Mirror values for checking

**Recommendation for your project:**
- **Skip RAL in Phase 1** unless you specifically want to test with `apb_regs` module
- **Consider RAL in Phase 3** for iDMA integration

---

### 4.3 DPI-C Memory Model

**What is it?**
DPI-C allows calling C/C++ code from SystemVerilog, useful for high-performance memory models.

**Where it fits in your project:**

```
APB Agent
├── APB Driver (Slave mode)
│   └── Memory Model ← Can be DPI-C or SystemVerilog
│       ├── Option A: SV associative array (simple, slower)
│       └── Option B: DPI-C memory (faster, more realistic)
```

**When to use:**
- ⚠️ **Phase 1 (Optional):** If you need large APB slave memory or care about performance
- ✅ **Phase 3 (Recommended):** For realistic memory modeling in full system tests
- ✅ **Stress testing:** When running millions of transactions

**Implementation:**

**C Side (`tb/dpi/dpi_memory.c`):**
```c
#include "dpi_memory.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MEM_SIZE (1024 * 1024 * 16)  // 16MB
static uint8_t *memory = NULL;

void dpi_mem_init() {
    if (memory == NULL) {
        memory = (uint8_t*)calloc(MEM_SIZE, sizeof(uint8_t));
    }
}

void dpi_mem_write(uint32_t addr, uint32_t data, uint8_t strb) {
    if (addr >= MEM_SIZE) return;
    
    if (strb & 0x1) memory[addr + 0] = (data >>  0) & 0xFF;
    if (strb & 0x2) memory[addr + 1] = (data >>  8) & 0xFF;
    if (strb & 0x4) memory[addr + 2] = (data >> 16) & 0xFF;
    if (strb & 0x8) memory[addr + 3] = (data >> 24) & 0xFF;
}

uint32_t dpi_mem_read(uint32_t addr) {
    if (addr >= MEM_SIZE) return 0xDEADBEEF;
    
    uint32_t data = 0;
    data |= ((uint32_t)memory[addr + 0]) <<  0;
    data |= ((uint32_t)memory[addr + 1]) <<  8;
    data |= ((uint32_t)memory[addr + 2]) << 16;
    data |= ((uint32_t)memory[addr + 3]) << 24;
    return data;
}

void dpi_mem_clear() {
    if (memory != NULL) {
        memset(memory, 0, MEM_SIZE);
    }
}
```

**Header (`tb/dpi/dpi_memory.h`):**
```c
#ifndef DPI_MEMORY_H
#define DPI_MEMORY_H

#include <stdint.h>

void dpi_mem_init();
void dpi_mem_write(uint32_t addr, uint32_t data, uint8_t strb);
uint32_t dpi_mem_read(uint32_t addr);
void dpi_mem_clear();

#endif
```

**SystemVerilog Wrapper (`tb/dpi/dpi_memory.sv`):**
```systemverilog
package dpi_memory_pkg;
  
  // Import DPI-C functions
  import "DPI-C" function void dpi_mem_init();
  import "DPI-C" function void dpi_mem_write(
    input int unsigned addr,
    input int unsigned data,
    input byte unsigned strb
  );
  import "DPI-C" function int unsigned dpi_mem_read(
    input int unsigned addr
  );
  import "DPI-C" function void dpi_mem_clear();
  
  // Wrapper class for UVM usage
  class dpi_memory_model;
    
    function new();
      dpi_mem_init();
    endfunction
    
    function void write(int unsigned addr, int unsigned data, byte strb);
      dpi_mem_write(addr, data, strb);
    endfunction
    
    function int unsigned read(int unsigned addr);
      return dpi_mem_read(addr);
    endfunction
    
    function void clear();
      dpi_mem_clear();
    endfunction
    
  endclass
  
endpackage
```

**Using in APB Driver:**
```systemverilog
class apb_driver extends uvm_driver #(apb_transaction);
  
  // Choose memory model type
  dpi_memory_pkg::dpi_memory_model mem;  // DPI-C version
  // OR
  // bit [31:0] mem[bit[31:0]];          // SV associative array
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mem = new();  // Initialize DPI-C memory
  endfunction
  
  task drive_apb_read(apb_transaction txn);
    @(posedge vif.clk);
    vif.pready  <= 1'b0;
    vif.prdata  <= 'x;
    vif.pslverr <= 1'b0;
    
    // Read from DPI-C memory
    repeat (cfg.read_delay) @(posedge vif.clk);
    vif.prdata  <= mem.read(txn.addr);
    vif.pready  <= 1'b1;
    @(posedge vif.clk);
  endtask
  
  task drive_apb_write(apb_transaction txn);
    @(posedge vif.clk);
    vif.pready <= 1'b0;
    
    repeat (cfg.write_delay) @(posedge vif.clk);
    mem.write(txn.addr, txn.data, txn.strb);
    vif.pready  <= 1'b1;
    vif.pslverr <= 1'b0;
    @(posedge vif.clk);
  endtask
  
endclass
```

**Compilation with DPI-C:**
```makefile
# In Makefile.uvm
VCS_DPI_FLAGS = \
    -CFLAGS "-I$(PWD)/../tb/dpi" \
    -LDFLAGS "-L$(PWD)/../tb/dpi -ldpi_memory"

# Compile C code
../tb/dpi/dpi_memory.so: ../tb/dpi/dpi_memory.c
	gcc -shared -fPIC -o $@ $<

compile: ../tb/dpi/dpi_memory.so
	vcs $(VCS_UVM_FLAGS) $(VCS_DPI_FLAGS) ...
```

**Benefits:**
- **Fast:** C memory operations are much faster than SV
- **Large memory:** Can model GBs of memory efficiently
- **Realistic:** Models actual memory behavior
- **Reusable:** Same memory model across projects

**Recommendation for your project:**
- **Start simple in Phase 1:** Use SV associative array
- **Upgrade if needed:** Add DPI-C memory if performance becomes issue
- **Use for Phase 3:** For full system stress testing

---

### 4.4 DPI-C Golden Reference Model ⭐

**What is it?**
A C/C++ implementation of your DUT's expected behavior, used to generate expected outputs for scoreboard comparison.

**Why use C for the golden model?**
1. ✅ **Performance:** C is much faster than SystemVerilog for complex algorithms
2. ✅ **Reusability:** Same model can be used standalone, in other testbenches, or for firmware development
3. ✅ **Simplicity:** Behavioral models are often easier to write in C
4. ✅ **Debugging:** C debugging tools (gdb) are more mature
5. ✅ **Specification:** C model can BE the specification

**Where it fits in your verification:**

```
┌─────────────────────────────────────────────────────────────┐
│                    VERIFICATION FLOW                        │
│                                                             │
│  AXI-Lite Monitor                                          │
│         │                                                   │
│         │ (observed txn)                                   │
│         ▼                                                   │
│  ┌──────────────────┐                                      │
│  │   Predictor      │                                      │
│  │  ┌────────────┐  │                                      │
│  │  │  Golden    │  │  ◄── DPI-C Reference Model          │
│  │  │  Model     │  │                                      │
│  │  │  (C code)  │  │                                      │
│  │  └────────────┘  │                                      │
│  │        │         │                                      │
│  │        ▼         │                                      │
│  │  Expected APB txn│                                      │
│  └────────┬─────────┘                                      │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────┐                                   │
│  │   Scoreboard       │                                   │
│  │  Compare:          │                                   │
│  │  Expected vs Actual│◄─── Actual APB txn (from monitor)│
│  └────────────────────┘                                   │
└─────────────────────────────────────────────────────────────┘
```

**Architecture for your bridge:**

Your golden model will:
1. Take AXI-Lite transaction as input
2. Perform address decode (same logic as DUT)
3. Generate expected APB request
4. Generate expected AXI-Lite response
5. Return these to the predictor

---

#### 4.4.1 C Implementation

**Header File (`tb/dpi/golden_model/bridge_golden_model.h`):**
```c
#ifndef BRIDGE_GOLDEN_MODEL_H
#define BRIDGE_GOLDEN_MODEL_H

#include <stdint.h>
#include <stdbool.h>

// Transaction types matching SystemVerilog
typedef enum {
    TXN_WRITE = 0,
    TXN_READ  = 1
} txn_type_t;

typedef enum {
    RESP_OKAY   = 0x0,
    RESP_EXOKAY = 0x1,
    RESP_SLVERR = 0x2,
    RESP_DECERR = 0x3
} axi_resp_t;

// Address range for APB slaves
typedef struct {
    uint32_t base_addr;
    uint32_t size;
} apb_slave_range_t;

// Expected APB transaction
typedef struct {
    uint32_t    paddr;
    uint32_t    pwdata;
    uint8_t     pstrb;
    bool        pwrite;
    uint8_t     psel_idx;     // Which slave (0 to N-1)
    bool        is_valid;     // Is this a valid transaction?
} apb_expected_t;

// Expected AXI-Lite response
typedef struct {
    uint32_t    rdata;        // For reads
    axi_resp_t  resp;         // OKAY, SLVERR, DECERR
} axi_resp_expected_t;

// Initialize golden model with address map
void golden_model_init(
    const apb_slave_range_t *slave_ranges,
    uint32_t num_slaves
);

// Process AXI-Lite transaction, return expected APB + AXI response
void golden_model_process(
    txn_type_t  txn_type,
    uint32_t    addr,
    uint32_t    wdata,
    uint8_t     wstrb,
    uint32_t    read_data,       // Input: data that will be read from APB
    apb_expected_t     *apb_out, // Output: expected APB transaction
    axi_resp_expected_t *axi_out // Output: expected AXI-Lite response
);

// Cleanup
void golden_model_cleanup();

#endif // BRIDGE_GOLDEN_MODEL_H
```

**C Implementation (`tb/dpi/golden_model/bridge_golden_model.c`):**
```c
#include "bridge_golden_model.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static apb_slave_range_t *g_slave_ranges = NULL;
static uint32_t g_num_slaves = 0;

void golden_model_init(
    const apb_slave_range_t *slave_ranges,
    uint32_t num_slaves
) {
    // Allocate and copy slave ranges
    g_num_slaves = num_slaves;
    g_slave_ranges = (apb_slave_range_t*)malloc(
        num_slaves * sizeof(apb_slave_range_t)
    );
    memcpy(g_slave_ranges, slave_ranges, 
           num_slaves * sizeof(apb_slave_range_t));
    
    printf("[Golden Model] Initialized with %d APB slaves\n", num_slaves);
    for (uint32_t i = 0; i < num_slaves; i++) {
        printf("  Slave %d: 0x%08X - 0x%08X\n", i,
               g_slave_ranges[i].base_addr,
               g_slave_ranges[i].base_addr + g_slave_ranges[i].size - 1);
    }
}

// Address decode function (matches DUT logic)
static int32_t decode_address(uint32_t addr) {
    for (uint32_t i = 0; i < g_num_slaves; i++) {
        uint32_t base = g_slave_ranges[i].base_addr;
        uint32_t end = base + g_slave_ranges[i].size;
        
        if (addr >= base && addr < end) {
            return (int32_t)i;  // Found matching slave
        }
    }
    return -1;  // No match (DECERR)
}

void golden_model_process(
    txn_type_t  txn_type,
    uint32_t    addr,
    uint32_t    wdata,
    uint8_t     wstrb,
    uint32_t    read_data,
    apb_expected_t     *apb_out,
    axi_resp_expected_t *axi_out
) {
    // Initialize outputs
    memset(apb_out, 0, sizeof(apb_expected_t));
    memset(axi_out, 0, sizeof(axi_resp_expected_t));
    
    // Perform address decode
    int32_t slave_idx = decode_address(addr);
    
    if (slave_idx < 0) {
        // Address decode error
        apb_out->is_valid = false;
        axi_out->resp = RESP_DECERR;
        axi_out->rdata = 0xDEADBEEF;  // Error pattern
        
        printf("[Golden Model] DECERR: addr=0x%08X not in any slave range\n", 
               addr);
        return;
    }
    
    // Valid address - generate expected APB transaction
    apb_out->is_valid = true;
    apb_out->paddr = addr;
    apb_out->pwrite = (txn_type == TXN_WRITE);
    apb_out->psel_idx = (uint8_t)slave_idx;
    
    if (txn_type == TXN_WRITE) {
        // Write transaction
        apb_out->pwdata = wdata;
        apb_out->pstrb = wstrb;
        
        // Expected AXI response for write
        axi_out->resp = RESP_OKAY;  // Assuming APB slave doesn't error
        axi_out->rdata = 0;         // Don't care for writes
        
        printf("[Golden Model] WRITE: addr=0x%08X data=0x%08X strb=0x%X slave=%d\n",
               addr, wdata, wstrb, slave_idx);
    } else {
        // Read transaction
        apb_out->pwdata = 0;  // Don't care
        apb_out->pstrb = 0xF; // All bytes
        
        // Expected AXI response for read
        axi_out->resp = RESP_OKAY;
        axi_out->rdata = read_data;  // Data from APB slave
        
        printf("[Golden Model] READ: addr=0x%08X data=0x%08X slave=%d\n",
               addr, read_data, slave_idx);
    }
}

void golden_model_cleanup() {
    if (g_slave_ranges) {
        free(g_slave_ranges);
        g_slave_ranges = NULL;
    }
    g_num_slaves = 0;
    printf("[Golden Model] Cleaned up\n");
}
```

**Makefile (`tb/dpi/golden_model/Makefile`):**
```makefile
# Compile golden model as shared library
CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC -shared
TARGET = libbridge_golden.so

all: $(TARGET)

$(TARGET): bridge_golden_model.c bridge_golden_model.h
	$(CC) $(CFLAGS) -o $(TARGET) bridge_golden_model.c

clean:
	rm -f $(TARGET) *.o

.PHONY: all clean
```

---

#### 4.4.2 SystemVerilog Wrapper

**SV Package (`tb/dpi/golden_model/bridge_golden_model.sv`):**
```systemverilog
package bridge_golden_model_pkg;
  
  // Import C functions
  import "DPI-C" context function void golden_model_init(
    input int unsigned slave_base_addrs[],
    input int unsigned slave_sizes[],
    input int unsigned num_slaves
  );
  
  import "DPI-C" context function void golden_model_process(
    input  bit         is_write,       // 0=read, 1=write
    input  int unsigned addr,
    input  int unsigned wdata,
    input  byte unsigned wstrb,
    input  int unsigned read_data,
    // Outputs
    output int unsigned paddr,
    output int unsigned pwdata,
    output byte unsigned pstrb,
    output bit         pwrite,
    output byte unsigned psel_idx,
    output bit         is_valid,
    output int unsigned expected_rdata,
    output byte unsigned expected_resp
  );
  
  import "DPI-C" context function void golden_model_cleanup();
  
  // Wrapper class for UVM usage
  class bridge_golden_model;
    
    // Configuration
    int unsigned slave_base_addrs[];
    int unsigned slave_sizes[];
    
    function new();
      // Will be configured from environment
    endfunction
    
    function void configure(int unsigned bases[], int unsigned sizes[]);
      slave_base_addrs = bases;
      slave_sizes = sizes;
      golden_model_init(bases, sizes, bases.size());
    endfunction
    
    // Process transaction and get expected outputs
    function void predict(
      input  bit is_write,
      input  int unsigned addr,
      input  int unsigned wdata,
      input  byte unsigned wstrb,
      input  int unsigned read_data,  // Actual data read from APB
      // Expected outputs
      output int unsigned exp_paddr,
      output int unsigned exp_pwdata,
      output byte unsigned exp_pstrb,
      output bit exp_pwrite,
      output byte unsigned exp_psel_idx,
      output bit exp_is_valid,
      output int unsigned exp_rdata,
      output byte unsigned exp_resp
    );
      golden_model_process(
        is_write, addr, wdata, wstrb, read_data,
        exp_paddr, exp_pwdata, exp_pstrb, exp_pwrite,
        exp_psel_idx, exp_is_valid, exp_rdata, exp_resp
      );
    endfunction
    
    function void cleanup();
      golden_model_cleanup();
    endfunction
    
  endclass
  
endpackage
```

---

#### 4.4.3 Integration with Predictor/Scoreboard

**Predictor with Golden Model:**
```systemverilog
class axi_lite_to_apb_predictor extends uvm_component;
  `uvm_component_utils(axi_lite_to_apb_predictor)
  
  // Analysis port to scoreboard
  uvm_analysis_port #(apb_transaction) apb_expected_ap;
  uvm_analysis_port #(axi_lite_transaction) axi_expected_ap;
  
  // Golden model instance
  bridge_golden_model_pkg::bridge_golden_model golden;
  
  // TLM analysis export (receives from AXI-Lite monitor)
  uvm_analysis_imp #(axi_lite_transaction, axi_lite_to_apb_predictor) 
    axi_lite_imp;
  
  // Memory to track reads (APB slave response)
  bit [31:0] apb_memory [bit[31:0]];
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_lite_imp = new("axi_lite_imp", this);
    apb_expected_ap = new("apb_expected_ap", this);
    axi_expected_ap = new("axi_expected_ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    golden = new();
  endfunction
  
  function void configure(int unsigned bases[], int unsigned sizes[]);
    golden.configure(bases, sizes);
  endfunction
  
  // Receive AXI-Lite transaction from monitor
  function void write(axi_lite_transaction axi_txn);
    apb_transaction expected_apb;
    axi_lite_transaction expected_axi_resp;
    
    int unsigned exp_paddr;
    int unsigned exp_pwdata;
    byte unsigned exp_pstrb;
    bit exp_pwrite;
    byte unsigned exp_psel_idx;
    bit exp_is_valid;
    int unsigned exp_rdata;
    byte unsigned exp_resp;
    
    // Get data that will be read (for reads)
    int unsigned read_data = 0;
    if (axi_txn.txn_type == READ) begin
      if (apb_memory.exists(axi_txn.addr))
        read_data = apb_memory[axi_txn.addr];
      else
        read_data = $urandom();  // Uninitialized reads
    end
    
    // Call golden model
    golden.predict(
      (axi_txn.txn_type == WRITE), // is_write
      axi_txn.addr,
      axi_txn.data,
      axi_txn.strb,
      read_data,
      exp_paddr, exp_pwdata, exp_pstrb, exp_pwrite,
      exp_psel_idx, exp_is_valid, exp_rdata, exp_resp
    );
    
    // Create expected APB transaction
    if (exp_is_valid) begin
      expected_apb = apb_transaction::type_id::create("expected_apb");
      expected_apb.addr = exp_paddr;
      expected_apb.data = exp_pwdata;
      expected_apb.strb = exp_pstrb;
      expected_apb.is_write = exp_pwrite;
      expected_apb.psel_idx = exp_psel_idx;
      
      // Send to scoreboard
      apb_expected_ap.write(expected_apb);
      
      // Update memory for writes
      if (exp_pwrite) begin
        apb_memory[exp_paddr] = exp_pwdata;
      end
    end
    
    // Create expected AXI-Lite response
    expected_axi_resp = axi_lite_transaction::type_id::create("expected_axi_resp");
    expected_axi_resp.addr = axi_txn.addr;
    expected_axi_resp.txn_type = axi_txn.txn_type;
    expected_axi_resp.data = exp_rdata;
    expected_axi_resp.resp = axi_resp_t'(exp_resp);
    
    // Send to scoreboard
    axi_expected_ap.write(expected_axi_resp);
    
    `uvm_info(get_type_name(), 
      $sformatf("Predicted: APB valid=%0d, AXI resp=%s", 
                exp_is_valid, expected_axi_resp.resp.name()), 
      UVM_MEDIUM)
  endfunction
  
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    golden.cleanup();
  endfunction
  
endclass
```

---

#### 4.4.4 Compilation & Linking

**Updated `sim/Makefile.uvm`:**
```makefile
# Golden model paths
GOLDEN_MODEL_DIR = ../tb/dpi/golden_model
GOLDEN_MODEL_LIB = $(GOLDEN_MODEL_DIR)/libbridge_golden.so

# DPI-C flags
VCS_DPI_FLAGS = \
    -CFLAGS "-I$(GOLDEN_MODEL_DIR)" \
    -LDFLAGS "-L$(GOLDEN_MODEL_DIR) -lbridge_golden -Wl,-rpath,$(GOLDEN_MODEL_DIR)"

# Build golden model C library
$(GOLDEN_MODEL_LIB):
	$(MAKE) -C $(GOLDEN_MODEL_DIR)

# Main compilation target
compile: $(GOLDEN_MODEL_LIB)
	vcs $(VCS_UVM_FLAGS) $(VCS_DPI_FLAGS) \
	    $(INCLUDE_DIRS) \
	    -top tb_axi_lite_to_apb_top \
	    $(GOLDEN_MODEL_DIR)/bridge_golden_model.sv \
	    $(DUT_SOURCES) $(TB_SOURCES) \
	    -o simv_uvm

clean:
	$(MAKE) -C $(GOLDEN_MODEL_DIR) clean
	rm -rf simv_uvm* csrc *.log

.PHONY: compile clean
```

---

#### 4.4.5 Benefits of DPI-C Golden Model

| Aspect | SystemVerilog Model | DPI-C Golden Model |
|--------|--------------------|--------------------|
| **Performance** | Slower | ⚡ Much faster |
| **Complexity** | Harder for algorithms | ✅ Easier for complex logic |
| **Debugging** | Limited tools | 🔧 gdb, valgrind, etc. |
| **Reusability** | TB only | ✅ Standalone, firmware, etc. |
| **Maintenance** | Harder | ✅ Easier (C is simpler) |
| **Testing** | Needs simulator | ✅ Can unit test in C |

---

#### 4.4.6 Testing the Golden Model Standalone

You can test your C golden model independently:

**Test Program (`tb/dpi/golden_model/test_golden.c`):**
```c
#include "bridge_golden_model.h"
#include <stdio.h>
#include <assert.h>

int main() {
    printf("Testing Golden Model\n");
    printf("====================\n\n");
    
    // Configure with 2 APB slaves
    apb_slave_range_t slaves[] = {
        {.base_addr = 0x0000_0000, .size = 0x1000},  // Slave 0
        {.base_addr = 0x0000_1000, .size = 0x1000}   // Slave 1
    };
    golden_model_init(slaves, 2);
    
    apb_expected_t apb;
    axi_resp_expected_t axi;
    
    // Test 1: Write to slave 0
    printf("\nTest 1: Write to Slave 0\n");
    golden_model_process(TXN_WRITE, 0x0000_0100, 0xDEADBEEF, 0xF, 0,
                        &apb, &axi);
    assert(apb.is_valid == true);
    assert(apb.psel_idx == 0);
    assert(apb.pwrite == true);
    assert(axi.resp == RESP_OKAY);
    printf("  PASS\n");
    
    // Test 2: Read from slave 1
    printf("\nTest 2: Read from Slave 1\n");
    golden_model_process(TXN_READ, 0x0000_1500, 0, 0xF, 0xCAFEBABE,
                        &apb, &axi);
    assert(apb.is_valid == true);
    assert(apb.psel_idx == 1);
    assert(apb.pwrite == false);
    assert(axi.resp == RESP_OKAY);
    assert(axi.rdata == 0xCAFEBABE);
    printf("  PASS\n");
    
    // Test 3: Invalid address (DECERR)
    printf("\nTest 3: Invalid Address\n");
    golden_model_process(TXN_WRITE, 0xFFFF_FFFF, 0, 0xF, 0,
                        &apb, &axi);
    assert(apb.is_valid == false);
    assert(axi.resp == RESP_DECERR);
    printf("  PASS\n");
    
    golden_model_cleanup();
    
    printf("\n====================\n");
    printf("All tests PASSED!\n");
    return 0;
}
```

**Compile and run:**
```bash
cd tb/dpi/golden_model
gcc -o test_golden test_golden.c bridge_golden_model.c
./test_golden
```

---

### 4.5 Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    UVM ENVIRONMENT                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────┐     │
│  │         Virtual Sequencer (Phase 1 Optional)         │     │
│  │  ┌────────────────┐         ┌────────────────┐      │     │
│  │  │ AXI-Lite Seqr  │         │   APB Seqr     │      │     │
│  │  │   (ref)        │         │   (ref)        │      │     │
│  │  └───────┬────────┘         └────────┬───────┘      │     │
│  └──────────┼──────────────────────────┼──────────────┘     │
│             │                           │                     │
│  ┌──────────▼────────┐       ┌─────────▼────────┐           │
│  │  AXI-Lite Agent   │       │    APB Agent      │           │
│  │  ┌──────────────┐ │       │  ┌──────────────┐│           │
│  │  │ Sequencer    │ │       │  │ Sequencer    ││           │
│  │  ├──────────────┤ │       │  ├──────────────┤│           │
│  │  │ Driver       │ │       │  │ Driver       ││           │
│  │  │              │ │       │  │ (Slave mode) ││           │
│  │  │              │ │       │  │  ┌─────────┐ ││           │
│  │  │              │ │       │  │  │ Memory  │ ││           │
│  │  │              │ │       │  │  │ Model   │ ││           │
│  │  │              │ │       │  │  │         │ ││           │
│  │  │              │ │       │  │  │ DPI-C   │ ││ ◄─ Optional
│  │  │              │ │       │  │  │ or SV   │ ││           │
│  │  │              │ │       │  │  └─────────┘ ││           │
│  │  ├──────────────┤ │       │  ├──────────────┤│           │
│  │  │ Monitor      │ │       │  │ Monitor      ││           │
│  │  └──────────────┘ │       │  └──────────────┘│           │
│  └───────────────────┘       └───────────────────┘           │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  RAL (Optional - for register-based APB slaves)      │   │
│  │  ┌────────────┐  ┌──────────┐  ┌────────────────┐   │   │
│  │  │ Reg Model  │  │ Adapter  │  │  Predictor     │   │   │
│  │  └────────────┘  └──────────┘  └────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

### 4.6 Phased Adoption Strategy

| Component | Phase 1 | Phase 2 | Phase 3 | Complexity | When to Add |
|-----------|---------|---------|---------|------------|-------------|
| **Virtual Sequencer** | Optional | Recommended | Essential | ⭐ Low | Week 4 if needed |
| **RAL** | Skip | Skip | Consider | ⭐⭐ Medium | Only if using register slaves |
| **DPI-C Memory** | Skip | Optional | Recommended | ⭐⭐ Low-Med | If performance needed |
| **DPI-C Golden Model** | Recommended | Essential | Essential | ⭐⭐ Medium | Week 3-4 ✅ |

**Recommended Phase 1 approach:**
1. ✅ **Start simple (Week 1-2):** SV predictor, no RAL, no virtual sequencer
2. ✅ **Add golden model (Week 3-4):** DPI-C reference model for accurate checking
3. ⚠️ **Add if needed (Week 4-5):** Virtual sequencer for coordinated tests
4. ⚠️ **Optimize (Week 5-6):** DPI-C memory if performance issues
5. ❌ **Skip:** RAL (not applicable to protocol converter)

---

## 5. Phase 1: AXI-Lite to APB Bridge Testbench

### 4.1 Verification Components

#### 4.1.1 AXI-Lite Master Agent
**Purpose:** Generate AXI4-Lite transactions to drive the DUT input

**Components:**
- **Driver:** Drives AXI-Lite interface (AW, W, B, AR, R channels)
- **Monitor:** Observes and collects AXI-Lite transactions
- **Sequencer:** Manages sequence execution
- **Sequences:**
  - Random read/write sequences
  - Back-to-back transactions
  - Outstanding transaction control
  - Error injection (invalid addresses)

**Leverage Existing Code:**
```systemverilog
// Can adapt from deps/axi/src/axi_test.sv
// Use axi_lite_rand_master_t as reference
```

#### 4.1.2 APB Slave Agent
**Purpose:** Respond to APB transactions from DUT output

**Components:**
- **Driver (Slave):** Responds to APB requests with configurable delays
- **Monitor:** Collects APB transactions and checks protocol
- **Memory Model:** Simple memory to store/retrieve data
- **Sequences:**
  - Random ready delay insertion
  - Error response generation
  - Zero-wait-state responses

**Leverage Existing Code:**
```systemverilog
// Can adapt from deps/apb/src/apb_test.sv
// Has built-in slave/master mode support
```

#### 4.1.3 Environment Components

**Scoreboard:**
- Compare AXI-Lite requests → Expected APB transactions
- Verify write data integrity
- Verify read data correctness
- Check response codes (OKAY, SLVERR, DECERR)

**Predictor/Reference Model:**
- Model expected APB behavior from AXI-Lite inputs
- Handle address decoding
- Track pipelined requests/responses

**Coverage Collector:**
- Protocol coverage (all channels exercised)
- Cross coverage (address × transfer type)
- Corner cases (back-pressure, errors, boundaries)

### 4.2 Test Scenarios (Phase 1)

| Test Name | Description | Priority |
|-----------|-------------|----------|
| **Sanity Test** | Basic read/write to single address | P0 |
| **Random Test** | Constrained random transactions | P0 |
| **Back-to-Back** | Consecutive transactions, no gaps | P1 |
| **Address Decode** | All APB slaves accessed | P0 |
| **Error Response** | Invalid addresses → DECERR | P1 |
| **APB Backpressure** | APB slave delays with PREADY=0 | P1 |
| **Pipeline Test** | Test PIPE_REQ/PIPE_RESP configs | P0 |
| **Outstanding Txns** | Multiple pending transactions | P2 |
| **Burst Coverage** | Various sizes/alignments | P2 |
| **Reset During Txn** | Reset assertion handling | P2 |

### 4.3 Phase 1 Success Criteria
- ✅ 100% functional coverage of basic operations
- ✅ All 4 pipeline configurations pass (PIPE_REQ × PIPE_RESP)
- ✅ Zero scoreboard mismatches in 10K random transactions
- ✅ Protocol compliance verified
- ✅ Address decode for all slaves verified

---

## 5. Phase 2: AXI to AXI-Lite Converter Testbench

### 5.1 Verification Components

#### 5.1.1 AXI4 Full Master Agent
**Components:**
- Full AXI4 driver with burst support
- ATOP transaction generation
- Outstanding transaction management
- ID-based response tracking

**Leverage:**
```systemverilog
// deps/axi/src/axi_test.sv - axi_rand_master class
```

#### 5.1.2 AXI-Lite Slave Agent
**Components:**
- Monitor AXI-Lite outputs
- Respond to split burst transactions
- Verify burst-to-beat conversion

### 5.2 Key Verification Points
- ✅ Burst splitting (INCR → multiple AXI-Lite beats)
- ✅ ATOP filtering
- ✅ ID reflection/transformation
- ✅ Response aggregation
- ✅ Error propagation

---

## 6. Phase 3: Integrated System Testing

### 6.1 Integration Strategy

```
┌─────────────────────────────────────────────────────────┐
│                  Integrated Testbench                   │
│                                                         │
│  [AXI4 Agent]──→[axi_to_axi_lite]──→[axi_lite_to_apb] │
│     (Master)          (DUT1)        (DUT2)             │
│                                          ↓              │
│                                    [APB Agent]          │
│                                       (Slave)           │
│                                                         │
│  Scoreboard: AXI4 Request → APB4 Response              │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Integration Tests
- End-to-end data integrity
- Full burst transactions (AXI4 → multiple APB beats)
- Error propagation through chain
- Performance metrics (latency, throughput)

---

## 7. Leveraging PULP Platform Infrastructure

### 7.1 Reuse Opportunities

#### From `deps/axi/src/axi_test.sv`:
```systemverilog
class axi_rand_master;      // AXI4 master driver
class axi_lite_rand_slave;  // AXI-Lite slave driver
// Use as reference for UVM driver implementation
```

#### From `deps/apb/src/apb_test.sv`:
```systemverilog
class apb_driver;           // APB master/slave driver
// Wrap in UVM driver
```

#### From `deps/common_verification/`:
```systemverilog
class rand_id_queue;        // Transaction tracking
// Use in scoreboard
```

### 7.2 Integration with Existing Tests
- **Reference tests remain non-UVM** (`deps/axi/test/`)
- **UVM tests are separate** (`tb/tests/`)
- **Both can coexist** for different verification needs

---

## 8. Build Infrastructure

### 8.1 Makefile Strategy

```makefile
# sim/Makefile.uvm (new file)
UVM_HOME = /path/to/uvm
VCS_UVM_FLAGS = -ntb_opts uvm-1.2

# Separate targets for each phase
uvm_phase1: compile_uvm_phase1 run_uvm_phase1
uvm_phase2: compile_uvm_phase2 run_uvm_phase2
uvm_phase3: compile_uvm_phase3 run_uvm_phase3

# Test selection
TEST ?= axi_lite_to_apb_sanity_test
run_test:
    $(SIMV) +UVM_TESTNAME=$(TEST)
```

### 8.2 Regression Suite
```bash
#!/bin/bash
# sim/scripts/uvm_regression.sh
tests=(
    "axi_lite_to_apb_sanity_test"
    "axi_lite_to_apb_random_test"
    "axi_lite_to_apb_stress_test"
    # ...
)
```

---

## 9. Development Roadmap

### 9.1 Phase 1 Timeline

| Week | Milestone | Deliverables |
|------|-----------|--------------|
| **1** | Infrastructure setup | - Directory structure<br>- Base classes<br>- Interfaces |
| **2** | AXI-Lite agent | - Driver<br>- Monitor<br>- Basic sequences |
| **3** | APB agent | - Slave driver<br>- Monitor<br>- Memory model |
| **4** | Environment | - Scoreboard<br>- Coverage<br>- Base test |
| **5** | Test development | - Sanity<br>- Random<br>- Error tests |
| **6** | Debug & refine | - Fix issues<br>- Coverage closure |

### 9.2 Phase 2-3 (Future)
- Phase 2: +4-5 weeks (AXI to AXI-Lite)
- Phase 3: +2-3 weeks (Integration)

---

## 10. Best Practices & Guidelines

### 10.1 Coding Standards
- Follow UVM naming conventions (`_driver`, `_monitor`, `_agent`)
- Use factory registration for all components
- Implement copy/compare/print for all transactions
- Use `uvm_config_db` for all configuration

### 10.2 Debug Strategy
- Use UVM verbosity levels (`UVM_LOW`, `UVM_MEDIUM`, `UVM_HIGH`)
- Implement comprehensive logging in monitors
- Use waveform dumps for protocol analysis (Verdi/DVE)
- Create debug-focused test variants

### 10.3 Coverage Strategy
- Functional coverage in agents (protocol coverage)
- Cross coverage in environment (scenarios)
- Code coverage collection with VCS -cm
- Target: >95% functional, >90% code coverage

---

## 11. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| **VCS environment issues** | Use known-working Router_UVM setup as reference |
| **Protocol complexity** | Start with simple sanity tests, incremental complexity |
| **Integration challenges** | Thoroughly verify each phase standalone first |
| **Debug difficulty** | Invest in good logging/messaging infrastructure early |

---

## 12. Success Metrics

### Phase 1 (AXI-Lite to APB)
- [ ] All P0 tests passing
- [ ] >95% functional coverage
- [ ] >90% code coverage
- [ ] Zero scoreboard mismatches in 10K random transactions
- [ ] Documentation complete

### Phase 2 (AXI to AXI-Lite)
- [ ] Burst splitting verified
- [ ] ATOP handling verified
- [ ] ID management verified

### Phase 3 (Integration)
- [ ] End-to-end data integrity
- [ ] Full system regression passing
- [ ] Performance metrics documented

---

## 13. References

### External Documentation
- ARM AMBA APB Protocol Specification v2.0
- ARM AMBA AXI4 Protocol Specification
- UVM 1.2 User Guide
- PULP Platform Verification Guide

### Internal References
- `deps/axi/README.md` - AXI infrastructure
- `deps/apb/README.md` - APB infrastructure
- `deps/common_verification/` - TB utilities
- `docs/STRUCT_REFERENCE.md` - Interface definitions

---

## Appendices

### A. File Naming Conventions
```
Agents:     <protocol>_<component>.sv
Tests:      <dut>_<scenario>_test.sv
Sequences:  <protocol>_<type>_seq.sv
Interfaces: <protocol>_if.sv
Packages:   <module>_pkg.sv
```

### B. UVM Configuration Example
```systemverilog
// In test:
uvm_config_db#(virtual axi_lite_if)::set(
    this, "env.axi_agent*", "vif", axi_lite_vif
);

uvm_config_db#(int)::set(
    this, "env.apb_agent*", "max_delay", 10
);
```

---

**Document Version:** 1.0  
**Next Review:** After Phase 1 completion  
**Approver:** Nathan Carter

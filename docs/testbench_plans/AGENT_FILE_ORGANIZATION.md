# UVM Agent File Organization Guide

**Question:** Where do transaction classes go?  
**Answer:** Inside each agent's directory, compiled into that agent's package.

---

## 🎯 Quick Answer

```
tb/agents/axi_lite_agent/
├── axi_lite_transaction.sv  ← Transaction class goes HERE ⭐
├── axi_lite_driver.sv
├── axi_lite_monitor.sv
└── axi_lite_pkg.sv          ← Package includes transaction
```

**Rule:** Each agent is self-contained with its own transaction class.

---

## 📂 Complete Agent Directory Structure

### AXI-Lite Agent (Example)

```
tb/agents/axi_lite_agent/
├── axi_lite_pkg.sv                # Package definition (includes all .sv files)
├── axi_lite_if.sv                 # Interface (NOT in package)
├── axi_lite_transaction.sv        # Transaction/sequence_item ⭐
├── axi_lite_config.sv             # Configuration object
├── axi_lite_sequencer.sv          # Sequencer (parameterized with transaction)
├── axi_lite_driver.sv             # Driver (uses transaction)
├── axi_lite_monitor.sv            # Monitor (generates transactions)
├── axi_lite_coverage.sv           # Coverage collector (subscribes to transactions)
├── axi_lite_agent.sv              # Agent top-level (instantiates all components)
└── sequences/                     # Sequence library folder
    ├── axi_lite_base_seq.sv       # Base sequence (uses transaction)
    ├── axi_lite_random_seq.sv     # Random sequence
    ├── axi_lite_write_seq.sv      # Write-only sequence
    ├── axi_lite_read_seq.sv       # Read-only sequence
    └── axi_lite_stress_seq.sv     # Back-to-back sequence
```

---

## 📝 File-by-File Breakdown

### 1. Transaction Class (`axi_lite_transaction.sv`)

**Purpose:** Defines the data structure passed between sequencer, driver, and monitor.

**Location:** `tb/agents/axi_lite_agent/axi_lite_transaction.sv`

```systemverilog
// File: tb/agents/axi_lite_agent/axi_lite_transaction.sv
class axi_lite_transaction extends uvm_sequence_item;
  
  // Transaction type
  typedef enum {READ, WRITE} txn_type_e;
  
  // Data fields (randomizable)
  rand txn_type_e       txn_type;
  rand bit [31:0]       addr;
  rand bit [31:0]       data;      // wdata for writes, rdata for reads
  rand bit [3:0]        strb;
  
  // Response (set by monitor/driver)
  bit [1:0]             resp;      // OKAY, SLVERR, DECERR
  
  // Timing (optional, for tracking)
  time                  start_time;
  time                  end_time;
  
  // Constraints
  constraint valid_strb_c {
    $countones(strb) > 0;  // At least one byte must be enabled
  }
  
  constraint aligned_addr_c {
    addr[1:0] == 2'b00;    // 32-bit aligned addresses
  }
  
  // UVM automation macros
  `uvm_object_utils_begin(axi_lite_transaction)
    `uvm_field_enum(txn_type_e, txn_type, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(strb, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(resp, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "axi_lite_transaction");
    super.new(name);
  endfunction
  
  // Custom methods
  function bit is_write();
    return (txn_type == WRITE);
  endfunction
  
  function bit is_read();
    return (txn_type == READ);
  endfunction
  
endclass
```

---

### 2. Package File (`axi_lite_pkg.sv`)

**Purpose:** Wraps all agent components into a package for easy importing.

**Location:** `tb/agents/axi_lite_agent/axi_lite_pkg.sv`

**Important:** Package includes `.sv` files, NOT the interface!

```systemverilog
// File: tb/agents/axi_lite_agent/axi_lite_pkg.sv
package axi_lite_pkg;
  
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // Include order matters! Dependencies first.
  
  // 1. Transaction (no dependencies)
  `include "axi_lite_transaction.sv"
  
  // 2. Configuration (no dependencies)
  `include "axi_lite_config.sv"
  
  // 3. Sequencer (depends on transaction)
  `include "axi_lite_sequencer.sv"
  
  // 4. Driver (depends on transaction, config)
  `include "axi_lite_driver.sv"
  
  // 5. Monitor (depends on transaction, config)
  `include "axi_lite_monitor.sv"
  
  // 6. Coverage (depends on transaction, config)
  `include "axi_lite_coverage.sv"
  
  // 7. Sequences (depend on transaction, sequencer)
  `include "sequences/axi_lite_base_seq.sv"
  `include "sequences/axi_lite_random_seq.sv"
  `include "sequences/axi_lite_write_seq.sv"
  `include "sequences/axi_lite_read_seq.sv"
  
  // 8. Agent (depends on everything above)
  `include "axi_lite_agent.sv"
  
endpackage
```

**Why this order?**
- Transaction is included first (no dependencies)
- Components that USE transaction come after
- Agent comes last (uses all components)

---

### 3. Interface (`axi_lite_if.sv`)

**Purpose:** Defines signal interface between DUT and testbench.

**Location:** `tb/agents/axi_lite_agent/axi_lite_if.sv`

**Important:** Interface is NOT part of the package! It's instantiated in the top-level testbench.

```systemverilog
// File: tb/agents/axi_lite_agent/axi_lite_if.sv
// NOTE: This file is NOT included in the package!
interface axi_lite_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32
)(
  input logic clk,
  input logic rst_n
);
  
  // AXI4-Lite signals
  // Write address channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic                  awvalid;
  logic                  awready;
  
  // Write data channel
  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wvalid;
  logic                    wready;
  
  // Write response channel
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;
  
  // Read address channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic                  arvalid;
  logic                  arready;
  
  // Read data channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rvalid;
  logic                  rready;
  
  // Clocking blocks for driver (outputs) and monitor (inputs)
  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output awaddr, awvalid, wdata, wstrb, wvalid;
    output bready, araddr, arvalid, rready;
    input  awready, wready, bresp, bvalid;
    input  arready, rdata, rresp, rvalid;
  endclocking
  
  clocking mon_cb @(posedge clk);
    default input #1step;
    input awaddr, awvalid, awready;
    input wdata, wstrb, wvalid, wready;
    input bresp, bvalid, bready;
    input araddr, arvalid, arready;
    input rdata, rresp, rvalid, rready;
  endclocking
  
  // Modports
  modport driver  (clocking drv_cb, input rst_n, input clk);
  modport monitor (clocking mon_cb, input rst_n, input clk);
  modport dut     (
    input  awaddr, awvalid, output awready,
    input  wdata, wstrb, wvalid, output wready,
    output bresp, bvalid, input  bready,
    input  araddr, arvalid, output arready,
    output rdata, rresp, rvalid, input  rready
  );
  
endinterface
```

---

### 4. Driver (`axi_lite_driver.sv`)

**Purpose:** Receives transactions from sequencer and drives interface.

**Uses:** `axi_lite_transaction` class

```systemverilog
// File: tb/agents/axi_lite_agent/axi_lite_driver.sv
class axi_lite_driver extends uvm_driver #(axi_lite_transaction);
  `uvm_component_utils(axi_lite_driver)
  
  virtual axi_lite_if vif;
  axi_lite_config cfg;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface not found")
    if (!uvm_config_db#(axi_lite_config)::get(this, "", "cfg", cfg))
      `uvm_info(get_type_name(), "Config not found, using defaults", UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      // Get transaction from sequencer
      seq_item_port.get_next_item(req);
      
      // Drive based on transaction type
      if (req.is_write())
        drive_write(req);
      else
        drive_read(req);
      
      // Signal completion
      seq_item_port.item_done();
    end
  endtask
  
  task drive_write(axi_lite_transaction txn);
    // Drive write address
    @(vif.drv_cb);
    vif.drv_cb.awaddr  <= txn.addr;
    vif.drv_cb.awvalid <= 1'b1;
    @(vif.drv_cb iff vif.drv_cb.awready);
    vif.drv_cb.awvalid <= 1'b0;
    
    // Drive write data
    vif.drv_cb.wdata  <= txn.data;
    vif.drv_cb.wstrb  <= txn.strb;
    vif.drv_cb.wvalid <= 1'b1;
    @(vif.drv_cb iff vif.drv_cb.wready);
    vif.drv_cb.wvalid <= 1'b0;
    
    // Receive response
    vif.drv_cb.bready <= 1'b1;
    @(vif.drv_cb iff vif.drv_cb.bvalid);
    txn.resp = vif.drv_cb.bresp;
    vif.drv_cb.bready <= 1'b0;
  endtask
  
  task drive_read(axi_lite_transaction txn);
    // Similar for reads...
  endtask
  
endclass
```

---

### 5. Sequences (Use Transactions)

**Location:** `tb/agents/axi_lite_agent/sequences/`

```systemverilog
// File: tb/agents/axi_lite_agent/sequences/axi_lite_random_seq.sv
class axi_lite_random_seq extends uvm_sequence #(axi_lite_transaction);
  `uvm_object_utils(axi_lite_random_seq)
  
  rand int num_transactions;
  
  constraint num_txns_c {
    num_transactions inside {[10:100]};
  }
  
  function new(string name = "axi_lite_random_seq");
    super.new(name);
  endfunction
  
  task body();
    repeat (num_transactions) begin
      `uvm_do(req)  // Create and randomize transaction
    end
  endtask
  
endclass
```

---

## 🔄 How It All Connects

```
┌─────────────────────────────────────────────────────────┐
│                    Test (top-level)                     │
│  import axi_lite_pkg::*;                                │
│  axi_lite_random_seq seq = axi_lite_random_seq::...    │
│  seq.start(env.axi_agent.sequencer);                    │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│              axi_lite_agent (in package)                │
│                                                         │
│  ┌──────────────┐      ┌─────────────────┐            │
│  │  Sequencer   │─────→│     Driver      │            │
│  └──────────────┘      └────────┬────────┘            │
│         │                        │                     │
│         │ axi_lite_transaction   │                     │
│         ▼                        ▼                     │
│  ┌──────────────────────────────────┐                 │
│  │   axi_lite_transaction class     │                 │
│  │   (data fields, constraints)     │                 │
│  └──────────────────────────────────┘                 │
│                        │                               │
└────────────────────────┼───────────────────────────────┘
                         │
                         ▼
              ┌──────────────────┐
              │  axi_lite_if     │ (NOT in package)
              │  (Interface)     │
              └────────┬─────────┘
                       │
                       ▼
                    [DUT]
```

---

## 📋 Checklist: Creating a New Agent

When creating a new agent, follow this order:

### Step 1: Create Directory
```bash
mkdir -p tb/agents/my_agent/sequences
```

### Step 2: Create Files (in this order)

1. ✅ **Interface** (`my_if.sv`)
   - Define signals
   - Create clocking blocks
   - NOT in package

2. ✅ **Transaction** (`my_transaction.sv`)
   - Extend `uvm_sequence_item`
   - Define data fields
   - Add constraints
   - Add `uvm_object_utils`

3. ✅ **Config** (`my_config.sv`)
   - Agent configuration parameters

4. ✅ **Sequencer** (`my_sequencer.sv`)
   - Usually just: `typedef uvm_sequencer#(my_transaction) my_sequencer;`

5. ✅ **Driver** (`my_driver.sv`)
   - Extend `uvm_driver#(my_transaction)`
   - Implement `run_phase`

6. ✅ **Monitor** (`my_monitor.sv`)
   - Observe interface
   - Create and broadcast transactions

7. ✅ **Coverage** (`my_coverage.sv`) - Optional
   - Functional coverage on transactions

8. ✅ **Sequences** (`sequences/*.sv`)
   - Extend `uvm_sequence#(my_transaction)`

9. ✅ **Agent** (`my_agent.sv`)
   - Instantiate all components

10. ✅ **Package** (`my_pkg.sv`)
    - Include all files (except interface!)
    - Correct dependency order

---

## 🎯 Common Mistakes to Avoid

### ❌ WRONG: Including interface in package
```systemverilog
// WRONG!
package my_pkg;
  `include "my_if.sv"  // ← NO! Interface not in package
  `include "my_transaction.sv"
  ...
endpackage
```

### ✅ CORRECT: Interface separate
```systemverilog
// CORRECT!
package my_pkg;
  // Interface is NOT here
  `include "my_transaction.sv"
  `include "my_driver.sv"
  ...
endpackage
```

### ❌ WRONG: Wrong include order
```systemverilog
// WRONG! Agent uses transaction, so must come after
package my_pkg;
  `include "my_agent.sv"         // ← Uses transaction...
  `include "my_transaction.sv"   // ← ...but defined here!
endpackage
```

### ✅ CORRECT: Dependencies first
```systemverilog
// CORRECT!
package my_pkg;
  `include "my_transaction.sv"   // No dependencies
  `include "my_driver.sv"        // Uses transaction
  `include "my_agent.sv"         // Uses everything
endpackage
```

---

## 📦 Using the Agent in Your Testbench

### In Environment:
```systemverilog
class my_env extends uvm_env;
  
  // Import the agent package
  import axi_lite_pkg::*;
  import apb_pkg::*;
  
  // Declare agent instances
  axi_lite_agent axi_agt;
  apb_agent      apb_agt;
  
  // ...
endclass
```

### In Test:
```systemverilog
class my_test extends uvm_test;
  
  // Import packages
  import axi_lite_pkg::*;
  
  task run_phase(uvm_phase phase);
    axi_lite_random_seq seq;
    
    // Create sequence
    seq = axi_lite_random_seq::type_id::create("seq");
    
    // Start sequence
    seq.start(env.axi_agt.sequencer);
  endtask
  
endclass
```

---

## 📊 Summary Table

| File | Location | In Package? | Purpose |
|------|----------|-------------|---------|
| `*_transaction.sv` | `agent/` | ✅ Yes | Data structure |
| `*_if.sv` | `agent/` | ❌ No | Signal interface |
| `*_config.sv` | `agent/` | ✅ Yes | Configuration |
| `*_sequencer.sv` | `agent/` | ✅ Yes | Sequence management |
| `*_driver.sv` | `agent/` | ✅ Yes | Interface driver |
| `*_monitor.sv` | `agent/` | ✅ Yes | Observer |
| `*_coverage.sv` | `agent/` | ✅ Yes | Coverage collector |
| `sequences/*.sv` | `agent/sequences/` | ✅ Yes | Stimulus |
| `*_agent.sv` | `agent/` | ✅ Yes | Top component |
| `*_pkg.sv` | `agent/` | N/A | Package wrapper |

---

## 🚀 Quick Start Template

When creating your first agent, use this as a template:

```
tb/agents/YOUR_AGENT_NAME/
├── YOUR_AGENT_NAME_pkg.sv           # Package file
├── YOUR_AGENT_NAME_if.sv            # Interface
├── YOUR_AGENT_NAME_transaction.sv   # Start here! ⭐
├── YOUR_AGENT_NAME_config.sv
├── YOUR_AGENT_NAME_sequencer.sv
├── YOUR_AGENT_NAME_driver.sv
├── YOUR_AGENT_NAME_monitor.sv
├── YOUR_AGENT_NAME_agent.sv
└── sequences/
    ├── YOUR_AGENT_NAME_base_seq.sv
    └── YOUR_AGENT_NAME_random_seq.sv
```

**Start with transaction, then build outward!**

---

**Document Version:** 1.0  
**Date:** 2026-01-27  
**Related:** `UVM_TESTBENCH_ARCHITECTURE.md`, `QUICK_START_UVM.md`

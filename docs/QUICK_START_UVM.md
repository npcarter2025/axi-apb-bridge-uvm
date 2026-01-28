# Quick Start Guide: UVM Testbench Development

**Last Updated:** 2026-01-27  
**Status:** Ready to begin implementation

---

## 🎯 You Are Here

```
✅ Planning Phase Complete
📍 Ready to Start Implementation
⏭️  Next: Week 1 - Infrastructure Setup
```

---

## 📚 Essential Reading Order

1. **[UVM_TESTBENCH_ARCHITECTURE.md](UVM_TESTBENCH_ARCHITECTURE.md)** (15 min read)
   - System overview
   - Directory structure
   - Development phases
   - Leveraging PULP infrastructure

2. **[VERIFICATION_PLAN.md](VERIFICATION_PLAN.md)** (20 min read)
   - Detailed test cases
   - Coverage strategy
   - Assertions/checkers
   - Success criteria

3. **This guide** - Quick reference for getting started

---

## 🚀 Week 1: Getting Started

### Day 1-2: Directory Setup

```bash
cd /scratch/cs199-buw/AXI_TO_APB_BRIDGE_UVM

# Create UVM testbench structure
mkdir -p tb/{agents,env,tests,top,common}
mkdir -p tb/agents/{axi_lite_agent,apb_agent}
mkdir -p tb/agents/axi_lite_agent/sequences
mkdir -p tb/agents/apb_agent/sequences
mkdir -p tb/env/axi_lite_to_apb_env
mkdir -p tb/tests/axi_lite_to_apb_tests

# Create simulation directories
mkdir -p sim/files/uvm
mkdir -p sim/logs_uvm
mkdir -p sim/build_uvm
```

### Day 3-4: Base Interfaces

**Create: `tb/agents/axi_lite_agent/axi_lite_if.sv`**
```systemverilog
interface axi_lite_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32
)(
  input logic clk,
  input logic rst_n
);
  // AW channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic                  awvalid;
  logic                  awready;
  
  // W channel
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                  wvalid;
  logic                  wready;
  
  // B channel
  logic [1:0]           bresp;
  logic                 bvalid;
  logic                 bready;
  
  // AR channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic                  arvalid;
  logic                  arready;
  
  // R channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rvalid;
  logic                  rready;
  
  // Clocking blocks for driver/monitor
  clocking drv_cb @(posedge clk);
    output awaddr, awvalid, wdata, wstrb, wvalid;
    output bready, araddr, arvalid, rready;
    input  awready, wready, bresp, bvalid;
    input  arready, rdata, rresp, rvalid;
  endclocking
  
  clocking mon_cb @(posedge clk);
    input awaddr, awvalid, awready;
    input wdata, wstrb, wvalid, wready;
    input bresp, bvalid, bready;
    input araddr, arvalid, arready;
    input rdata, rresp, rvalid, rready;
  endclocking
  
  modport driver  (clocking drv_cb, input rst_n);
  modport monitor (clocking mon_cb, input rst_n);
  
endinterface
```

**Create: `tb/agents/apb_agent/apb_if.sv`**
```systemverilog
interface apb_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32
)(
  input logic clk,
  input logic rst_n
);
  logic [ADDR_WIDTH-1:0] paddr;
  logic                  psel;
  logic                  penable;
  logic                  pwrite;
  logic [DATA_WIDTH-1:0] pwdata;
  logic [DATA_WIDTH/8-1:0] pstrb;
  logic                  pready;
  logic [DATA_WIDTH-1:0] prdata;
  logic                  pslverr;
  
  // Clocking blocks
  clocking slv_drv_cb @(posedge clk);
    input  paddr, psel, penable, pwrite, pwdata, pstrb;
    output pready, prdata, pslverr;
  endclocking
  
  clocking mon_cb @(posedge clk);
    input paddr, psel, penable, pwrite, pwdata, pstrb;
    input pready, prdata, pslverr;
  endclocking
  
  modport slave   (clocking slv_drv_cb, input rst_n);
  modport monitor (clocking mon_cb, input rst_n);
  
endinterface
```

### Day 5: Transaction Classes

**Create: `tb/agents/axi_lite_agent/axi_lite_transaction.sv`**
```systemverilog
class axi_lite_transaction extends uvm_sequence_item;
  
  typedef enum {READ, WRITE} txn_type_e;
  
  rand txn_type_e                txn_type;
  rand bit [31:0]                addr;
  rand bit [31:0]                data;
  rand bit [3:0]                 strb;
  bit [1:0]                      resp;
  
  // Constraints
  constraint valid_strb_c {
    $countones(strb) > 0;  // At least one byte enabled
  }
  
  `uvm_object_utils_begin(axi_lite_transaction)
    `uvm_field_enum(txn_type_e, txn_type, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(strb, UVM_ALL_ON)
    `uvm_field_int(resp, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "axi_lite_transaction");
    super.new(name);
  endfunction
  
endclass
```

---

## 🔧 Reference Code Locations

### PULP Platform Code to Study

```
deps/axi/src/axi_test.sv
├─ axi_rand_master class      → Reference for AXI driver
├─ axi_lite_rand_slave class  → Reference for AXI-Lite slave
└─ Transaction randomization

deps/apb/src/apb_test.sv
├─ apb_driver class            → Reference for APB driver
└─ Master/slave mode switching

deps/common_verification/src/
├─ rand_id_queue.sv            → Transaction tracking
└─ rand_synch_driver.sv        → Randomized valid/ready
```

### Working Reference Testbench

```
deps/axi/test/tb_axi_lite_to_apb.sv
├─ Shows how to instantiate DUT
├─ Clock/reset generation
├─ Driver instantiation
└─ Checks to implement
```

---

## 📝 Checklist: Week 1

- [ ] Create directory structure
- [ ] Define `axi_lite_if` interface
- [ ] Define `apb_if` interface  
- [ ] Create `axi_lite_transaction` class
- [ ] Create `apb_transaction` class
- [ ] Create `axi_lite_pkg.sv`
- [ ] Create `apb_pkg.sv`
- [ ] Test compilation of packages

---

## 🛠️ Makefile Template

**Create: `sim/Makefile.uvm`**
```makefile
# UVM-specific Makefile
UVM_HOME ?= $(VCS_HOME)/etc/uvm-1.2

# VCS flags for UVM
VCS_UVM_FLAGS = \
    -ntb_opts uvm-1.2 \
    -CFLAGS -DVCS \
    +vcs+flush+all \
    -timescale=1ns/1ps \
    -full64 \
    -sverilog \
    -debug_access+all \
    -kdb \
    -lca

# Include directories
INCLUDE_DIRS = \
    +incdir+../deps/axi/include \
    +incdir+../deps/apb/include \
    +incdir+../tb/agents/axi_lite_agent \
    +incdir+../tb/agents/apb_agent \
    +incdir+../tb/env \
    +incdir+../tb/tests

# Source files (Phase 1)
TB_SOURCES = \
    ../deps/common_verification/src/clk_rst_gen.sv \
    ../deps/common_verification/src/rand_id_queue.sv \
    ../deps/apb/src/apb_pkg.sv \
    ../deps/apb/src/apb_intf.sv \
    ../deps/axi/src/axi_pkg.sv \
    ../deps/axi/src/axi_intf.sv \
    ../tb/agents/axi_lite_agent/axi_lite_if.sv \
    ../tb/agents/apb_agent/apb_if.sv \
    ../tb/agents/axi_lite_agent/axi_lite_pkg.sv \
    ../tb/agents/apb_agent/apb_pkg.sv \
    ../tb/env/axi_lite_to_apb_env/axi_lite_to_apb_env_pkg.sv \
    ../tb/tests/axi_lite_to_apb_base_test.sv \
    ../tb/top/tb_axi_lite_to_apb_top.sv

# DUT sources
DUT_SOURCES = \
    $(wildcard ../deps/common_cells/src/*.sv) \
    ../dut_axi_lite/axi_lite_to_apb.sv

# Default test
TEST ?= axi_lite_to_apb_sanity_test
SEED ?= random

.PHONY: compile run clean

compile:
	vcs $(VCS_UVM_FLAGS) $(INCLUDE_DIRS) \
	    -top tb_axi_lite_to_apb_top \
	    $(DUT_SOURCES) $(TB_SOURCES) \
	    -o simv_uvm

run: compile
	./simv_uvm +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED)

clean:
	rm -rf simv_uvm* csrc *.log DVEfiles ucli.key
```

---

## 🎓 UVM Learning Resources

### Key Concepts to Review
1. **UVM Phases:** build, connect, run
2. **Factory Pattern:** `uvm_component_utils`, registration
3. **Configuration:** `uvm_config_db`
4. **Messaging:** `uvm_info`, `uvm_error`, `uvm_fatal`
5. **Sequences:** `uvm_sequence`, `uvm_sequencer`

### Quick UVM Template
```systemverilog
class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver)
  
  virtual my_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface not found")
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask
  
  task drive_transaction(my_transaction txn);
    // Drive interface signals
  endtask
  
endclass
```

---

## 📞 Getting Help

### When Stuck
1. **Check PULP reference code** in `deps/`
2. **Review verification plan** for test requirements
3. **Check working testbench** in `deps/axi/test/tb_axi_lite_to_apb.sv`
4. **UVM cookbook** examples
5. **VCS UVM documentation** (`$VCS_HOME/doc/`)

### Debug Tips
```bash
# Increase UVM verbosity
make -f Makefile.uvm run TEST=my_test UVM_VERBOSITY=UVM_HIGH

# Enable waveforms
make -f Makefile.uvm run TEST=my_test DUMP_VPD=1

# Run with GUI
make -f Makefile.uvm run TEST=my_test GUI=1
```

---

## 🎯 Success Criteria (Week 1)

By end of Week 1, you should have:
- ✅ Directory structure created
- ✅ Interfaces defined and compiling
- ✅ Transaction classes defined
- ✅ Packages compiling
- ✅ Basic Makefile working
- ✅ Understanding of UVM component hierarchy

**Next:** Week 2 - Driver & Monitor Implementation

---

## 📋 Daily Log Template

Keep track of progress:
```markdown
## Week 1 - Day 1 (Date: _______)
**Goal:** Create directory structure and interfaces
**Completed:**
- [ ] Created tb/ directory structure
- [ ] Created axi_lite_if.sv
- [ ] Tested compilation

**Blockers:** None / [describe any issues]
**Tomorrow:** Start transaction classes
```

---

**Ready to start? Let's build this! 🚀**

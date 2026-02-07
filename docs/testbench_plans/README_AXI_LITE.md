# AXI-Lite to APB Bridge - UVM Testbench Project

This directory contains all the necessary files for creating a UVM testbench for the AXI-Lite to APB bridge.

## Directory Structure

```
AXI_TO_APB_BRIDGE_UVM/
├── dut_axi_lite/           # AXI-Lite to APB bridge DUT
│   └── axi_lite_to_apb.sv
├── pkg/                     # SystemVerilog packages
│   ├── axi_pkg.sv          # AXI protocol definitions
│   └── cf_math_pkg.sv      # Common functions math package
├── include/                 # Header files
│   ├── axi/
│   │   ├── typedef.svh     # AXI type definition macros
│   │   └── assign.svh      # AXI assignment macros
│   └── common_cells/
│       ├── registers.svh   # Register macros
│       └── assertions.svh  # Assertion macros
├── rtl/                     # Supporting RTL modules
│   └── common_cells/
│       ├── onehot_to_bin.sv
│       ├── rr_arb_tree.sv
│       ├── lzc.sv
│       ├── addr_decode.sv
│       ├── spill_register.sv
│       └── fall_through_register.sv
└── reference/               # Reference testbench (non-UVM)
    └── tb_axi_lite_to_apb.sv

## DUT Overview

**Module:** `axi_lite_to_apb`

### Description
This module converts AXI4-Lite transactions to APB4 transactions. It features:
- One AXI4-Lite slave port
- Multiple APB4 master ports (configurable)
- Address decoding for APB slave selection
- Optional request/response pipelining
- Error handling (decode errors mapped to AXI responses)

### Key Features
- **Protocol Translation:** AXI4-Lite ↔ APB4
- **Multiple APB Slaves:** Supports up to N APB slaves with address decoding
- **Round-Robin Arbitration:** Between read and write channels
- **Buffering:** Optional pipeline stages for timing closure
- **Parameterizable:** Data widths, number of slaves, buffer depths

### Interface Requirements

The module expects these struct types to be defined:

```systemverilog
// AXI-Lite Request (use macros from axi/typedef.svh)
typedef struct packed {
  aw_chan_t aw;
  logic     aw_valid;
  w_chan_t  w;
  logic     w_valid;
  logic     b_ready;
  ar_chan_t ar;
  logic     ar_valid;
  logic     r_ready;
} axi_lite_req_t;

// AXI-Lite Response
typedef struct packed {
  logic     aw_ready;
  logic     ar_ready;
  logic     w_ready;
  logic     b_valid;
  b_chan_t  b;
  logic     r_valid;
  r_chan_t  r;
} axi_lite_resp_t;

// APB Request
typedef struct packed {
  addr_t          paddr;
  axi_pkg::prot_t pprot;
  logic           psel;
  logic           penable;
  logic           pwrite;
  data_t          pwdata;
  strb_t          pstrb;
} apb_req_t;

// APB Response
typedef struct packed {
  logic  pready;
  data_t prdata;
  logic  pslverr;
} apb_resp_t;
```

## Compilation Order

**IMPORTANT:** Files must be compiled in this order:

1. **Packages** (Level 0):
   - `pkg/cf_math_pkg.sv`
   - `pkg/axi_pkg.sv`

2. **Common Cells - Level 0** (no dependencies):
   - `rtl/common_cells/onehot_to_bin.sv`
   - `rtl/common_cells/rr_arb_tree.sv`

3. **Common Cells - Level 1** (depends on packages):
   - `rtl/common_cells/lzc.sv`

4. **Common Cells - Level 2** (depends on Level 0 & 1):
   - `rtl/common_cells/addr_decode.sv`
   - `rtl/common_cells/spill_register.sv`
   - `rtl/common_cells/fall_through_register.sv`

5. **DUT**:
   - `dut_axi_lite/axi_lite_to_apb.sv`

## Simulator Setup

### Include Paths
Add these to your simulator options:
```bash
+incdir+include/
+incdir+include/axi/
+incdir+include/common_cells/
```

Or for VCS:
```bash
-I include/ -I include/axi/ -I include/common_cells/
```

### Example Compilation (VCS)

```bash
vcs -sverilog \
    -timescale=1ns/1ps \
    +incdir+include/ \
    +incdir+include/axi/ \
    +incdir+include/common_cells/ \
    pkg/cf_math_pkg.sv \
    pkg/axi_pkg.sv \
    rtl/common_cells/onehot_to_bin.sv \
    rtl/common_cells/rr_arb_tree.sv \
    rtl/common_cells/lzc.sv \
    rtl/common_cells/addr_decode.sv \
    rtl/common_cells/spill_register.sv \
    rtl/common_cells/fall_through_register.sv \
    dut_axi_lite/axi_lite_to_apb.sv \
    <your_testbench_files>
```

## Creating Your UVM Testbench

### Required UVM Components

1. **AXI-Lite Master Agent**
   - Driver: Generate AXI-Lite transactions
   - Monitor: Observe AXI-Lite bus
   - Sequencer: Manage transaction sequences

2. **APB Slave Agent**
   - Driver: Respond to APB transactions
   - Monitor: Observe APB bus
   - Sequencer: Manage response patterns

3. **Scoreboard**
   - Check protocol conversion correctness
   - Verify data integrity
   - Monitor response mappings

4. **Environment**
   - Instantiate agents
   - Configure address map
   - Connect TLM ports

5. **Sequences**
   - Random read/write sequences
   - Directed tests (burst, errors, edge cases)
   - Address map coverage

### Suggested Test Scenarios

- ✓ Basic read/write transactions
- ✓ Back-to-back transactions
- ✓ Out-of-address-map accesses (decode errors)
- ✓ Multiple APB slaves
- ✓ Read-write arbitration
- ✓ APB slave wait states (PREADY low)
- ✓ APB slave errors (PSLVERR)
- ✓ Pipeline configurations (request/response)
- ✓ Corner cases (address alignment, strobe patterns)

## Reference Testbench

The `reference/tb_axi_lite_to_apb.sv` file contains a working non-UVM testbench that:
- Shows how to instantiate the DUT
- Defines the required struct types
- Demonstrates address map configuration
- Uses random transaction generation

Use it as a reference for understanding the DUT behavior.

## License

All files are licensed under the Solderpad Hardware License, Version 0.51.

**Original Authors:**
- Wolfgang Roenninger (ETH Zurich)
- Andreas Kurth (ETH Zurich)
- Samuel Riedel (ETH Zurich)
- And many others from PULP Platform

## Next Steps

1. Review the reference testbench in `reference/`
2. Create UVM package with type definitions
3. Develop AXI-Lite master agent
4. Develop APB slave agent
5. Create scoreboard
6. Build test sequences
7. Add functional coverage

Good luck with your UVM testbench!
```

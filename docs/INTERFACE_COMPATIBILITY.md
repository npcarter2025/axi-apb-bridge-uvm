# Interface Compatibility Analysis: Chaining axi_to_axi_lite → axi_lite_to_apb

This document verifies that `axi_to_axi_lite` and `axi_lite_to_apb` can be safely chained together.

## Executive Summary

**✅ FULLY COMPATIBLE** - These modules can be directly connected.

Both modules use the **same AXI4-Lite typedef macros** from `axi/include/axi/typedef.svh`, ensuring perfect structural compatibility.

---

## 1. Module Interface Comparison

### Module 1: `axi_to_axi_lite`
```systemverilog
module axi_to_axi_lite #(
  parameter type lite_req_t  = logic,  // ← OUTPUT type
  parameter type lite_resp_t = logic   // ← INPUT type
) (
  // ... other ports ...
  output lite_req_t  mst_req_o,   // ← AXI-Lite Master REQUEST out
  input  lite_resp_t mst_resp_i   // ← AXI-Lite Master RESPONSE in
);
```

### Module 2: `axi_lite_to_apb`
```systemverilog
module axi_lite_to_apb #(
  parameter type axi_lite_req_t  = logic,  // ← INPUT type
  parameter type axi_lite_resp_t = logic   // ← OUTPUT type
) (
  // ... other ports ...
  input  axi_lite_req_t  axi_lite_req_i,   // ← AXI-Lite Slave REQUEST in
  output axi_lite_resp_t axi_lite_resp_o   // ← AXI-Lite Slave RESPONSE out
);
```

### Connection Mapping

| Signal | axi_to_axi_lite (Master) | Direction | axi_lite_to_apb (Slave) | Compatible? |
|--------|--------------------------|-----------|-------------------------|-------------|
| **Request** | `mst_req_o` | → | `axi_lite_req_i` | ✅ YES |
| **Response** | `mst_resp_i` | ← | `axi_lite_resp_o` | ✅ YES |

**Connection:**
```systemverilog
// Intermediate signals
axi_lite_req_t  axi_lite_req;
axi_lite_resp_t axi_lite_resp;

// Module 1 output connects to Module 2 input
assign axi_lite_req = axi_to_axi_lite_inst.mst_req_o;
assign axi_to_axi_lite_inst.mst_resp_i = axi_lite_resp;

// Or directly in port connections
axi_to_axi_lite i_stage1 (
  .mst_req_o  ( axi_lite_req  ),
  .mst_resp_i ( axi_lite_resp )
);

axi_lite_to_apb i_stage2 (
  .axi_lite_req_i  ( axi_lite_req  ),
  .axi_lite_resp_o ( axi_lite_resp )
);
```

---

## 2. AXI-Lite Request Structure (`lite_req_t` / `axi_lite_req_t`)

Both modules use the **identical typedef macro**: `AXI_LITE_TYPEDEF_REQ_T`

### Structure Definition (from typedef.svh lines 181-191):

```systemverilog
typedef struct packed {
  aw_chan_lite_t aw;        // Write address channel
  logic          aw_valid;  // Write address valid
  w_chan_lite_t  w;         // Write data channel
  logic          w_valid;   // Write data valid
  logic          b_ready;   // Write response ready
  ar_chan_lite_t ar;        // Read address channel
  logic          ar_valid;  // Read address valid
  logic          r_ready;   // Read data ready
} req_lite_t;
```

### Channel Details:

#### Write Address Channel (aw_chan_lite_t):
```systemverilog
typedef struct packed {
  addr_t          addr;  // Address
  axi_pkg::prot_t prot;  // Protection type
} aw_chan_lite_t;
```

#### Write Data Channel (w_chan_lite_t):
```systemverilog
typedef struct packed {
  data_t data;  // Write data
  strb_t strb;  // Write strobes
} w_chan_lite_t;
```

#### Read Address Channel (ar_chan_lite_t):
```systemverilog
typedef struct packed {
  addr_t          addr;  // Address
  axi_pkg::prot_t prot;  // Protection type
} ar_chan_lite_t;
```

**✅ Result:** Both modules produce/consume identical request structures.

---

## 3. AXI-Lite Response Structure (`lite_resp_t` / `axi_lite_resp_t`)

Both modules use the **identical typedef macro**: `AXI_LITE_TYPEDEF_RESP_T`

### Structure Definition (from typedef.svh lines 192-201):

```systemverilog
typedef struct packed {
  logic          aw_ready;  // Write address ready
  logic          w_ready;   // Write data ready
  b_chan_lite_t  b;         // Write response channel
  logic          b_valid;   // Write response valid
  logic          ar_ready;  // Read address ready
  r_chan_lite_t  r;         // Read data channel
  logic          r_valid;   // Read data valid
} resp_lite_t;
```

### Channel Details:

#### Write Response Channel (b_chan_lite_t):
```systemverilog
typedef struct packed {
  axi_pkg::resp_t resp;  // Response status (OKAY, SLVERR, etc.)
} b_chan_lite_t;
```

#### Read Data Channel (r_chan_lite_t):
```systemverilog
typedef struct packed {
  data_t          data;  // Read data
  axi_pkg::resp_t resp;  // Response status
} r_chan_lite_t;
```

**✅ Result:** Both modules produce/consume identical response structures.

---

## 4. Signal-by-Signal Compatibility

### Request Signals (Module 1 OUT → Module 2 IN)

| Signal Path | Type | Width | Source | Sink | Match |
|-------------|------|-------|--------|------|-------|
| `aw.addr` | addr_t | AddrWidth | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `aw.prot` | axi_pkg::prot_t | 3 bits | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `aw_valid` | logic | 1 bit | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `w.data` | data_t | DataWidth | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `w.strb` | strb_t | DataWidth/8 | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `w_valid` | logic | 1 bit | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `b_ready` | logic | 1 bit | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `ar.addr` | addr_t | AddrWidth | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `ar.prot` | axi_pkg::prot_t | 3 bits | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `ar_valid` | logic | 1 bit | axi_to_axi_lite | axi_lite_to_apb | ✅ |
| `r_ready` | logic | 1 bit | axi_to_axi_lite | axi_lite_to_apb | ✅ |

**Total: 11 request signals - ALL COMPATIBLE ✅**

### Response Signals (Module 2 OUT → Module 1 IN)

| Signal Path | Type | Width | Source | Sink | Match |
|-------------|------|-------|--------|------|-------|
| `aw_ready` | logic | 1 bit | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `w_ready` | logic | 1 bit | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `b.resp` | axi_pkg::resp_t | 2 bits | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `b_valid` | logic | 1 bit | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `ar_ready` | logic | 1 bit | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `r.data` | data_t | DataWidth | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `r.resp` | axi_pkg::resp_t | 2 bits | axi_lite_to_apb | axi_to_axi_lite | ✅ |
| `r_valid` | logic | 1 bit | axi_lite_to_apb | axi_to_axi_lite | ✅ |

**Total: 8 response signals - ALL COMPATIBLE ✅**

---

## 5. Parameter Compatibility

### Data Width Requirements

| Parameter | axi_to_axi_lite | axi_lite_to_apb | Compatible? |
|-----------|-----------------|-----------------|-------------|
| Address Width | `AxiAddrWidth` | `AddrWidth` | ✅ Must match |
| Data Width | `AxiDataWidth` | `DataWidth` | ✅ Must match |
| Strobe Width | (DataWidth/8) | (DataWidth/8) | ✅ Derived same way |

**Constraint:** Both modules must use the same `AddrWidth` and `DataWidth` parameters.

### Clock and Reset

| Signal | axi_to_axi_lite | axi_lite_to_apb | Compatible? |
|--------|-----------------|-----------------|-------------|
| Clock | `clk_i` | `clk_i` | ✅ Same name |
| Reset | `rst_ni` (active low) | `rst_ni` (active low) | ✅ Same polarity |

**✅ Result:** Clock and reset can be directly connected.

---

## 6. Protocol Compatibility

### AXI4-Lite Protocol Requirements

Both modules implement **full AXI4-Lite specification**:

| Feature | axi_to_axi_lite | axi_lite_to_apb | Compatible? |
|---------|-----------------|-----------------|-------------|
| Single transfers only | ✅ Splits bursts | ✅ Expects singles | ✅ |
| No burst support | ✅ Converts to singles | ✅ Single only | ✅ |
| No ID signals | ✅ ID reflection | ✅ No IDs | ✅ |
| Fixed data width | ✅ Same width | ✅ Same width | ✅ |
| PROT support | ✅ Passes through | ✅ Maps to APB | ✅ |
| Response codes | ✅ Generates OKAY/SLVERR | ✅ Handles OKAY/SLVERR/DECERR | ✅ |

**✅ Result:** Protocol semantics are fully compatible.

### Transaction Flow

```
Full AXI Write Burst (N beats):
  ┌─────────────────┐
  │ axi_to_axi_lite │
  └─────────────────┘
         ↓
  N separate AXI-Lite write transactions
         ↓
  ┌──────────────────┐
  │ axi_lite_to_apb  │
  └──────────────────┘
         ↓
  N separate APB write transactions

Full AXI Read Burst (N beats):
  Same flow, burst → N singles → N APB reads
```

**✅ Result:** Transaction semantics preserved through the chain.

---

## 7. Timing Compatibility

### Ready/Valid Handshaking

Both modules implement **standard AXI ready/valid handshaking**:

- **Request channel:** Valid can assert without ready; transfer occurs when both are high
- **Response channel:** Valid can assert without ready; transfer occurs when both are high
- **No timing assumptions:** Both modules are fully elastic

**✅ Result:** No timing conflicts; can operate at any clock frequency.

### Pipeline Depth

| Module | Pipeline Stages | Configurable? |
|--------|-----------------|---------------|
| axi_to_axi_lite | Variable (FIFOs for ID reflection) | Yes (FallThrough param) |
| axi_lite_to_apb | 0-2 stages | Yes (PipelineRequest/Response) |

**✅ Result:** Combined latency is sum of individual latencies; both predictable.

---

## 8. Design Evidence They're Meant to Work Together

### 1. Same Source Repository
Both modules are from the **PULP platform** AXI repository:
- Maintained by the same team (ETH Zurich / Bologna)
- Part of the same IP library
- Use identical coding conventions

### 2. Consistent Naming Convention
```
axi_to_axi_lite  ← "from" full AXI "to" AXI-Lite
axi_lite_to_apb  ← "from" AXI-Lite "to" APB
```
This naming pattern suggests intentional composability.

### 3. Shared Type System
Both use:
- Same typedef macros (`AXI_LITE_TYPEDEF_*`)
- Same package (`axi_pkg`)
- Same include files

### 4. Complementary Functionality
```
axi_to_axi_lite:    Handles bursts, atomics, IDs
axi_lite_to_apb:    Handles protocol translation, multiple slaves
```
Clean separation of concerns = designed for composition.

### 5. Common Usage in PULP Platform
These modules are commonly chained in PULP SoC designs to create complete AXI-to-APB bridges.

---

## 9. Verification Checklist for Integration

When integrating these modules, verify:

- [ ] **Same address width** - Both use same `AddrWidth` parameter
- [ ] **Same data width** - Both use same `DataWidth` parameter
- [ ] **Same typedef macros** - Use `AXI_LITE_TYPEDEF_*` for intermediate types
- [ ] **Clock domain** - Both clocked by same `clk_i`
- [ ] **Reset polarity** - Both use active-low `rst_ni`
- [ ] **Address ranges** - Ensure APB address map is within AXI address space

---

## 10. Example Wrapper Module

Here's a complete example showing how to connect them:

```systemverilog
module axi_to_apb_bridge_complete #(
  // Common parameters
  parameter int unsigned AddrWidth      = 32,
  parameter int unsigned DataWidth      = 32,
  parameter int unsigned AxiIdWidth     = 4,
  parameter int unsigned AxiUserWidth   = 1,
  parameter int unsigned AxiMaxWriteTxns = 8,
  parameter int unsigned AxiMaxReadTxns  = 8,
  parameter int unsigned NoApbSlaves    = 4,
  parameter int unsigned NoApbRules     = 4,
  // Type parameters
  parameter type axi_req_t  = logic,
  parameter type axi_resp_t = logic,
  parameter type apb_req_t  = logic,
  parameter type apb_resp_t = logic,
  parameter type rule_t     = logic
) (
  input  logic                        clk_i,
  input  logic                        rst_ni,
  input  logic                        test_i,
  // Full AXI slave
  input  axi_req_t                    axi_req_i,
  output axi_resp_t                   axi_resp_o,
  // APB master(s)
  output apb_req_t  [NoApbSlaves-1:0] apb_req_o,
  input  apb_resp_t [NoApbSlaves-1:0] apb_resp_i,
  input  rule_t     [NoApbRules-1:0]  addr_map_i
);

  // Define intermediate AXI-Lite types using same typedefs
  typedef logic [AddrWidth-1:0]   addr_t;
  typedef logic [DataWidth-1:0]   data_t;
  typedef logic [DataWidth/8-1:0] strb_t;
  
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(axi_lite_req_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)
  `AXI_LITE_TYPEDEF_RESP_T(axi_lite_resp_t, b_chan_lite_t, r_chan_lite_t)
  
  // Intermediate AXI-Lite signals
  axi_lite_req_t  axi_lite_req;
  axi_lite_resp_t axi_lite_resp;
  
  // Stage 1: Full AXI to AXI-Lite
  axi_to_axi_lite #(
    .AxiAddrWidth    ( AddrWidth         ),
    .AxiDataWidth    ( DataWidth         ),
    .AxiIdWidth      ( AxiIdWidth        ),
    .AxiUserWidth    ( AxiUserWidth      ),
    .AxiMaxWriteTxns ( AxiMaxWriteTxns   ),
    .AxiMaxReadTxns  ( AxiMaxReadTxns    ),
    .full_req_t      ( axi_req_t         ),
    .full_resp_t     ( axi_resp_t        ),
    .lite_req_t      ( axi_lite_req_t    ),
    .lite_resp_t     ( axi_lite_resp_t   )
  ) i_axi_to_axi_lite (
    .clk_i       ( clk_i         ),
    .rst_ni      ( rst_ni        ),
    .test_i      ( test_i        ),
    .slv_req_i   ( axi_req_i     ),
    .slv_resp_o  ( axi_resp_o    ),
    .mst_req_o   ( axi_lite_req  ),  // ← Connects to next stage
    .mst_resp_i  ( axi_lite_resp )   // ← Connects to next stage
  );
  
  // Stage 2: AXI-Lite to APB
  axi_lite_to_apb #(
    .NoApbSlaves      ( NoApbSlaves      ),
    .NoRules          ( NoApbRules       ),
    .AddrWidth        ( AddrWidth        ),
    .DataWidth        ( DataWidth        ),
    .axi_lite_req_t   ( axi_lite_req_t   ),
    .axi_lite_resp_t  ( axi_lite_resp_t  ),
    .apb_req_t        ( apb_req_t        ),
    .apb_resp_t       ( apb_resp_t       ),
    .rule_t           ( rule_t           )
  ) i_axi_lite_to_apb (
    .clk_i            ( clk_i         ),
    .rst_ni           ( rst_ni        ),
    .axi_lite_req_i   ( axi_lite_req  ),  // ← From previous stage
    .axi_lite_resp_o  ( axi_lite_resp ),  // ← To previous stage
    .apb_req_o        ( apb_req_o     ),
    .apb_resp_i       ( apb_resp_i    ),
    .addr_map_i       ( addr_map_i    )
  );

endmodule
```

---

## 11. Conclusion

### Compatibility Summary

| Aspect | Status | Notes |
|--------|--------|-------|
| **Port Types** | ✅ COMPATIBLE | Same typedef macros |
| **Signal Names** | ✅ COMPATIBLE | Standard AXI-Lite naming |
| **Signal Widths** | ✅ COMPATIBLE | Parameterized consistently |
| **Protocol** | ✅ COMPATIBLE | Both AXI-Lite compliant |
| **Timing** | ✅ COMPATIBLE | Standard ready/valid |
| **Clocking** | ✅ COMPATIBLE | Same clock/reset signals |
| **Design Intent** | ✅ COMPATIBLE | From same IP library |

### Final Verdict

**✅ These modules are PERFECTLY COMPATIBLE and DESIGNED to work together.**

You can confidently chain them to create a complete AXI-to-APB bridge. The interface is not just compatible by accident - it's compatible by design, using a shared type system and protocol standards from the same IP library.

### Recommended Next Steps

1. ✅ Start with `axi_lite_to_apb` testbench (simpler)
2. ✅ Add `axi_to_axi_lite` wrapper later
3. ✅ Use the provided wrapper example as a starting point
4. ✅ Add intermediate monitors for both interfaces in your UVM environment

---

**Document Version:** 1.0  
**Date:** 2026-01-27  
**Analysis Based On:** PULP Platform AXI IP Library

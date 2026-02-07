# AXI-Lite to APB Bridge - Complete Struct Reference

**Module:** `axi_lite_to_apb.sv`  
**Purpose:** Complete documentation of all struct types with unpacked signal definitions  
**Date:** 2026-01-27

---

## Table of Contents

1. [AXI4-Lite Request/Response Structs](#axi4-lite-requestresponse-structs)
2. [AXI4-Lite Channel Structs](#axi4-lite-channel-structs)
3. [APB4 Structs](#apb4-structs)
4. [Internal Bridge Structs](#internal-bridge-structs)
5. [Support Types](#support-types)
   - Basic Typedefs (addr_t, data_t, strb_t)
   - APB State Machine Enum
   - Address Decoder Rule
6. [Signal Flow Diagram](#signal-flow-diagram)
7. [Struct Size Summary](#struct-size-summary)

---

## AXI4-Lite Request/Response Structs

### 1. `axi_lite_req_t` - AXI4-Lite Request Struct

**Defined at:** `axi/include/axi/typedef.svh` (lines 181-191)

```systemverilog
typedef struct packed {
  aw_chan_lite_t aw;       // Write address channel
  logic          aw_valid; // Write address valid
  w_chan_lite_t  w;        // Write data channel
  logic          w_valid;  // Write data valid
  logic          b_ready;  // Write response ready
  ar_chan_lite_t ar;       // Read address channel
  logic          ar_valid; // Read address valid
  logic          r_ready;  // Read data ready
} axi_lite_req_t;
```

**Unpacked Signal List:**

| Signal Path | Type | Width | Direction | Description |
|------------|------|-------|-----------|-------------|
| `aw.addr` | `addr_t` | 32 | Input | Write address |
| `aw.prot` | `logic [2:0]` | 3 | Input | Write protection type |
| `aw_valid` | `logic` | 1 | Input | Write address valid |
| `w.data` | `data_t` | 32 | Input | Write data |
| `w.strb` | `strb_t` | 4 | Input | Write byte strobes |
| `w_valid` | `logic` | 1 | Input | Write data valid |
| `b_ready` | `logic` | 1 | Input | Write response ready (master accepts) |
| `ar.addr` | `addr_t` | 32 | Input | Read address |
| `ar.prot` | `logic [2:0]` | 3 | Input | Read protection type |
| `ar_valid` | `logic` | 1 | Input | Read address valid |
| `r_ready` | `logic` | 1 | Input | Read data ready (master accepts) |

**Total Signals:** 11 (all master-to-slave)

---

### 2. `axi_lite_resp_t` - AXI4-Lite Response Struct

**Defined at:** `axi/include/axi/typedef.svh` (lines 192-201)

```systemverilog
typedef struct packed {
  logic          aw_ready; // Write address ready
  logic          w_ready;  // Write data ready
  b_chan_lite_t  b;        // Write response channel
  logic          b_valid;  // Write response valid
  logic          ar_ready; // Read address ready
  r_chan_lite_t  r;        // Read data channel
  logic          r_valid;  // Read data valid
} axi_lite_resp_t;
```

**Unpacked Signal List:**

| Signal Path | Type | Width | Direction | Description |
|------------|------|-------|-----------|-------------|
| `aw_ready` | `logic` | 1 | Output | Write address ready (slave accepts) |
| `w_ready` | `logic` | 1 | Output | Write data ready (slave accepts) |
| `b.resp` | `logic [1:0]` | 2 | Output | Write response status |
| `b_valid` | `logic` | 1 | Output | Write response valid |
| `ar_ready` | `logic` | 1 | Output | Read address ready (slave accepts) |
| `r.data` | `data_t` | 32 | Output | Read data |
| `r.resp` | `logic [1:0]` | 2 | Output | Read response status |
| `r_valid` | `logic` | 1 | Output | Read data valid |

**Total Signals:** 8 (all slave-to-master)

**Response Codes (`b.resp`, `r.resp`):**
- `2'b00`: `RESP_OKAY` - Success
- `2'b10`: `RESP_SLVERR` - Slave error
- `2'b11`: `RESP_DECERR` - Decode error

---

## AXI4-Lite Channel Structs

### 3. `aw_chan_lite_t` - Write Address Channel

**Defined at:** `axi/include/axi/typedef.svh` (lines 157-161)

```systemverilog
typedef struct packed {
  addr_t          addr; // [31:0]
  axi_pkg::prot_t prot; // [2:0]
} aw_chan_lite_t;
```

| Field | Width | Description |
|-------|-------|-------------|
| `addr` | 32 bits | Write address |
| `prot[2]` | 1 bit | 0=Data, 1=Instruction access |
| `prot[1]` | 1 bit | 0=Secure, 1=Non-secure |
| `prot[0]` | 1 bit | 0=Unprivileged, 1=Privileged |

---

### 4. `w_chan_lite_t` - Write Data Channel

**Defined at:** `axi/include/axi/typedef.svh` (lines 162-166)

```systemverilog
typedef struct packed {
  data_t data; // [31:0]
  strb_t strb; // [3:0]
} w_chan_lite_t;
```

| Field | Width | Description |
|-------|-------|-------------|
| `data` | 32 bits | Write data |
| `strb[3]` | 1 bit | Byte lane [31:24] valid |
| `strb[2]` | 1 bit | Byte lane [23:16] valid |
| `strb[1]` | 1 bit | Byte lane [15:8] valid |
| `strb[0]` | 1 bit | Byte lane [7:0] valid |

---

### 5. `b_chan_lite_t` - Write Response Channel

**Defined at:** `axi/include/axi/typedef.svh` (lines 167-170)

```systemverilog
typedef struct packed {
  axi_pkg::resp_t resp; // [1:0]
} b_chan_lite_t;
```

| Field | Width | Description |
|-------|-------|-------------|
| `resp` | 2 bits | Write response status |

---

### 6. `ar_chan_lite_t` - Read Address Channel

**Defined at:** `axi/include/axi/typedef.svh` (lines 171-175)

```systemverilog
typedef struct packed {
  addr_t          addr; // [31:0]
  axi_pkg::prot_t prot; // [2:0]
} ar_chan_lite_t;
```

**Identical to `aw_chan_lite_t`** - same fields and bit definitions.

---

### 7. `r_chan_lite_t` - Read Data Channel

**Defined at:** `axi/include/axi/typedef.svh` (lines 176-180)

```systemverilog
typedef struct packed {
  data_t          data; // [31:0]
  axi_pkg::resp_t resp; // [1:0]
} r_chan_lite_t;
```

| Field | Width | Description |
|-------|-------|-------------|
| `data` | 32 bits | Read data |
| `resp` | 2 bits | Read response status |

---

## APB4 Structs

### 8. `apb_req_t` - APB4 Request Struct

**Defined at:** `axi_lite_to_apb.sv` (lines 421-429)

```systemverilog
typedef struct packed {
  addr_t          paddr;   // [31:0] Address
  axi_pkg::prot_t pprot;   // [2:0] Protection
  logic           psel;    // Select
  logic           penable; // Enable
  logic           pwrite;  // Write=1, Read=0
  data_t          pwdata;  // [31:0] Write data
  strb_t          pstrb;   // [3:0] Write strobes
} apb_req_t;
```

**Unpacked Signal List:**

| Signal | Width | Description | APB Spec |
|--------|-------|-------------|----------|
| `paddr` | 32 | APB address (aligned) | PADDR |
| `pprot[2:0]` | 3 | Protection (maps from AXI) | PPROT |
| `psel` | 1 | Peripheral select | PSEL |
| `penable` | 1 | Enable (0=Setup, 1=Access) | PENABLE |
| `pwrite` | 1 | Write enable | PWRITE |
| `pwdata` | 32 | Write data | PWDATA |
| `pstrb` | 4 | Write byte strobes | PSTRB |

**APB Protocol Phases:**
- **Setup:** `psel=1`, `penable=0` (1 clock cycle)
- **Access:** `psel=1`, `penable=1` (wait for `pready=1`)

**Note:** One `apb_req_t` generated per APB slave. Only selected slave has `psel=1`.

---

### 9. `apb_resp_t` - APB4 Response Struct

**Defined at:** `axi_lite_to_apb.sv` (lines 431-435)

```systemverilog
typedef struct packed {
  logic  pready;  // Ready
  data_t prdata;  // [31:0] Read data
  logic  pslverr; // Slave error
} apb_resp_t;
```

**Unpacked Signal List:**

| Signal | Width | Description | APB Spec |
|--------|-------|-------------|----------|
| `pready` | 1 | Slave ready (transfer complete) | PREADY |
| `prdata` | 32 | Read data | PRDATA |
| `pslverr` | 1 | Slave error (0=OK, 1=ERROR) | PSLVERR |

**Error Mapping:**
- `pslverr=0` → `axi_pkg::RESP_OKAY`
- `pslverr=1` → `axi_pkg::RESP_SLVERR`

---

## Internal Bridge Structs

### 10. `int_req_t` - Internal Request Struct

**Defined at:** `axi_lite_to_apb.sv` (lines 82-88)

```systemverilog
typedef struct packed {
  addr_t          addr;  // [31:0] Address
  axi_pkg::prot_t prot;  // [2:0] Protection
  data_t          data;  // [31:0] Write data
  strb_t          strb;  // [3:0] Write strobes
  logic           write; // 1=Write, 0=Read
} int_req_t;
```

**Purpose:** Unified internal request format after merging AXI channels.

**Sources:**
- **Read:** From `ar` channel (`data=0`, `strb=0`, `write=0`)
- **Write:** From `aw` + `w` channels (`write=1`)

**Flow:**
```
AXI Read:  ar_chan_lite_t → int_req_t[RD]
AXI Write: (aw_chan_lite_t + w_chan_lite_t) → int_req_t[WR]
           → Arbitration → Single int_req_t → APB FSM
```

---

### 11. `int_resp_t` - Internal Response Struct

**Defined at:** `axi_lite_to_apb.sv` (lines 89-92)

```systemverilog
typedef struct packed {
  data_t          data; // [31:0] Read data
  axi_pkg::resp_t resp; // [1:0] Response code
} int_resp_t;
```

**Purpose:** Internal response format before routing to AXI B or R channel.

**Destinations:**
- **Write:** `resp` → B channel
- **Read:** `data` + `resp` → R channel

---

## Support Types

### 12. Basic Typedefs - Fundamental Data Types

**Defined at:** `axi_lite_to_apb.sv` (lines 77-79)

These are the basic building block types used throughout all structs in the bridge:

```systemverilog
typedef logic [AddrWidth-1:0]   addr_t;  // Address type
typedef logic [DataWidth-1:0]   data_t;  // Data type
typedef logic [DataWidth/8-1:0] strb_t;  // Strobe type
```

**Type Definitions:**

| Type | Definition | Typical Width | Description |
|------|------------|---------------|-------------|
| `addr_t` | `logic [AddrWidth-1:0]` | 32 bits | Address bus width (configurable via parameter) |
| `data_t` | `logic [DataWidth-1:0]` | 32 bits | Data bus width (configurable via parameter) |
| `strb_t` | `logic [DataWidth/8-1:0]` | 4 bits | Write strobe width (1 bit per byte lane) |

**Parameter Dependencies:**

```systemverilog
// Module parameters that define these types:
parameter int unsigned AddrWidth = 32'd32,  // Typical: 32-bit addressing
parameter int unsigned DataWidth = 32'd32   // Typical: 32-bit data
```

**Examples for Different Configurations:**

| DataWidth | addr_t | data_t | strb_t | Use Case |
|-----------|--------|--------|--------|----------|
| 32 | `[31:0]` | `[31:0]` | `[3:0]` | Standard 32-bit system |
| 64 | `[31:0]` | `[63:0]` | `[7:0]` | 64-bit data path |
| 128 | `[31:0]` | `[127:0]` | `[15:0]` | High-performance system |

**Strobe Bit Mapping:**

For 32-bit data (`DataWidth=32`):
```
strb_t = logic [3:0]
  strb[3] → data[31:24]  (byte 3)
  strb[2] → data[23:16]  (byte 2)
  strb[1] → data[15:8]   (byte 1)
  strb[0] → data[7:0]    (byte 0)
```

**Usage in Structs:**

These types appear in:
- **AXI4-Lite channels:** `aw_chan_lite_t`, `w_chan_lite_t`, `ar_chan_lite_t`, `r_chan_lite_t`
- **APB4 structs:** `apb_req_t`, `apb_resp_t`
- **Internal structs:** `int_req_t`, `int_resp_t`

**Design Note:** Using typedefs allows the bridge to be parameterized for different address and data widths without changing the struct definitions. The same code works for 32-bit, 64-bit, or wider configurations.

---

### 13. `apb_state_e` - APB FSM State

**Defined at:** `axi_lite_to_apb.sv` (lines 93-96)

```systemverilog
typedef enum logic {
  Setup  = 1'b0, // Idle or Setup phase
  Access = 1'b1  // Access phase
} apb_state_e;
```

**State Machine:**
```
       ┌─────────────┐
       │    Setup    │──────┐
       │ (penable=0) │      │ No request or decode error
       └─────────────┘◄─────┘
             │
             │ Valid request & address OK
             ▼
       ┌─────────────┐
       │   Access    │──────┐
       │ (penable=1) │      │ pready=0 (wait)
       └─────────────┘◄─────┘
             │
             │ pready=1
             ▼
       Back to Setup
```

---

### 14. `rule_t` - Address Decoder Rule

**External type from `common_cells/addr_decode.sv`**

```systemverilog
typedef struct packed {
  int unsigned idx;        // Slave index
  addr_t       start_addr; // Start address
  addr_t       end_addr;   // End address (inclusive)
} rule_t;
```

**Example:**
```systemverilog
rule_t [1:0] addr_map = '{
  '{idx: 0, start_addr: 32'h1000_0000, end_addr: 32'h1000_0FFF},
  '{idx: 1, start_addr: 32'h2000_0000, end_addr: 32'h2000_0FFF}
};
```

---

## Signal Flow Diagram

```
┌─────────────────────────────────────────────┐
│         AXI4-Lite Slave Interface           │
│                                             │
│  Input:  axi_lite_req_t                     │
│    ├─ aw: {addr[31:0], prot[2:0]}           │
│    ├─ w:  {data[31:0], strb[3:0]}           │
│    └─ ar: {addr[31:0], prot[2:0]}           │
│                                             │
│  Output: axi_lite_resp_t                    │
│    ├─ b: {resp[1:0]}                        │
│    └─ r: {data[31:0], resp[1:0]}            │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│         Channel → Internal Format           │
│                                             │
│  ar → int_req_t[RD]                         │
│    {addr, prot, data=0, strb=0, write=0}    │
│                                             │
│  aw+w → int_req_t[WR]                       │
│    {addr, prot, data, strb, write=1}        │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│         Round-Robin Arbitration             │
│  (rr_arb_tree: read vs write priority)      │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│      Optional Request Spill Register        │
│  (Pipeline stage if PipelineRequest=1)      │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│            APB Master FSM                   │
│                                             │
│  State: apb_state_e                         │
│    Setup → Access → Setup                   │
│                                             │
│  Address Decode:                            │
│    addr → rule_t matching → slave_idx       │
│                                             │
│  Generate: apb_req_t[slave_idx]             │
│    {paddr, pprot, psel, penable,            │
│     pwrite, pwdata, pstrb}                  │
│                                             │
│  Receive: apb_resp_t[slave_idx]             │
│    {pready, prdata, pslverr}                │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│           APB Master Interface              │
│                                             │
│  Output: apb_req_t [NoApbSlaves-1:0]        │
│    Per-slave request with psel routing      │
│                                             │
│  Input:  apb_resp_t [NoApbSlaves-1:0]       │
│    Per-slave response                       │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│         Response Path (back to AXI)         │
│                                             │
│  APB → Internal:                            │
│    Write: apb_wresp (resp_t)                │
│    Read:  apb_rresp (int_resp_t)            │
│                                             │
│  Spill Registers (if PipelineResponse=1)    │
│                                             │
│  Internal → AXI:                            │
│    Write: resp → b.resp                     │
│    Read:  {data, resp} → r.{data, resp}     │
└─────────────────────────────────────────────┘
```

---

## Struct Size Summary

**Configuration:** AddrWidth=32, DataWidth=32

| Struct Name | Total Bits | Breakdown |
|-------------|-----------|-----------|
| `axi_lite_req_t` | 106 | aw(35) + aw_valid(1) + w(36) + w_valid(1) + b_ready(1) + ar(35) + ar_valid(1) + r_ready(1) |
| `axi_lite_resp_t` | 72 | aw_ready(1) + w_ready(1) + b(2) + b_valid(1) + ar_ready(1) + r(34) + r_valid(1) |
| `aw_chan_lite_t` | 35 | addr(32) + prot(3) |
| `w_chan_lite_t` | 36 | data(32) + strb(4) |
| `b_chan_lite_t` | 2 | resp(2) |
| `ar_chan_lite_t` | 35 | addr(32) + prot(3) |
| `r_chan_lite_t` | 34 | data(32) + resp(2) |
| `apb_req_t` | 71 | paddr(32) + pprot(3) + psel(1) + penable(1) + pwrite(1) + pwdata(32) + pstrb(4) |
| `apb_resp_t` | 34 | pready(1) + prdata(32) + pslverr(1) |
| `int_req_t` | 72 | addr(32) + prot(3) + data(32) + strb(4) + write(1) |
| `int_resp_t` | 34 | data(32) + resp(2) |

---

## Key Design Points

### 1. Struct Hierarchy
- **Top Level:** `axi_lite_req_t` / `axi_lite_resp_t` (external interface)
- **Channel Level:** Individual channel structs (aw, w, b, ar, r)
- **Internal Level:** `int_req_t` / `int_resp_t` (merged format)
- **APB Level:** `apb_req_t` / `apb_resp_t` (protocol-specific)

### 2. Protocol Conversion
- **AXI → Internal:** Separate read/write paths merged into common format
- **Internal → APB:** Unified request generates 2-phase APB transaction
- **APB → AXI:** Response routed back to appropriate channel (B or R)

### 3. Address Alignment
- AXI4-Lite allows unaligned addresses
- APB4 requires aligned addresses
- Bridge auto-aligns using `axi_pkg::aligned_addr()`
- Data always bus-aligned in both protocols

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-27  
**Module:** `axi_lite_to_apb.sv` from PULP Platform

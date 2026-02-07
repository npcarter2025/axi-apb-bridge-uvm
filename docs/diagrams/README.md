# AXI-Lite to APB Bridge Diagrams

This directory contains PlantUML diagrams documenting the `axi_lite_to_apb` module architecture and behavior, as well as supporting modules from the common_cells library.

## Directory Structure

```
diagrams/
├── axi_lite_to_apb_*.puml/png     # Main bridge diagrams
├── fall_through_register/         # Zero-latency register diagrams
│   ├── architecture.puml
│   ├── fsm.puml
│   ├── timing.puml
│   ├── signal_flow.puml
│   └── README.md
├── spill_register/                # Full-isolation register diagrams
│   ├── architecture.puml
│   ├── fsm.puml
│   ├── timing.puml
│   ├── signal_flow.puml
│   └── README.md
├── spill_register_flushable/      # Flushable spill register diagrams
│   ├── architecture.puml
│   ├── fsm.puml
│   ├── timing.puml
│   ├── signal_flow.puml
│   └── README.md
└── rr_arb_tree/                   # Round-robin arbiter diagrams
    ├── architecture.puml
    ├── fsm.puml
    ├── timing.puml
    ├── signal_flow.puml
    └── README.md
```

## Available Diagrams

All diagrams are available in both PlantUML source (`.puml`) and rendered PNG formats.

### 1. Architecture Diagram
- **Source:** `axi_lite_to_apb_architecture.puml`
- **PNG:** `axi_lite_to_apb_architecture.png` (114 KB)
- **Purpose:** High-level architectural overview of the bridge module

**Shows:**
- Module interfaces (AXI4-Lite slave, APB4 master)
- Internal components and data flow
- Arbitration between read and write channels
- Optional pipeline stages
- Address decoder integration
- APB FSM states
- Response routing

**Key Features Highlighted:**
- Parameter configuration options
- Error handling mechanisms
- Pipeline stages (request and response)
- Multi-slave APB support
![Architecture](axi_lite_to_apb_architecture.png)
### 2. FSM State Diagram
- **Source:** `axi_lite_to_apb_fsm.puml`
- **PNG:** `axi_lite_to_apb_fsm.png` (120 KB)
- **Purpose:** Detailed state machine diagram for the APB master FSM

**Shows:**
- Two main states: Setup and Access
- Decode error handling path
- State transitions with conditions
- Actions performed in each state
- Response generation logic

**Key Details:**
- APB protocol phases (Setup vs Access)
- PSEL and PENABLE signal control
- PREADY handshaking
- Error response mapping (pslverr → AXI response)
- Address alignment handling
![FSM](axi_lite_to_apb_fsm.png)

### 3. Signal Flow Diagram
- **Source:** `axi_lite_to_apb_signal_flow.puml`
- **PNG:** `axi_lite_to_apb_signal_flow.png` (216 KB)
- **Purpose:** End-to-end signal flow for read and write transactions

**Shows:**
- Complete transaction sequences
- Read transaction flow
- Write transaction flow
- Decode error handling
- Zero-strobe write bypass

**Components:**
- AXI master interaction
- Internal processing stages
- APB slave interaction
- Pipeline stages
![Signal Flow](axi_lite_to_apb_signal_flow.png)

### 4. Timing Waveform Diagram
- **Source:** `axi_lite_to_apb_timing.puml`
- **PNG:** `axi_lite_to_apb_timing.png` (31 KB)
- **Purpose:** Detailed timing waveforms showing signal behavior over time

**Shows:**
- Clock-cycle accurate waveforms
- AXI handshake signals (valid/ready)
- APB FSM state transitions
- APB protocol signals (psel, penable, pwrite, pready)
- Read and write transaction timing
- 2-phase APB protocol visualization
![Timing](axi_lite_to_apb_timing.png)

### 5. Sequence Timing Diagram
- **Source:** `axi_lite_to_apb_timing_simple.puml`
- **PNG:** `axi_lite_to_apb_timing_simple.png` (70 KB)
- **Purpose:** Transaction timing and protocol interaction (sequence style)


**Shows:**
- Read transaction sequence
- Write transaction sequence
- Decode error transaction
- APB 2-phase protocol (Setup & Access)
- Signal interactions between AXI and APB

![timing_simple](axi_lite_to_apb_timing_simple.png)

## Viewing the Diagrams

### Online Viewers
1. **PlantUML Web Server:** http://www.plantuml.com/plantuml/uml/
   - Copy and paste the diagram code
   - Or upload the .puml file

2. **PlantText:** https://www.planttext.com/
   - Paste the code and render

### Local Tools
1. **VS Code Extensions:**
   - PlantUML extension by jebbs
   - Requires Java and Graphviz installed

2. **Command Line:**
   ```bash
   # Generate PNG
   plantuml axi_lite_to_apb_architecture.puml
   
   # Generate SVG
   plantuml -tsvg axi_lite_to_apb_architecture.puml
   ```

3. **IntelliJ IDEA:**
   - PlantUML integration plugin available

## Design Documentation References

These diagrams complement the following documentation:
- `/dut_axi_lite/axi_lite_to_apb.sv` - Source code
- `/docs/testbench_plans/README_AXI_LITE.md` - AXI-Lite documentation
- `/docs/testbench_plans/UVM_TESTBENCH_ARCHITECTURE.md` - Testbench design

## Key Design Points

### Protocol Conversion
- **AXI4-Lite:** Split transaction protocol with separate address and data channels
- **APB4:** Two-phase protocol (Setup + Access) with combined address and data

### Arbitration
- Round-robin arbitration between read and write channels
- Lock-in support to prevent starvation
- Single outstanding APB transaction at a time

### Address Decoding
- Configurable address map for multiple APB slaves
- Each slave gets dedicated `psel` signal
- Decode errors generate AXI DECERR response without APB transaction

### Pipeline Options
- Optional request pipeline (PipelineRequest parameter)
- Optional response pipeline (PipelineResponse parameter)
- Spill register or fall-through register modes

### Error Handling
- Unmapped addresses → RESP_DECERR
- APB pslverr → RESP_SLVERR
- Valid APB response → RESP_OKAY
- Zero-strobe writes bypass APB (RESP_OKAY)
- Default error data: 0xDEA110C8

### Address Alignment
- APB addresses aligned per APB spec 2.1.1
- AXI4-Lite data always bus-aligned regardless of address
- Uses `axi_pkg::aligned_addr()` function

## Module Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| NoApbSlaves | 1 | Number of APB slaves connected |
| NoRules | 1 | Number of address decode rules |
| AddrWidth | 32 | Address bus width (must match AXI and APB) |
| DataWidth | 32 | Data bus width (must match AXI and APB) |
| PipelineRequest | 0 | Enable request path pipelining |
| PipelineResponse | 0 | Enable response path pipelining |

## Verification Considerations

When verifying this design, pay attention to:
1. **Arbitration fairness** between read and write channels
2. **Back-pressure handling** via ready signals
3. **Decode error scenarios** with unmapped addresses
4. **APB timing compliance** (2-phase protocol)
5. **Address alignment** edge cases
6. **Multiple APB slaves** selection
7. **Pipeline behavior** with various parameters
8. **Error response mapping** correctness

Refer to `/docs/testbench_plans/VERIFICATION_PLAN.md` for detailed test scenarios.

## Supporting Module Diagrams

### Fall-Through Register (`fall_through_register/`)

Complete diagram set for the `fall_through_register` module from common_cells library.

**Key Characteristics:**
- Zero-latency when downstream ready
- Cuts combinational path on ready signal only
- Based on FIFO_v3 with FALL_THROUGH=1, DEPTH=1
- Valid and data paths remain combinational

**Diagrams Available:**
1. **Architecture** - Internal FIFO structure and signal routing
2. **FSM** - Two-state machine (EMPTY/FULL)
3. **Timing** - Waveforms showing zero-latency and buffering behavior
4. **Signal Flow** - Data/control paths with timing analysis

**Use Case:** Back-pressure isolation with minimal latency

See `fall_through_register/README.md` for detailed documentation.

---

### Spill Register (`spill_register/`)

Complete diagram set for the `spill_register` and `spill_register_flushable` modules.

**Key Characteristics:**
- Always has ≥1 cycle latency
- Complete combinational path isolation (ready, valid, data)
- Two-register architecture (A + B)
- Can buffer up to 2 data items
- Prioritizes older data (FIFO ordering)

**Diagrams Available:**
1. **Architecture** - Two-register structure with fill/drain control
2. **FSM** - Four-state machine based on register occupancy
3. **Timing** - Waveforms showing latency and buffering behavior
4. **Signal Flow** - Complete path isolation analysis

**Use Case:** Timing closure, breaking critical combinational paths

See `spill_register/README.md` for detailed documentation.

---

### Register Comparison

| Feature | Fall-Through | Spill Register |
|---------|-------------|----------------|
| **Min Latency** | 0 cycles | 1 cycle |
| **Max Buffering** | 1 item | 2 items |
| **Ready Path** | Registered ✓ | Registered ✓ |
| **Valid Path** | Combinational | Registered ✓ |
| **Data Path** | Can be combinational | Registered ✓ |
| **Timing Isolation** | Partial (ready only) | Complete |
| **Use Case** | Minimal latency | Timing closure |

Both registers are used in the AXI-Lite to APB bridge's optional pipeline stages.

---

### Spill Register Flushable (`spill_register_flushable/`)

Complete diagram set for the `spill_register_flushable` module - the actual implementation with flush capability.

**Key Characteristics:**
- Same two-register architecture as spill_register
- **Flush capability**: Synchronous clear of both registers
- **Optional bypass mode**: Parameter-controlled transparent mode
- Complete combinational path isolation (non-bypass mode)
- Assertion checks prevent flush+valid conflicts

**Diagrams Available:**
1. **Architecture** - Two-register structure with flush logic and bypass mode
2. **FSM** - Four-state machine with flush transitions from all states
3. **Timing** - Waveforms showing flush operation and recovery
4. **Signal Flow** - Sequence demonstrating flush clearing both registers

**Use Case:** Timing closure with pipeline abort/reset capability

See `spill_register_flushable/README.md` for detailed documentation.

---

### Round-Robin Arbiter Tree (`rr_arb_tree/`)

Complete diagram set for the `rr_arb_tree` module - logarithmic arbitration with rotating priorities.

**Key Characteristics:**
- **O(log N) delay** through tree structure
- Non-starving round-robin arbitration
- Configurable fair vs unfair arbitration
- Optional lock-in prevents decision change when stalled
- External priority support for synchronized arbiters
- AXI valid/ready handshake mode

**Diagrams Available:**
1. **Architecture** - Tree structure with priority management and modes
2. **FSM** - State machine showing arbitration and priority rotation
3. **Timing** - Cycle-by-cycle showing priority rotation through inputs
4. **Signal Flow** - Sequence showing how priorities rotate and lock-in works

**Use Case:** Fair arbitration between multiple requesters (used in AXI bridge)

See `rr_arb_tree/README.md` for detailed documentation including all parameters.

---

### Module Summary

| Module | Purpose | Latency | Key Feature |
|--------|---------|---------|-------------|
| **fall_through_register** | Back-pressure isolation | 0-1 cycle | Zero-latency mode |
| **spill_register** | Complete timing isolation | ≥1 cycle | Two-register buffering |
| **spill_register_flushable** | Isolation + flush | ≥1 cycle | Flush capability |
| **rr_arb_tree** | Fair arbitration | O(log N) | Round-robin priorities |

All modules are from the common_cells library and used throughout the AXI-Lite to APB bridge.

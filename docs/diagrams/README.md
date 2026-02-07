# AXI-Lite to APB Bridge Diagrams

This directory contains PlantUML diagrams documenting the `axi_lite_to_apb` module architecture and behavior.

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

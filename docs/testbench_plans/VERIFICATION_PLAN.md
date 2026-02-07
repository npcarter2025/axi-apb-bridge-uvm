# Verification Plan: AXI-Lite to APB Bridge (Phase 1)
**DUT:** `axi_lite_to_apb.sv`  
**Protocol:** AXI4-Lite → APB4  
**Author:** Nathan Carter  
**Date:** 2026-01-27

---

## 1. DUT Overview

### 1.1 Module Parameters
```systemverilog
module axi_lite_to_apb #(
  parameter int unsigned NoApbSlaves = 32'd1,     // Number of APB slaves
  parameter int unsigned NoRules     = 32'd1,     // Address decode rules
  parameter int unsigned AddrWidth   = 32'd32,    // Address width
  parameter int unsigned DataWidth   = 32'd32,    // Data width
  parameter bit PipelineRequest      = 1'b0,      // Pipeline req path
  parameter bit PipelineResponse     = 1'b0,      // Pipeline resp path
  // Type parameters...
)
```

### 1.2 Key Features to Verify
1. ✅ **Protocol conversion** (AXI4-Lite → APB4)
2. ✅ **Address decoding** (multiple APB slaves)
3. ✅ **Pipeline configurations** (4 combinations)
4. ✅ **Error handling** (DECERR, SLVERR)
5. ✅ **Data integrity** (write/read correctness)

---

## 2. Feature Verification Matrix

| Feature | Priority | Verification Method | Coverage Goal |
|---------|----------|---------------------|---------------|
| **Basic Write** | P0 | Directed + Random | 100% |
| **Basic Read** | P0 | Directed + Random | 100% |
| **Address Decode** | P0 | Directed | 100% |
| **Back-to-Back Txns** | P0 | Random | >95% |
| **Pipeline Modes** | P0 | Directed | 100% (all 4) |
| **DECERR Response** | P1 | Directed | 100% |
| **SLVERR Response** | P1 | Directed | 100% |
| **APB Wait States** | P1 | Random | >90% |
| **Outstanding Txns** | P2 | Random | >80% |
| **Reset Handling** | P2 | Directed | 100% |

---

## 3. Test Plan

### 3.1 Test Suite Overview

```
tests/axi_lite_to_apb_tests/
├── Sanity (P0)
│   ├── Single write
│   ├── Single read
│   └── Write-then-read
├── Functional (P0)
│   ├── All slaves addressed
│   ├── All pipeline configs
│   ├── Error responses
│   └── Data patterns
├── Random (P0)
│   ├── Constrained random
│   ├── Back-to-back
│   └── Mixed read/write
├── Stress (P1)
│   ├── Maximum throughput
│   ├── Maximum APB delays
│   └── Boundary addresses
└── Corner Cases (P2)
    ├── Reset during transaction
    ├── Address boundaries
    └── Data bus width patterns
```

### 3.2 Detailed Test Cases

#### TC001: Sanity - Basic Write
**Objective:** Verify single write transaction  
**Stimulus:**
- AXI-Lite master issues single AW+W to valid address
- APB slave responds immediately (PREADY=1)

**Expected:**
- APB PSEL, PENABLE sequence correct
- PWRITE=1, PWDATA matches WDATA
- AXI-Lite B channel returns RESP=OKAY

**Coverage:**
- Write channel handshake
- APB write protocol
- Response propagation

---

#### TC002: Sanity - Basic Read
**Objective:** Verify single read transaction  
**Stimulus:**
- AXI-Lite master issues single AR to valid address
- APB slave responds with data

**Expected:**
- APB PSEL, PENABLE sequence correct
- PWRITE=0
- AXI-Lite R channel returns PRDATA with RESP=OKAY

**Coverage:**
- Read channel handshake
- APB read protocol
- Data propagation

---

#### TC003: Functional - All Slaves Addressed
**Objective:** Verify address decoding to all APB slaves  
**Stimulus:**
- Configure with NoApbSlaves=4
- Issue writes to each slave's address range
- Issue reads from each slave

**Expected:**
- Correct PSEL[n] asserted for each address
- All slaves accessed successfully

**Coverage:**
- Address decode cross coverage (slave × txn_type)

---

#### TC004: Functional - Pipeline Configurations
**Objective:** Test all 4 pipeline parameter combinations  
**Stimulus:**
```
Config 1: PIPE_REQ=0, PIPE_RESP=0  (fall_through)
Config 2: PIPE_REQ=0, PIPE_RESP=1  (response pipelined)
Config 3: PIPE_REQ=1, PIPE_RESP=0  (request pipelined)
Config 4: PIPE_REQ=1, PIPE_RESP=1  (both pipelined)
```

**Expected:**
- All configs produce correct results
- Latency increases with pipelining
- No protocol violations

**Coverage:**
- Pipeline config cross coverage

---

#### TC005: Functional - DECERR Response
**Objective:** Verify decode error on invalid address  
**Stimulus:**
- Issue AW/AR to address not in any slave range

**Expected:**
- AXI-Lite response = RESP_DECERR (2'b11)
- No APB transaction initiated (all PSEL=0)

**Coverage:**
- Error response types
- Invalid address handling

---

#### TC006: Functional - SLVERR Response
**Objective:** Verify slave error propagation  
**Stimulus:**
- APB slave asserts PSLVERR=1

**Expected:**
- AXI-Lite response = RESP_SLVERR (2'b10)

**Coverage:**
- Error propagation

---

#### TC007: Random - Constrained Random Transactions
**Objective:** Broad functional coverage  
**Stimulus:**
- 10K random AXI-Lite transactions
- Constraints:
  - 70% valid addresses, 30% invalid
  - 50% read, 50% write
  - Random data patterns
  - Random APB delays (0-10 cycles)

**Expected:**
- Zero scoreboard mismatches
- Protocol compliance
- Coverage holes identified

**Coverage:**
- Cross coverage (address × type × pipeline)
- Data patterns
- Delay scenarios

---

#### TC008: Random - Back-to-Back Transactions
**Objective:** Verify high-throughput scenarios  
**Stimulus:**
- Consecutive AXI-Lite transactions with no gaps
- Both read and write
- Same and different slaves

**Expected:**
- All transactions complete successfully
- No protocol violations
- Correct pipelining behavior

**Coverage:**
- Outstanding transactions
- Channel interleavings

---

#### TC009: Stress - Maximum APB Delays
**Objective:** Stress test with slow APB slaves  
**Stimulus:**
- Configure APB slaves with max PREADY delays (100+ cycles)
- Issue multiple AXI-Lite requests

**Expected:**
- Bridge handles delays correctly
- No deadlocks
- Correct data integrity

**Coverage:**
- Long delay scenarios
- Backpressure handling

---

#### TC010: Stress - Address Boundaries
**Objective:** Test address decode boundaries  
**Stimulus:**
- Transactions to:
  - First address in each slave range
  - Last address in each slave range
  - Addresses just outside ranges (DECERR)

**Expected:**
- Correct slave selection
- Boundary addresses handled correctly

**Coverage:**
- Address boundary coverage

---

#### TC011: Corner Case - Reset During Transaction
**Objective:** Verify reset handling  
**Stimulus:**
- Assert reset during various APB states:
  - During SETUP phase
  - During ACCESS phase
  - During AXI response

**Expected:**
- Clean reset
- No lingering state
- Next transaction works correctly

**Coverage:**
- Reset timing scenarios

---

## 4. Coverage Plan

### 4.1 Functional Coverage

#### Covergroup: AXI-Lite Transactions
```systemverilog
covergroup axi_lite_txn_cg;
  // Transaction type
  cp_type: coverpoint txn_type {
    bins write = {WRITE};
    bins read  = {READ};
  }
  
  // Address ranges (per slave)
  cp_addr: coverpoint txn_addr {
    bins slave[NoApbSlaves] = {[0:$]};
    bins invalid = {[max+1:$]};
  }
  
  // Data patterns
  cp_data: coverpoint txn_data {
    bins zeros     = {32'h0000_0000};
    bins all_ones  = {32'hFFFF_FFFF};
    bins walking_1 = {32'h0000_0001, 32'h0000_0002, ..., 32'h8000_0000};
    bins random    = default;
  }
  
  // Strobe patterns
  cp_strb: coverpoint txn_strb {
    bins all_bytes = {4'b1111};
    bins byte_0    = {4'b0001};
    bins byte_1    = {4'b0010};
    bins byte_2    = {4'b0100};
    bins byte_3    = {4'b1000};
    bins half_low  = {4'b0011};
    bins half_high = {4'b1100};
  }
  
  // Response types
  cp_resp: coverpoint txn_resp {
    bins okay    = {RESP_OKAY};
    bins slverr  = {RESP_SLVERR};
    bins decerr  = {RESP_DECERR};
  }
  
  // Cross coverage
  cross_type_addr: cross cp_type, cp_addr;
  cross_type_resp: cross cp_type, cp_resp;
  cross_addr_strb: cross cp_addr, cp_strb;
endgroup
```

#### Covergroup: APB Protocol
```systemverilog
covergroup apb_protocol_cg;
  // APB state transitions
  cp_state: coverpoint apb_state {
    bins idle   = {IDLE};
    bins setup  = {SETUP};
    bins access = {ACCESS};
  }
  
  // PREADY delays
  cp_pready_delay: coverpoint pready_delay {
    bins immediate = {0};
    bins short     = {[1:5]};
    bins medium    = {[6:20]};
    bins long      = {[21:100]};
  }
  
  // Slave selection
  cp_psel: coverpoint psel_index {
    bins slaves[NoApbSlaves] = {[0:NoApbSlaves-1]};
  }
endgroup
```

#### Covergroup: Pipeline Configurations
```systemverilog
covergroup pipeline_config_cg;
  cp_pipe_req: coverpoint PIPE_REQ {
    bins disabled = {0};
    bins enabled  = {1};
  }
  
  cp_pipe_resp: coverpoint PIPE_RESP {
    bins disabled = {0};
    bins enabled  = {1};
  }
  
  cross_pipeline: cross cp_pipe_req, cp_pipe_resp;
  // Expect 4 bins: (0,0), (0,1), (1,0), (1,1)
endgroup
```

### 4.2 Code Coverage
- **Statement coverage:** >95%
- **Branch coverage:** >90%
- **Expression coverage:** >85%
- **FSM coverage:** 100% (all states/transitions)

### 4.3 Assertion Coverage
- **Protocol assertions:** 100% exercised
- **Error injection:** All error scenarios

---

## 5. Assertions / Checkers

### 5.1 AXI4-Lite Protocol Assertions
```systemverilog
// Write address valid-ready handshake
property axi_aw_handshake;
  @(posedge clk) disable iff (!rst_n)
  (aw_valid && !aw_ready) |=> $stable(aw_addr) && $stable(aw_valid);
endproperty

// Write data valid-ready handshake
property axi_w_handshake;
  @(posedge clk) disable iff (!rst_n)
  (w_valid && !w_ready) |=> $stable(w_data) && $stable(w_strb);
endproperty

// Read address valid-ready handshake
property axi_ar_handshake;
  @(posedge clk) disable iff (!rst_n)
  (ar_valid && !ar_ready) |=> $stable(ar_addr) && $stable(ar_valid);
endproperty
```

### 5.2 APB Protocol Assertions
```systemverilog
// PENABLE follows PSEL
property apb_penable_after_psel;
  @(posedge clk) disable iff (!rst_n)
  $rose(psel) && !penable |=> penable;
endproperty

// PSEL must be stable during PENABLE
property apb_psel_stable;
  @(posedge clk) disable iff (!rst_n)
  penable |=> $stable(psel) || $fell(psel);
endproperty

// Transfer completes when PENABLE and PREADY
property apb_transfer_complete;
  @(posedge clk) disable iff (!rst_n)
  (penable && pready) |=> !penable;
endproperty
```

### 5.3 Bridge-Specific Assertions
```systemverilog
// DECERR when address not in any slave range
property decerr_on_invalid_addr;
  @(posedge clk) disable iff (!rst_n)
  (axi_txn_start && addr_invalid) |-> 
    ##[1:$] (axi_resp_valid && (resp == RESP_DECERR));
endproperty

// APB transaction only for valid addresses
property no_apb_for_invalid_addr;
  @(posedge clk) disable iff (!rst_n)
  (axi_txn_start && addr_invalid) |-> 
    !psel throughout ##[0:$] axi_resp_valid;
endproperty
```

---

## 6. Scoreboard Strategy

### 6.1 Predictor Model
```
Input: AXI-Lite Transaction
  ├── Address decode
  ├── Determine target APB slave
  ├── Generate expected APB request
  └── Generate expected AXI-Lite response

Output: Expected Transactions Queue
```

### 6.2 Comparison Points
1. **APB Request:**
   - PADDR matches AXI AWADDR/ARADDR
   - PWRITE matches transaction type
   - PWDATA matches WDATA (for writes)
   - PSTRB matches WSTRB
   - PSEL[n] correct for address

2. **AXI Response:**
   - RDATA matches PRDATA (for reads)
   - RESP correct (OKAY, SLVERR, DECERR)
   - Response timing acceptable

### 6.3 Error Reporting
```systemverilog
if (actual !== expected) begin
  `uvm_error("SCOREBOARD_MISMATCH",
    $sformatf("Expected: %s, Actual: %s", 
              expected.sprint(), actual.sprint()))
end
```

---

## 7. Resource Requirements

### 7.1 Simulation Time Estimates
| Test | Transactions | Sim Time (VCS) |
|------|--------------|----------------|
| Sanity | ~10 | ~1 min |
| Functional | ~100 | ~5 min |
| Random (10K) | 10,000 | ~30 min |
| Stress | ~1,000 | ~15 min |
| **Total Regression** | ~11K | **~1 hour** |

### 7.2 Compute Resources
- Single test: 1 CPU core
- Parallel regression: 8-16 cores recommended
- Memory: ~2GB per simulation

---

## 8. Pass/Fail Criteria

### 8.1 Per-Test Criteria
✅ **PASS** if:
- Zero UVM errors/fatals
- Zero scoreboard mismatches
- All assertions passed
- Expected coverage hits achieved

❌ **FAIL** if:
- Any UVM error/fatal
- Scoreboard mismatch
- Assertion failure
- Timeout (simulation hang)

### 8.2 Regression Criteria
✅ **PASS** if:
- All P0 tests pass
- >90% of P1 tests pass
- Functional coverage >95%
- Code coverage >90%

---

## 9. Schedule

### Week-by-Week Breakdown

| Week | Tasks | Deliverables |
|------|-------|--------------|
| **1** | - Create directory structure<br>- Define interfaces<br>- Create base classes | - `tb/` structure<br>- Interface files<br>- Base UVM components |
| **2** | - Implement AXI-Lite agent<br>- Basic sequences | - Working AXI-Lite master |
| **3** | - Implement APB agent<br>- Memory model | - Working APB slave |
| **4** | - Environment integration<br>- Scoreboard | - Connected environment<br>- Basic checking |
| **5** | - Test development (TC001-TC008) | - P0 tests passing |
| **6** | - Coverage analysis<br>- Bug fixes<br>- Documentation | - Coverage closure<br>- Final report |

---

## 10. Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| VCS license unavailable | Low | High | Use known-working setup, coordinate with IT |
| DUT bugs found | Medium | Medium | Report to design, create workaround tests |
| Coverage holes | Medium | Low | Identify early, add directed tests |
| Schedule slip | Medium | Medium | Focus on P0 first, defer P2 if needed |

---

## 11. Sign-off Checklist

- [ ] All P0 tests passing
- [ ] Functional coverage >95%
- [ ] Code coverage >90%
- [ ] All assertions passing
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Regression automated
- [ ] Signoff meeting held

---

## Appendix A: Test Command Examples

```bash
# Run single test
make -f Makefile.uvm TEST=axi_lite_to_apb_sanity_test

# Run with seed
make -f Makefile.uvm TEST=axi_lite_to_apb_random_test SEED=12345

# Run with verbosity
make -f Makefile.uvm TEST=axi_lite_to_apb_random_test UVM_VERBOSITY=UVM_HIGH

# Run with GUI
make -f Makefile.uvm TEST=axi_lite_to_apb_sanity_test GUI=1

# Run full regression
./scripts/uvm_regression.sh
```

## Appendix B: Debug Checklist

When test fails:
1. Check UVM log for errors
2. Check scoreboard mismatches
3. Review waveforms (focus on error time)
4. Check assertion failures
5. Increase verbosity (`UVM_HIGH`)
6. Add debug messages in specific components
7. Create minimal reproducer

---

**Document Version:** 1.0  
**Status:** Planning  
**Next Review:** After Week 2 (Agent Implementation)

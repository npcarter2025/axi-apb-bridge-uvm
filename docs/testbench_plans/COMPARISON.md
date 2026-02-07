# Comparison: AXI2APB vs AXI-Lite to APB Bridges

You now have **TWO** different AXI to APB bridge designs in this directory:

## 1. AXI2APB Bridge (Original)
**Location:** `dut/`

### Design Files:
- `axi2apb.sv` - Main bridge (32-bit to 32-bit)
- `axi2apb_64_32.sv` - Data width converter (64-bit AXI to 32-bit APB)
- `axi2apb_wrap.sv` - Wrapper that selects appropriate bridge

### Characteristics:
- ✓ **Full AXI4 protocol** support
- ✓ Supports data width conversion
- ✓ Uses explicit signal-based interfaces (not structs)
- ✓ Has buffer modules instantiated: `axi_aw_buffer`, `axi_w_buffer`, etc.
- ✗ **Missing dependencies** - buffer modules not included
- ✗ Older design style
- Uses 5-state FSM for protocol conversion

### Status:
**⚠️ INCOMPLETE** - Requires external buffer modules that are not in this repository.

---

## 2. AXI-Lite to APB Bridge (New)
**Location:** `dut_axi_lite/`

### Design File:
- `axi_lite_to_apb.sv` - Complete standalone bridge

### Characteristics:
- ✓ **AXI4-Lite protocol** (simplified AXI)
- ✓ **Complete and self-contained** - all dependencies included
- ✓ Modern struct-based parameterized interfaces
- ✓ Better documentation
- ✓ Built-in arbitration (round-robin between read/write)
- ✓ Multiple APB slaves support with address decoder
- ✓ Optional request/response pipelining
- Uses common_cells library (all modules provided)

### Status:
**✅ READY TO USE** - All dependencies provided in `rtl/` and `pkg/` directories.

---

## Key Differences

| Feature | AXI2APB (dut/) | AXI-Lite to APB (dut_axi_lite/) |
|---------|----------------|----------------------------------|
| **Protocol** | Full AXI4 | AXI4-Lite |
| **Burst Support** | Yes | No (single transfers) |
| **Interface Style** | Explicit signals | Parameterized structs |
| **Dependencies** | ❌ Missing buffers | ✅ All included |
| **Width Conversion** | Yes (64→32) | No (same width) |
| **Multiple Slaves** | Single APB slave | Multiple APB slaves |
| **Address Decode** | Not built-in | Built-in with `addr_decode` |
| **Completeness** | Incomplete | Complete |
| **Documentation** | Basic | Comprehensive |
| **Recommended for UVM** | ❌ No | ✅ Yes |

---

## Which One Should You Use?

### For UVM Testbench Development: **AXI-Lite to APB** ✅

**Reasons:**
1. **Complete** - All dependencies are provided
2. **Modern** - Uses parameterized types, easier to integrate with UVM
3. **Well-documented** - Clear interface specifications
4. **Proven** - Has existing testbench for reference
5. **Flexible** - Supports multiple APB slaves

### When You Might Need AXI2APB:

- If you specifically need **full AXI4 protocol** (bursts, out-of-order)
- If you need **data width conversion** (64-bit to 32-bit)
- If you can obtain the missing buffer modules from PULP platform

---

## Recommendation

**Start with `axi_lite_to_apb.sv`** for your UVM testbench. It's:
- Ready to use immediately
- Better suited for learning UVM
- Has all necessary files
- More maintainable

If you later need full AXI4 features, you can:
1. Extend your UVM agents to support full AXI4
2. Obtain the missing buffer modules for `axi2apb`
3. Or use `axi_lite_to_apb` as a learning platform first

---

## File Organization

```
AXI_TO_APB_BRIDGE_UVM/
│
├── dut/                    # OLD: AXI2APB (incomplete)
│   ├── axi2apb.sv
│   ├── axi2apb_64_32.sv
│   └── axi2apb_wrap.sv
│
├── dut_axi_lite/          # NEW: AXI-Lite to APB (complete) ✅
│   └── axi_lite_to_apb.sv
│
├── pkg/                    # Packages for axi_lite_to_apb
├── include/                # Headers for axi_lite_to_apb
├── rtl/                    # Dependencies for axi_lite_to_apb
├── reference/              # Example testbench
│
├── README_AXI_LITE.md     # Main documentation
├── filelist_axi_lite.f    # Compilation filelist
└── COMPARISON.md          # This file
```

---

## Next Steps

1. **Read:** `README_AXI_LITE.md` for detailed information
2. **Study:** `reference/tb_axi_lite_to_apb.sv` to understand the DUT
3. **Build:** Your UVM testbench around `dut_axi_lite/axi_lite_to_apb.sv`
4. **Use:** `filelist_axi_lite.f` for compilation

Good luck with your UVM testbench development! 🚀

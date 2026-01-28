// ============================================================================
// Common Cells Dependencies
// ============================================================================
// AMD-style modular filelist
// Paths relative to project root (AXI_TO_APB_BRIDGE_UVM/)

// Include directories
+incdir+../../deps/common_cells/include
+incdir+../../deps/common_cells/include/common_cells

// ==========================================
// Level 1: Basic Common Cells
// ==========================================
../../deps/common_cells/src/cf_math_pkg.sv
../../deps/common_cells/src/lzc.sv
../../deps/common_cells/src/rr_arb_tree.sv
../../deps/common_cells/src/onehot_to_bin.sv
../../deps/common_cells/src/lfsr_8bit.sv
../../deps/common_cells/src/lfsr.sv

// ==========================================
// Level 2: Register/FIFO Primitives
// ==========================================
../../deps/common_cells/src/spill_register.sv
../../deps/common_cells/src/fall_through_register.sv
../../deps/common_cells/src/stream_register.sv
../../deps/common_cells/src/stream_fifo.sv
../../deps/common_cells/src/fifo_v3.sv

// ==========================================
// Level 3: Advanced Common Cells
// ==========================================
../../deps/common_cells/src/stream_arbiter_flushable.sv
../../deps/common_cells/src/stream_arbiter.sv
../../deps/common_cells/src/addr_decode_dync.sv
../../deps/common_cells/src/addr_decode.sv

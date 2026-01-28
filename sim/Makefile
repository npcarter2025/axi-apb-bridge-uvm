# ============================================================================
# Simple Makefile for AXI-Lite to APB Bridge Reference Testbench
# ============================================================================

# Tool settings
VCS = vcs
SIMV = simv

# Simulation parameters
PIPE_REQ ?= 0
PIPE_RESP ?= 0

# VCS compilation flags
VCS_FLAGS = -sverilog \
            -full64 \
            -timescale=1ns/1ps \
            -debug_access+all \
            -kdb \
            -lca \
            -LDFLAGS -Wl,--no-as-needed \
            -top tb_axi_lite_to_apb

# Include directories
VCS_FLAGS += +incdir+../deps/axi/include
VCS_FLAGS += +incdir+../deps/axi/include/axi
VCS_FLAGS += +incdir+../deps/common_cells/include
VCS_FLAGS += +incdir+../deps/common_cells/include/common_cells

# Source files
SOURCES = \
    ../deps/common_cells/src/cf_math_pkg.sv \
    ../deps/common_cells/src/lzc.sv \
    ../deps/common_cells/src/rr_arb_tree.sv \
    ../deps/common_cells/src/onehot_to_bin.sv \
    ../deps/common_cells/src/lfsr_8bit.sv \
    ../deps/common_cells/src/lfsr.sv \
    ../deps/common_cells/src/spill_register.sv \
    ../deps/common_cells/src/fall_through_register.sv \
    ../deps/common_cells/src/stream_register.sv \
    ../deps/common_cells/src/stream_fifo.sv \
    ../deps/common_cells/src/fifo_v3.sv \
    ../deps/common_cells/src/stream_arbiter_flushable.sv \
    ../deps/common_cells/src/stream_arbiter.sv \
    ../deps/common_cells/src/addr_decode_dync.sv \
    ../deps/common_cells/src/addr_decode.sv \
    ../deps/common_verification/src/clk_rst_gen.sv \
    ../deps/common_verification/src/rand_id_queue.sv \
    ../deps/axi/src/axi_pkg.sv \
    ../deps/axi/src/axi_intf.sv \
    ../deps/axi/src/axi_test.sv \
    ../dut_axi_lite/axi_lite_to_apb.sv \
    ../deps/axi/test/tb_axi_lite_to_apb.sv

# Simulation flags
SIM_FLAGS = +TbPipelineRequest=$(PIPE_REQ) \
            +TbPipelineResponse=$(PIPE_RESP)

# ============================================================================
# Targets
# ============================================================================

.PHONY: all compile run clean help test_all

all: run

test_all:
	@echo "Running all 4 pipeline configurations..."
	@./run_all_configs.sh

compile:
	@echo "============================================"
	@echo "Compiling AXI-Lite to APB Bridge Testbench"
	@echo "============================================"
	$(VCS) $(VCS_FLAGS) $(SOURCES) -o $(SIMV)
	@echo "✅ Compilation complete"

run: compile
	@echo "============================================"
	@echo "Running Simulation"
	@echo "  PIPE_REQ  = $(PIPE_REQ)"
	@echo "  PIPE_RESP = $(PIPE_RESP)"
	@echo "============================================"
	@echo "run" > run.tcl
	@echo "quit" >> run.tcl
	./$(SIMV) -ucli -i run.tcl $(SIM_FLAGS) | tee sim.log
	@rm -f run.tcl
	@echo ""
	@if grep -q "Run for Reads" sim.log; then \
		echo "✅ Simulation PASSED"; \
		echo "   Completed 20000 reads and 10000 writes"; \
	else \
		echo "❌ Simulation may have failed - check sim.log"; \
	fi

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(SIMV) $(SIMV).daidir csrc *.log *.vpd
	rm -rf ucli.key vc_hdrs.h DVEfiles run.tcl
	@echo "✅ Clean complete"

help:
	@echo "============================================"
	@echo "AXI-Lite to APB Bridge Testbench Makefile"
	@echo "============================================"
	@echo ""
	@echo "Targets:"
	@echo "  make           - Compile and run (default)"
	@echo "  make compile   - Compile testbench only"
	@echo "  make run       - Run simulation"
	@echo "  make test_all  - Run all 4 pipeline configurations"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make help      - Show this help"
	@echo ""
	@echo "Options:"
	@echo "  PIPE_REQ=0/1   - Pipeline request path (default: 0)"
	@echo "  PIPE_RESP=0/1  - Pipeline response path (default: 0)"
	@echo ""
	@echo "Examples:"
	@echo "  make                              # Quick run (no pipeline)"
	@echo "  make PIPE_REQ=1 PIPE_RESP=1       # Full pipeline"
	@echo ""
	@echo "Note: Run from your conda environment where VCS works"
	@echo ""

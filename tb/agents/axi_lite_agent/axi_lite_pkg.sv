// ============================================
// AXI4-Lite Agent Package
// ============================================
// This package contains all components for the AXI4-Lite UVM agent.
// To reconfigure bus widths, change the parameters below.

package axi_lite_pkg;

    // ============================================
    // IMPORTS
    // ============================================
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // ============================================
    // PACKAGE-LEVEL PARAMETERS
    // ============================================
    // Change these to reconfigure the entire agent
    // All classes will automatically use these widths
    parameter int AXI_ADDR_WIDTH = 32;
    parameter int AXI_DATA_WIDTH = 32;
    parameter int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    // ============================================
    // INCLUDES (Order matters!)
    // ============================================
    // 1. Transaction (no dependencies)
    `include "axi_lite_transaction.svh"
    
    // 2. Configuration (no dependencies)
    `include "axi_lite_config.svh"
    
    // 3. Coverage (depends on transaction)
    `include "axi_lite_coverage.svh"
    
    // 4. Sequencer (depends on transaction)
    `include "axi_lite_sequencer.svh"
    
    // 5. Driver (depends on transaction, config)
    `include "axi_lite_driver.svh"
    
    // 6. Monitor (depends on transaction, config)
    `include "axi_lite_monitor.svh"
    
    // 7. Agent (depends on all above)
    `include "axi_lite_agent.svh"
    
    // 8. Sequences (depend on transaction, sequencer)
    `include "sequences/axi_lite_base_seq.svh"
    `include "sequences/axi_lite_write_seq.svh"
    `include "sequences/axi_lite_read_seq.svh"
    `include "sequences/axi_lite_random_seq.svh"
    `include "sequences/axi_lite_directed_seq.svh"

endpackage : axi_lite_pkg

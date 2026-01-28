// ============================================
// APB4 Agent Package
// ============================================
// This package contains all components for the APB4 UVM agent.
// To reconfigure bus widths, change the parameters below.

package apb_pkg;

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
    parameter int APB_ADDR_WIDTH = 32;
    parameter int APB_DATA_WIDTH = 32;
    parameter int APB_STRB_WIDTH = APB_DATA_WIDTH / 8;

    // ============================================
    // INCLUDES (Order matters!)
    // ============================================
    // 1. Transaction (no dependencies)
    `include "apb_transaction.svh"
    
    // 2. Configuration (no dependencies)
    `include "apb_config.svh"
    
    // 3. Coverage (depends on transaction)
    `include "apb_coverage.svh"
    
    // 4. Sequencer (depends on transaction)
    `include "apb_sequencer.svh"
    
    // 5. Driver (depends on transaction, config)
    `include "apb_driver.svh"
    
    // 6. Monitor (depends on transaction, config)
    `include "apb_monitor.svh"
    
    // 7. Agent (depends on all above)
    `include "apb_agent.svh"
    
    // 8. Sequences (depend on transaction, sequencer)
    `include "sequences/apb_error_seq.sv"
    `include "sequences/apb_master_seq.sv"
    `include "sequences/apb_slave_seq.sv"


endpackage : apb_pkg

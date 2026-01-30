// ============================================
// AXI-Lite to APB Environment Package
// ============================================
// Top-level environment package that brings together
// the AXI-Lite and APB agents

package axi_lite_to_apb_env_pkg;

    // ============================================
    // Imports
    // ============================================
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import agent packages
    import axi_lite_pkg::*;
    import apb_pkg::*;

    // ============================================
    // Environment Components
    // ============================================
    // For now, just the basic environment
    // TODO: Add scoreboard, predictor, etc. later
    
    `include "axi_lite_to_apb_env.sv"

endpackage : axi_lite_to_apb_env_pkg

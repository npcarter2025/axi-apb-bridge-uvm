// ============================================
// Top-Level Testbench Package
// ============================================
// This package imports all verification components
// and makes them available to the testbench top module

package tb_pkg;

    // ============================================
    // Import UVM
    // ============================================
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // ============================================
    // Import Agent Packages
    // ============================================
    import axi_lite_pkg::*;
    import apb_pkg::*;

    // ============================================
    // Import Environment Package
    // ============================================
    import axi_lite_to_apb_env_pkg::*;

    // ============================================
    // Include Common Utilities (if any)
    // ============================================
    // `include "tb_utils.sv"  // TODO: Add if needed
    // `include "tb_params.sv" // TODO: Add if needed

    // ============================================
    // Include Test Classes
    // ============================================
    // Tests are included here to make them available
    // to the testbench top via +UVM_TESTNAME
    
    `include "../tests/axi_lite_to_apb_tests/axi_lite_to_apb_base_test.sv"
    `include "../tests/axi_lite_to_apb_tests/axi_lite_to_apb_sanity_test.sv"
    `include "../tests/axi_lite_to_apb_tests/axi_lite_to_apb_random_test.sv"

endpackage : tb_pkg

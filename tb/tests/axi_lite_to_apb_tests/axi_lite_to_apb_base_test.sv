// ============================================
// AXI-Lite to APB Base Test
// ============================================
// Base test class that all other tests extend from
// Sets up the environment and provides common functionality

class axi_lite_to_apb_base_test extends uvm_test;
    `uvm_component_utils(axi_lite_to_apb_base_test)

    // ============================================
    // Environment
    // ============================================
    axi_lite_to_apb_env env;

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "axi_lite_to_apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ============================================
    // Build Phase
    // ============================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create environment
        env = axi_lite_to_apb_env::type_id::create("env", this);

        `uvm_info(get_type_name(), "Base test build phase complete", UVM_LOW)
    endfunction

    // ============================================
    // End of Elaboration Phase
    // ============================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print topology
        `uvm_info(get_type_name(), "\n=== Test Configuration ===", UVM_LOW)
        uvm_top.print_topology();
        `uvm_info(get_type_name(), "=========================\n", UVM_LOW)
    endfunction

    // ============================================
    // Run Phase
    // ============================================
    // Child tests override this to start sequences
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        `uvm_info(get_type_name(), "Base test run phase (does nothing)", UVM_LOW)
        
        // Base test doesn't run any sequences
        // Child tests will override this
    endtask

endclass

// ============================================
// AXI-Lite to APB Sanity Test
// ============================================
// Simple sanity test to verify basic functionality
// Runs a directed sequence with known values

class axi_lite_to_apb_sanity_test extends axi_lite_to_apb_base_test;
    `uvm_component_utils(axi_lite_to_apb_sanity_test)

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "axi_lite_to_apb_sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ============================================
    // Run Phase
    // ============================================
    task run_phase(uvm_phase phase);
        axi_lite_directed_seq axi_seq;
        apb_slave_seq apb_seq;

        phase.raise_objection(this, "Starting sanity test");

        `uvm_info(get_type_name(), "\n*** STARTING SANITY TEST ***", UVM_LOW)

        // TEMPORARY: Skip APB sequence for now to isolate the issue
        // TODO: Fix APB reactive sequence startup
        
        `uvm_info(get_type_name(), "Waiting 50us for reset...", UVM_LOW)
        #50us;
        `uvm_info(get_type_name(), "After 50us wait", UVM_LOW)
        
        // Run AXI-Lite directed sequence (finite)
        `uvm_info(get_type_name(), "Starting AXI-Lite directed sequence", UVM_LOW)
        axi_seq = axi_lite_directed_seq::type_id::create("axi_seq");
        axi_seq.start(env.axi_lite_agt.sequencer);

        // Wait for transactions to complete
        #1us;

        `uvm_info(get_type_name(), "\n*** SANITY TEST COMPLETE ***", UVM_LOW)

        phase.drop_objection(this, "Sanity test finished");
    endtask

endclass

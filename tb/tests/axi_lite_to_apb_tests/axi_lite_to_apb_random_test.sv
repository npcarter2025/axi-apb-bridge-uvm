// ============================================
// AXI-Lite to APB Random Test
// ============================================
// Random test with multiple read/write transactions

class axi_lite_to_apb_random_test extends axi_lite_to_apb_base_test;
    `uvm_component_utils(axi_lite_to_apb_random_test)

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "axi_lite_to_apb_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ============================================
    // Run Phase
    // ============================================
    task run_phase(uvm_phase phase);
        axi_lite_random_seq axi_seq;
        apb_slave_seq apb_seq;

        phase.raise_objection(this, "Starting random test");

        `uvm_info(get_type_name(), "\n*** STARTING RANDOM TEST ***", UVM_LOW)

        // Start APB slave sequence in background
        fork
            begin
                apb_seq = apb_slave_seq::type_id::create("apb_seq");
                apb_seq.start(env.apb_agt.sequencer);
            end
        join_none

        // Give APB sequence time to start
        #100ns;

        // Run AXI-Lite random sequence
        axi_seq = axi_lite_random_seq::type_id::create("axi_seq");
        
        // Configure sequence
        assert(axi_seq.randomize() with {
            num_transactions == 20;
            start_addr == 32'h00000000;
            end_addr == 32'h00001000;
        });
        
        axi_seq.start(env.axi_lite_agt.sequencer);

        // Wait for transactions to complete
        #2us;

        `uvm_info(get_type_name(), "\n*** RANDOM TEST COMPLETE ***", UVM_LOW)

        phase.drop_objection(this, "Random test finished");
    endtask

endclass

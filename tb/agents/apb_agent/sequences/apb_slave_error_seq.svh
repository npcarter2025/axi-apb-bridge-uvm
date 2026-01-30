`ifndef APB_SLAVE_ERROR_SEQ_SVH
`define APB_SLAVE_ERROR_SEQ_SVH

// ============================================
// APB Slave Error Injection Sequence
// ============================================
// Variant of apb_slave_seq with higher error injection rate
// Use this sequence to test error handling in the DUT and
// verify that SLVERR is properly propagated to AXI-Lite

class apb_slave_error_seq extends apb_slave_base_seq;
    `uvm_object_utils(apb_slave_error_seq)

    // ============================================
    // Configuration - Higher Error Rate
    // ============================================
    constraint error_rate_high_c {
        error_rate inside {[20:50]};  // 20-50% error rate
    }

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "apb_slave_error_seq");
        super.new(name);
    endfunction

    // ============================================
    // Body Task - Same as Normal Slave, Just Higher Errors
    // ============================================
    task body();
        apb_transaction txn;
        int unsigned delay;
        bit inject_err;

        `uvm_info(get_type_name(), 
                  $sformatf("APB Slave ERROR Sequence started - error_rate=%0d%%",
                            error_rate),
                  UVM_LOW)

        forever begin
            // Create transaction
            txn = apb_transaction::type_id::create("txn");
            
            // Get response behavior
            delay = get_random_delay();
            inject_err = should_inject_error();
            
            // Start item
            start_item(txn);
            
            // Configure response
            txn.response_delay = delay;
            txn.pslverr = inject_err;
            
            // Handle transaction
            if (txn.pwrite) begin
                if (!inject_err) begin
                    write_mem(txn.paddr, txn.pwdata, txn.pstrb);
                    `uvm_info(get_type_name(),
                              $sformatf("WRITE: addr=0x%08h data=0x%08h",
                                        txn.paddr, txn.pwdata),
                              UVM_HIGH)
                end else begin
                    `uvm_warning(get_type_name(),
                                 $sformatf("WRITE ERROR INJECTED: addr=0x%08h", 
                                           txn.paddr))
                end
            end else begin
                if (!inject_err) begin
                    txn.prdata = read_mem(txn.paddr);
                    `uvm_info(get_type_name(),
                              $sformatf("READ: addr=0x%08h data=0x%08h",
                                        txn.paddr, txn.prdata),
                              UVM_HIGH)
                end else begin
                    txn.prdata = 32'hBADBAD00;  // Error pattern
                    `uvm_warning(get_type_name(),
                                 $sformatf("READ ERROR INJECTED: addr=0x%08h", 
                                           txn.paddr))
                end
            end
            
            // Finish item
            finish_item(txn);
            
        end // forever
    endtask

endclass

`endif

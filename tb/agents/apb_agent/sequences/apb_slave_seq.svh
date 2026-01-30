`ifndef APB_SLAVE_SEQ_SVH
`define APB_SLAVE_SEQ_SVH

// ============================================
// APB Slave Sequence
// ============================================
// Main reactive APB slave sequence that:
// - Runs forever responding to DUT requests
// - Applies configurable delays
// - Maintains a simple memory model
// - Optionally injects errors based on error_rate

class apb_slave_seq extends apb_slave_base_seq;
    `uvm_object_utils(apb_slave_seq)

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "apb_slave_seq");
        super.new(name);
    endfunction

    // ============================================
    // Body Task - Provides Response Transactions
    // ============================================
    // This sequence runs forever, providing response transactions
    // to the driver whenever the DUT makes an APB request
    
    task body();
        apb_transaction txn;
        int unsigned delay;
        bit inject_err;

        `uvm_info(get_type_name(), 
                  "APB Slave Sequence started - providing responses",
                  UVM_LOW)

        forever begin
            // Create a new transaction
            txn = apb_transaction::type_id::create("txn");
            
            // Randomize response behavior
            delay = get_random_delay();
            inject_err = should_inject_error();
            
            // Start item (blocks until driver is ready for a transaction)
            start_item(txn);
            
            // The driver will have filled in the request fields (paddr, pwrite, etc.)
            // Now we configure the response
            txn.response_delay = delay;
            txn.pslverr = inject_err;
            
            // Handle memory operations
            if (txn.pwrite) begin
                // Write transaction
                if (!inject_err) begin
                    write_mem(txn.paddr, txn.pwdata, txn.pstrb);
                    `uvm_info(get_type_name(),
                              $sformatf("WRITE: addr=0x%08h data=0x%08h strb=0x%h delay=%0d",
                                        txn.paddr, txn.pwdata, txn.pstrb, delay),
                              UVM_HIGH)
                end else begin
                    `uvm_info(get_type_name(),
                              $sformatf("WRITE ERROR: addr=0x%08h (injected)", txn.paddr),
                              UVM_MEDIUM)
                end
            end else begin
                // Read transaction
                if (!inject_err) begin
                    txn.prdata = read_mem(txn.paddr);
                    `uvm_info(get_type_name(),
                              $sformatf("READ: addr=0x%08h data=0x%08h delay=%0d",
                                        txn.paddr, txn.prdata, delay),
                              UVM_HIGH)
                end else begin
                    txn.prdata = 32'hDEAD_BEEF;  // Error pattern
                    `uvm_info(get_type_name(),
                              $sformatf("READ ERROR: addr=0x%08h (injected)", txn.paddr),
                              UVM_MEDIUM)
                end
            end
            
            // Finish item (sends transaction to driver)
            finish_item(txn);
            
        end // forever
    endtask

endclass

`endif

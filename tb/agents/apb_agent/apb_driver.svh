`ifndef APB_DRIVER_SVH
`define APB_DRIVER_SVH

class apb_driver extends uvm_driver#(apb_transaction);

    `uvm_component_utils(apb_driver)

    virtual apb_if.slave vif;
    virtual apb_if vif_tmp;

    apb_config cfg;

    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif_tmp))
            `uvm_fatal(get_type_name(), "Virtual interface couldn't be found in config_db")
        vif = vif_tmp;
        
        if(!uvm_config_db#(apb_config)::get(this, "", "config", cfg))
            `uvm_fatal(get_type_name(), "apb Config object not found in config_db")

    endfunction


    task run_phase(uvm_phase phase);
        vif.wait_reset_done();
        vif.reset_slave_signals();

        forever begin
            // Wait for a transfer from DUT
            wait_for_setup_phase();
            
            // Process the transfer with sequence interaction
            drive_slave_response();
        end
    endtask

    // Wait for APB SETUP phase (psel=1, penable=0)
    task wait_for_setup_phase();
        @(vif.slave_cb);
        wait(vif.slave_cb.psel && !vif.slave_cb.penable);
    endtask

    // Drive slave response (interacts with sequence)
    task drive_slave_response();
        apb_transaction txn;
        
        // Get transaction from sequence (blocks until sequence provides one)
        // The sequence will be waiting in start_item()
        seq_item_port.get_next_item(txn);
        
        // Fill in request information from interface (SETUP phase)
        txn.paddr = vif.slave_cb.paddr;
        txn.pprot = vif.slave_cb.pprot;
        txn.pwrite = vif.slave_cb.pwrite;
        txn.access_type = vif.slave_cb.pwrite ? apb_transaction::WRITE : apb_transaction::READ;
        
        if (vif.slave_cb.pwrite) begin
            txn.pwdata = vif.slave_cb.pwdata;
            txn.pstrb = vif.slave_cb.pstrb;
        end
        
        `uvm_info(get_type_name(),
                  $sformatf("Got request: %s addr=0x%08h", 
                            txn.pwrite ? "WRITE" : "READ", txn.paddr),
                  UVM_HIGH)
        
        // Move to ACCESS phase
        @(vif.slave_cb);
        
        // Verify we're in ACCESS phase
        if (!(vif.slave_cb.psel && vif.slave_cb.penable)) begin
            `uvm_error(get_type_name(), "Expected ACCESS phase (psel && penable)")
            seq_item_port.item_done();
            return;
        end
        
        // At this point, the sequence has configured the response
        // (response_delay, pslverr, prdata for reads)
        
        // Apply response delay
        if (txn.response_delay > 0) begin
            repeat(txn.response_delay) @(vif.slave_cb);
        end
        
        // Drive response signals
        vif.slave_cb.pready <= 1'b1;
        vif.slave_cb.pslverr <= txn.pslverr;
        
        if (!txn.pwrite) begin
            vif.slave_cb.prdata <= txn.prdata;
        end
        
        `uvm_info(get_type_name(),
                  $sformatf("Responding: %s addr=0x%08h delay=%0d err=%0b%s",
                            txn.pwrite ? "WRITE" : "READ",
                            txn.paddr, txn.response_delay, txn.pslverr,
                            txn.pwrite ? "" : $sformatf(" data=0x%08h", txn.prdata)),
                  UVM_MEDIUM)
        
        // Wait one cycle with pready high (transaction completes)
        @(vif.slave_cb);
        
        // Deassert pready
        vif.slave_cb.pready <= 1'b0;
        
        // Signal item done to sequencer
        // This will unblock finish_item() in the sequence
        seq_item_port.item_done();
        
    endtask


endclass

`endif


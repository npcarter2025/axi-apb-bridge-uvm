`ifndef APB_MONITOR_SVH
`define APB_MONITOR_SVH

class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor);

    virtual apb_if.monitor_cb vif;

    apb_config cfg;

    uvm_analysis_port#(apb_transaction) ap;

    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Couldn't find virtual interface in config_db")
        
        if (!uvm_config_db#(apb_config)::get(this, "", "config", cfg))
            `uvm_fatal(get_type_name(), "Couldn't find apb_config in config_db")

        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        vif.wait_reset_done();

        forever begin
            collect_transactions();

        end

    endtask

    task collect_transactions();
        collect_transaction();

    endtask

    task collect_transaction();
        apb_transaction tr;

        
        // TODO: Wait for SETUP phase (psel && !penable)
        // TODO: Capture paddr, pprot, pwrite
        // TODO: If write, capture pwdata, pstrb
        
        // TODO: Wait for ACCESS phase (psel && penable && pready)
        // TODO: If read, capture prdata
        // TODO: Capture pslverr
        
        // TODO: Create transaction object and fill fields
        // TODO: Send transaction via analysis port: ap.write(tr)
        // TODO: Log transaction
        
        @(vif.monitor_cb);
    endtask        


endclass

`endif 

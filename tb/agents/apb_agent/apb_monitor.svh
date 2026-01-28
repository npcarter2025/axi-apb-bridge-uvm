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
        while (!(vif.monitor_cb.psel && !vif.monitor_cb.penable))
            @(vif.monitor_cb);

        tr = apb_transaction::type_id::create("tr");

        tr.paddr = vif.monitor_cb.paddr;
        tr.pprot = vif.monitor_cb.pprot;
        tr.access_type = vif.monitor_cb.pwrite ? WRITE : READ;

        if (tr.is_write()) begin 
            tr.pwdata = vif.monitor_cb.pwdata;
            tr.pstrb = vif.monitor_cb.pstrb;
        end

        @(vif.monitor_cb);
        while(!(vif.monitor_cb.psel && vif.monitor_cb.penable && vif.monitor_cb.pready))
            @(vif.monitor_cb);

        if (tr.is_read())
            tr.prdata = vif.monitor_cb.prdata;
        
        tr.pslverr = vif.monitor_cb.pslverr;

        ap.write(tr);

        `uvm_info(get_type_name(), $sformatf("APB Transaction: %s", tr.convert2string()), UVM_MEDIUM)
        

    endtask        


endclass

`endif 

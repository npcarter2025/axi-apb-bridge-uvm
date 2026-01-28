`ifndef AXI_LITE_MONITOR_SVH
`define AXI_LITE_MONITOR_SVH

class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)

    virtual axi_lite_if.monitor vif;

    axi_lite_config cfg;

    uvm_analysis_port#(axi_lite_transaction) ap;

    function new(string name = "axi_lite_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Couldn't retrieve virtual interface from config_db")

        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", cgf))
            `uvm_fatal(get_type_name(), "Couldn't find axi_lite_config in config_db")

        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        vif.wait_reset_done();
        

        forever begin
            collect_transactions();
        end
    endtask

    task collect_transactions();
        fork
            collect_write_transaction();
            collect_read_transaction();
        join_any
    endtask

    task collect_write_transaction();
        axi_lite_transaction tr;

        // TODO: Wait for write address handshake (awvalid && awready)
        // TODO: Capture awaddr, awprot
        
        // TODO: Wait for write data handshake (wvalid && wready)
        // TODO: Capture wdata, wstrb
        
        // TODO: Wait for write response (bvalid && bready)
        // TODO: Capture bresp
        
        // TODO: Create transaction object and fill fields
        // TODO: Send transaction via analysis port: ap.write(tr)
        // TODO: Log transaction
        
    endtask

    // ============================================
    // COLLECT READ TRANSACTION
    // ============================================
    task collect_read_transaction();
        axi_lite_transaction tr;
        
        // TODO: Wait for read address handshake (arvalid && arready)
        // TODO: Capture araddr, arprot
        
        // TODO: Wait for read data (rvalid && rready)
        // TODO: Capture rdata, rresp
        
        // TODO: Create transaction object and fill fields
        // TODO: Send transaction via analysis port: ap.write(tr)
        // TODO: Log transaction
        
    endtask





endclass

`endif

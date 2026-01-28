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

        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", cfg))
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
        join_none
    endtask

    task collect_write_transaction();
        axi_lite_transaction tr;

        bit [AXI_ADDR_WIDTH-1:0] addr;
        bit [2:0] prot;
        bit [AXI_DATA_WIDTH-1:0] wdata;
        bit [AXI_STRB_WIDTH-1:0] wstrb;
        bit [1:0] bresp;

        @(vif.monitor_cb);
        while (!(vif.monitor_cb.awvalid && vif.monitor_cb.awready))
            @(vif.monitor_cb);
        // TODO: Wait for write address handshake (awvalid && awready)
        // TODO: Capture awaddr, awprot
        
        addr = vif.monitor_cb.awaddr;
        prot = vif.monitor_cb.awprot;

        `uvm_info(get_type_name(), 
                  $sformatf("Observed AW: addr=0x%0h, prot=0x%0h", addr, prot), 
                  UVM_HIGH)
        
        // STEP 2: Wait for and capture Write Data handshake
        @(vif.monitor_cb);
        while (!(vif.monitor_cb.wvalid && vif.monitor_cb.wready))
            @(vif.monitor_cb);
        
        // Capture data phase
        wdata = vif.monitor_cb.wdata;
        wstrb = vif.monitor_cb.wstrb;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Observed W: wdata=0x%0h, wstrb=0x%0h", wdata, wstrb), 
                  UVM_HIGH)
        
        // STEP 3: Wait for and capture Write Response
        @(vif.monitor_cb);
        while (!(vif.monitor_cb.bvalid && vif.monitor_cb.bready))
            @(vif.monitor_cb);
        
        // Capture response
        bresp = vif.monitor_cb.bresp;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Observed B: bresp=%0d", bresp), 
                  UVM_HIGH)
        
        // STEP 4: Create transaction and fill all fields
        tr = axi_lite_transaction::type_id::create("tr");
        tr.access_type = WRITE;
        tr.addr = addr;
        tr.prot = prot;
        tr.wdata = wdata;
        tr.wstrb = wstrb;
        tr.bresp = bresp;
        
        // STEP 5: Send to analysis port (scoreboard will receive)
        ap.write(tr);
        
        // STEP 6: Log complete transaction
        `uvm_info(get_type_name(), 
                  $sformatf("WRITE Transaction Collected: %s", tr.convert2string()), 
                  UVM_MEDIUM)


        // TODO: Wait for write data handshake (wvalid && wready)
        // TODO: Capture wdata, wstrb
        
        // TODO: Wait for write response (bvalid && bready)
        // TODO: Capture bresp
        
        // TODO: Create transaction object and fill fields
        // TODO: Send transaction via analysis port: ap.write(tr)
        // TODO: Log transaction

        // tr = axi_lite_transaction::type_id::create("tr");

        // tr.addr = vif.monitor_cb.awaddr;
        // tr.wdata = vif.monitor_cb.wdata;

        // ap.write(tr);
        
        // `uvm_info(get_type_name(), $sformatf("Observed: %s", tr.convert2string()), UVM_MEDIUM)


    endtask

    // ============================================
    // COLLECT READ TRANSACTION
    // ============================================
    task collect_read_transaction();
        axi_lite_transaction tr;
        bit [AXI_ADDR_WIDTH-1:0] addr;
        bit [2:0] prot;
        bit [AXI_DATA_WIDTH-1:0] rdata;
        bit [1:0] rresp;
        
        // STEP 1: Wait for and capture Read Address handshake
        @(vif.monitor_cb);
        while (!(vif.monitor_cb.arvalid && vif.monitor_cb.arready))
            @(vif.monitor_cb);
        
        // Capture address phase
        addr = vif.monitor_cb.araddr;
        prot = vif.monitor_cb.arprot;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Observed AR: addr=0x%0h, prot=0x%0h", addr, prot), 
                  UVM_HIGH)
        
        // STEP 2: Wait for and capture Read Data/Response
        @(vif.monitor_cb);
        while (!(vif.monitor_cb.rvalid && vif.monitor_cb.rready))
            @(vif.monitor_cb);
        
        // Capture data and response
        rdata = vif.monitor_cb.rdata;
        rresp = vif.monitor_cb.rresp;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Observed R: rdata=0x%0h, rresp=%0d", rdata, rresp), 
                  UVM_HIGH)
        
        // STEP 3: Create transaction and fill all fields
        tr = axi_lite_transaction::type_id::create("tr");
        tr.access_type = READ;
        tr.addr = addr;
        tr.prot = prot;
        tr.rdata = rdata;
        tr.rresp = rresp;
        
        // STEP 4: Send to analysis port
        ap.write(tr);
        
        // STEP 5: Log complete transaction
        `uvm_info(get_type_name(), 
                  $sformatf("READ Transaction Collected: %s", tr.convert2string()), 
                  UVM_MEDIUM)
        
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

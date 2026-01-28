`ifndef AXI_LITE_DRIVER_SVH
`define AXI_LITE_DRIVER_SVH

class axi_lite_driver extends uvm_driver#(axi_lite_transaction);
    `uvm_component_utils(axi_lite_driver)

    virtual axi_lite_if.master vif;

    axi_lite_config cfg;

    function new(string name = "axi_lite_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual Interface not found in config_db")

        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", cfg))
            `uvm_fatal(get_type_name(), "Config object not found in config_db")

    endfunction


    task run_phase(uvm_phase phase);
        vif.wait_reset_done();

        vif.reset_master_signals();

        forever begin

            seq_item_port.get_next_item(req);

            drive_transaction(req);

            seq_item_port.item_done();

        end
    endtask

    task drive_transaction(axi_lite_transaction tr);
        if(tr.is_write())
            drive_write(tr);
        else
            drive_read(tr);
    endtask


    task drive_write(axi_lite_transaction tr);
        // STEP 1: Write Address Channel
        repeat(cfg.default_ready_delay) @(vif.master_cb);

        vif.master_cb.awaddr    <= tr.addr;
        vif.master_cb.awprot    <= tr.prot;
        vif.master_cb.awvalid   <= 1'b1;


        @(vif.master_cb);
        while (!vif.master_cb.awready)
            @(vif.master_cb);
        
        vif.master_cb.awvalid <= 1'b0;

        // step2: Write Data Channel
        vif.master_cb.wdata <= tr.wdata;
        vif.master_cb.wstrb <= tr.wstrb;
        vif.master_cb.wvalid <= 1'b1;

        @(vif.master_cb);
        while (!vif.master_cb.wready)
            @(vif.master_cb);
        
        vif.master_cb.wvalid <= 1'b0;

        // Step 3: Write Response Channel
        vif.master_cb.bready <= 1'b1;

        @(vif.master_cb);
        while (!vif.master_cb.bvalid)
            @(vif.master_cb)
        
        tr.bresp = vif.master_cb.bresp;

        vif.master_cb.bready <= 1'b0;
        `uvm_info(get_type_name(), $sformatf("Wrote: %s", tr.convert2string()), UVM_MEDIUM)

    endtask

    task drive_read(axi_lite_transaction tr);

        // STEP 1: Drive Read Address Channel

        repeat(cfg.default_ready_delay) @(vif.master_cb)
        
        vif.master_cb.araddr <= tr.addr;
        vif.master_cb.arprot <= tr.prot;
        vif.master_cb.arvalid <= 1'b1;

        @(vif.master_cb);
        while (!vif.master_cb.arready)
            @(vif.master_cb)

        vif.master_cb.ar_valid <= 1'b0;

        //Step 2: Wait for Read Data Response
        vif.master_cb.rready <= 1'b1;

        @(vif.master_cb);
        while (!vif.master_cb.rvalid);
            @(vif.master_cb)
        
        tr.rdata = vif.master_cb.rdata;
        tr.rresp = vif.master_cb.rresp;

        vif.master_cb.rready <= 1'b0;

        `uvm_info(get_type_name(), $sformatf("Read: %s", tr.convert2string()), UVM_MEDIUM)
        

    endtask





endclass

`endif
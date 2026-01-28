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


    endtask

    task drive_read(axi_lite_transaction tr);

    endtask





endclass

`endif
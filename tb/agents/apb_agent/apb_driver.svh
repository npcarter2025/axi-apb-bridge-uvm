`ifndef APB_DRIVER_SVH
`define APB_DRIVER_SVH

class apb_driver extends uvm_driver#(apb_transaction);

    `uvm_component_utils(apb_driver)

    virtual apb_if.slave vif;

    apb_config cfg;

    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface couldn't be found in config_db")
        
        if(!uvm_config_db#(apb_config)::get(this, "", "config", cfg))
            `uvm_fatal(get_type_name(), "apb Config object not found in config_db")

    endfunction


    task run_phase(uvm_phase phase);

        vif.wait_reset_done();

        vif.reset_slave_signals();

        forever begin

            wait_for_transfer();

            respond_to_transfer();

        end

    endtask

    task wait_for_transfer();
        @(vif.slave_cb);
        wait(vif.slave_cb.psel && !vif.slave_cb.penable);
    endtask


    task respond_to_transfer();
        @(vif.slave_cb);


    endtask


endclass

`endif


`ifndef APB_AGENT_SVH
`define APB_AGENT_SVH

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_driver driver;
    apb_monitor monitor;
    apb_sequencer sequencer;
    apb_config cfg;

    uvm_analysis_port #(apb_transaction) ap;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(apb_config)::get(this, "", "config", cfg)) begin
            `uvm_fatal(get_type_name(), "No Config found in database. Switching to Defaults")
            cfg = apb_config::type_id::create("cfg");
        end

        if (cfg.is_active == UVM_ACTIVE) begin

            driver = apb_driver::type_id::create("driver", this);
            sequencer = apb_sequencer::type_id::create("sequencer", this);

        end

        monitor = apb_monitor::type_id::create("monitor", this);
        ap = new("ap", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end

        monitor.ap.connect(ap);



    endfunction



endclass

`endif
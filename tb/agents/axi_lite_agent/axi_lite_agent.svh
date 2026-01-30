`ifndef AXI_LITE_AGENT_SVH
`define AXI_LITE_AGENT_SVH

class axi_lite_agent extends uvm_agent;

    `uvm_component_utils(axi_lite_agent)

    axi_lite_driver driver;
    axi_lite_monitor monitor;
    axi_lite_sequencer sequencer;
    axi_lite_config cfg;

    uvm_analysis_port #(axi_lite_transaction) ap;

    function new(string name = "axi_lite_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", cfg)) begin
            `uvm_info(get_type_name(), "No config found, using defaults", UVM_LOW)
            cfg = axi_lite_config::type_id::create("cfg");
        end

        if (cfg.is_active == UVM_ACTIVE) begin
            driver = axi_lite_driver::type_id::create("driver", this);
            sequencer = axi_lite_sequencer::type_id::create("sequencer", this);
        end
        monitor = axi_lite_monitor::type_id::create("monitor", this);

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
// ============================================
// AXI-Lite to APB Environment
// ============================================
// Minimal environment to get testbench running
// TODO: Add scoreboard and predictor later

class axi_lite_to_apb_env extends uvm_env;
    `uvm_component_utils(axi_lite_to_apb_env)

    // ============================================
    // Agents
    // ============================================
    axi_lite_pkg::axi_lite_agent axi_lite_agt;
    apb_pkg::apb_agent            apb_agt;

    // ============================================
    // Configuration
    // ============================================
    axi_lite_pkg::axi_lite_config axi_lite_cfg;
    apb_pkg::apb_config           apb_cfg;

    // TODO: Add later for full verification
    // axi_lite_to_apb_scoreboard sb;
    // axi_lite_to_apb_predictor predictor;
    // axi_lite_to_apb_virtual_sequencer v_seqr;

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "axi_lite_to_apb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ============================================
    // Build Phase
    // ============================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create configurations
        axi_lite_cfg = axi_lite_pkg::axi_lite_config::type_id::create("axi_lite_cfg");
        apb_cfg = apb_pkg::apb_config::type_id::create("apb_cfg");

        // Configure AXI-Lite agent (MASTER mode)
        axi_lite_cfg.is_active = UVM_ACTIVE;
        axi_lite_cfg.agent_mode = axi_lite_pkg::axi_lite_config::MASTER;
        
        // Configure APB agent (SLAVE mode)
        apb_cfg.is_active = UVM_ACTIVE;
        apb_cfg.agent_mode = apb_pkg::apb_config::SLAVE;

        // Set configurations in config_db
        uvm_config_db#(axi_lite_pkg::axi_lite_config)::set(this, "axi_lite_agt*", "config", axi_lite_cfg);
        uvm_config_db#(apb_pkg::apb_config)::set(this, "apb_agt*", "config", apb_cfg);

        // Create agents
        axi_lite_agt = axi_lite_pkg::axi_lite_agent::type_id::create("axi_lite_agt", this);
        apb_agt = apb_pkg::apb_agent::type_id::create("apb_agt", this);

        `uvm_info(get_type_name(), "Environment build phase complete", UVM_LOW)
    endfunction

    // ============================================
    // Connect Phase
    // ============================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // TODO: Connect agents to scoreboard when ready
        // axi_lite_agt.ap.connect(sb.axi_lite_export);
        // apb_agt.ap.connect(sb.apb_export);

        `uvm_info(get_type_name(), "Environment connect phase complete", UVM_LOW)
    endfunction

    // ============================================
    // End of Elaboration Phase
    // ============================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        `uvm_info(get_type_name(), "\n=== Environment Configuration ===", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("AXI-Lite Agent: %s, mode=%s", 
                  axi_lite_cfg.is_active == UVM_ACTIVE ? "ACTIVE" : "PASSIVE",
                  axi_lite_cfg.agent_mode == axi_lite_pkg::axi_lite_config::MASTER ? "MASTER" : "SLAVE"),
                  UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("APB Agent: %s, mode=%s",
                  apb_cfg.is_active == UVM_ACTIVE ? "ACTIVE" : "PASSIVE", 
                  apb_cfg.agent_mode == apb_pkg::apb_config::SLAVE ? "SLAVE" : "MASTER"),
                  UVM_LOW)
        `uvm_info(get_type_name(), "================================\n", UVM_LOW)
    endfunction

endclass

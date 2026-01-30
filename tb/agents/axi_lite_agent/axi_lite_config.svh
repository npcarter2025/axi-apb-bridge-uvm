`ifndef AXI_LITE_CONFIG_SVH
`define AXI_LITE_CONFIG_SVH

// ============================================
// AXI4-Lite Agent Configuration
// ============================================
// This object configures the behavior of the AXI-Lite agent.
// It's created by the test/env and passed to the agent.

class axi_lite_config extends uvm_object;
    
    // ============================================
    // CONFIGURATION FIELDS
    // ============================================
    
    // Agent mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    // Master or Slave mode
    typedef enum {MASTER, SLAVE} agent_mode_e;
    agent_mode_e agent_mode = MASTER;
    
    // Coverage enables
    bit coverage_enable = 1;
    bit protocol_checks_enable = 1;
    
    // Timing configuration (optional)
    int unsigned default_ready_delay = 0;  // Cycles before asserting ready
    int unsigned max_outstanding_transactions = 1;  // For pipelining (future)
    
    // Address range (for slave mode - future use)
    bit [31:0] start_addr = 32'h00000000;
    bit [31:0] end_addr   = 32'hFFFFFFFF;
    
    // ============================================
    // UVM AUTOMATION
    // ============================================
    `uvm_object_utils_begin(axi_lite_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_enum(agent_mode_e, agent_mode, UVM_ALL_ON)
        `uvm_field_int(coverage_enable, UVM_ALL_ON)
        `uvm_field_int(protocol_checks_enable, UVM_ALL_ON)
        `uvm_field_int(default_ready_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(max_outstanding_transactions, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(start_addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(end_addr, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    function new(string name = "axi_lite_config");
        super.new(name);
    endfunction
    
    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    // Check if address is in valid range (for slave mode)
    function bit is_valid_addr(bit [31:0] addr);
        return (addr >= start_addr && addr <= end_addr);
    endfunction
    
    // Print configuration
    function void display();
        `uvm_info(get_type_name(), 
                  $sformatf("\n%s", sprint()), 
                  UVM_MEDIUM)
    endfunction

endclass

`endif

`ifndef APB_CONFIG_SVH
`define APB_CONFIG_SVH

// ============================================
// APB4 Agent Configuration
// ============================================
// This object configures the behavior of the APB agent.
// It's created by the test/env and passed to the agent.

class apb_config extends uvm_object;
    
    // ============================================
    // CONFIGURATION FIELDS
    // ============================================
    
    // Agent mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;  // Usually monitor for bridge
    
    // Master or Slave mode
    typedef enum {MASTER, SLAVE} agent_mode_e;
    agent_mode_e agent_mode = SLAVE;  // Usually slave/monitor for bridge
    
    // Coverage enables
    bit coverage_enable = 1;
    bit protocol_checks_enable = 1;
    
    // Timing configuration (for slave/responder mode)
    int unsigned default_ready_delay = 0;  // Cycles before asserting pready
    int unsigned max_ready_delay = 10;     // Max wait states
    
    // Random ready injection (for slave mode)
    int unsigned ready_probability = 100;  // % chance of ready=1 (100 = always ready)
    
    // Error injection (for slave mode)
    int unsigned error_probability = 0;    // % chance of pslverr=1
    
    // Address range (for slave mode)
    bit [31:0] start_addr = 32'h0000_0000;
    bit [31:0] end_addr   = 32'hFFFF_FFFF;
    
    // ============================================
    // UVM AUTOMATION
    // ============================================
    `uvm_object_utils_begin(apb_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_enum(agent_mode_e, agent_mode, UVM_ALL_ON)
        `uvm_field_int(coverage_enable, UVM_ALL_ON)
        `uvm_field_int(protocol_checks_enable, UVM_ALL_ON)
        `uvm_field_int(default_ready_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(max_ready_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(ready_probability, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(error_probability, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(start_addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(end_addr, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    function new(string name = "apb_config");
        super.new(name);
    endfunction
    
    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    // Check if address is in valid range
    function bit is_valid_addr(bit [31:0] addr);
        return (addr >= start_addr && addr <= end_addr);
    endfunction
    
    // Should inject error? (based on probability)
    function bit should_inject_error();
        return ($urandom_range(0, 99) < error_probability);
    endfunction
    
    // Should be ready? (based on probability)
    function bit should_be_ready();
        return ($urandom_range(0, 99) < ready_probability);
    endfunction
    
    // Print configuration
    function void display();
        `uvm_info(get_type_name(), 
                  $sformatf("\n%s", sprint()), 
                  UVM_MEDIUM)
    endfunction

endclass

`endif

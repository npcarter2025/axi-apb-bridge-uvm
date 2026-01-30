`ifndef APB_SLAVE_BASE_SEQ_SVH
`define APB_SLAVE_BASE_SEQ_SVH

// ============================================
// APB Slave Base Sequence
// ============================================
// Base class for reactive APB slave sequences.
// Unlike master sequences, slave sequences are REACTIVE:
// - They respond to requests from the DUT (not generate them)
// - They run forever (not for N transactions)
// - They provide configurable response behavior

class apb_slave_base_seq extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_slave_base_seq)

    // ============================================
    // Configuration Parameters
    // ============================================
    rand int unsigned min_response_delay;  // Min cycles before pready
    rand int unsigned max_response_delay;  // Max cycles before pready
    rand int unsigned error_rate;          // Error injection rate (0-100%)
    
    bit [31:0] memory[bit[31:0]];          // Simple memory model

    // ============================================
    // Constraints
    // ============================================
    constraint delay_c {
        min_response_delay <= max_response_delay;
        max_response_delay <= 20;  // Max 20 cycle delay
        min_response_delay >= 0;
    }

    constraint error_rate_c {
        error_rate inside {[0:5]};  // Default 0-5% error rate
    }

    // ============================================
    // Constructor
    // ============================================
    function new(string name = "apb_slave_base_seq");
        super.new(name);
    endfunction

    // ============================================
    // Helper Functions
    // ============================================
    
    // Get random delay within configured range
    function int unsigned get_random_delay();
        return $urandom_range(min_response_delay, max_response_delay);
    endfunction

    // Determine if this transaction should have an error
    function bit should_inject_error();
        int rand_val = $urandom_range(0, 99);
        return (rand_val < error_rate);
    endfunction

    // Read from memory
    function bit [31:0] read_mem(bit [31:0] addr);
        if (memory.exists(addr)) begin
            return memory[addr];
        end else begin
            // Return random data for uninitialized locations
            return $urandom();
        end
    endfunction

    // Write to memory
    function void write_mem(bit [31:0] addr, bit [31:0] data, bit [3:0] strb);
        bit [31:0] current_data;
        
        // Read-modify-write based on strobe
        if (memory.exists(addr))
            current_data = memory[addr];
        else
            current_data = 32'h0;

        // Apply write strobes
        if (strb[0]) current_data[7:0]   = data[7:0];
        if (strb[1]) current_data[15:8]  = data[15:8];
        if (strb[2]) current_data[23:16] = data[23:16];
        if (strb[3]) current_data[31:24] = data[31:24];

        memory[addr] = current_data;
    endfunction

    // ============================================
    // Body Task (Usually overridden by children)
    // ============================================
    virtual task body();
        `uvm_info(get_type_name(), 
                  $sformatf("APB Slave Base Sequence: delay[%0d:%0d], error_rate=%0d%%",
                            min_response_delay, max_response_delay, error_rate),
                  UVM_MEDIUM)
    endtask

endclass

`endif

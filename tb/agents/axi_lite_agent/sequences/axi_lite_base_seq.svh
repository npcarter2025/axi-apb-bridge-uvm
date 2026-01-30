`ifndef AXI_LITE_BASE_SEQ_SVH
`define AXI_LITE_BASE_SEQ_SVH

class axi_lite_base_seq extends uvm_sequence#(axi_lite_transaction);
    `uvm_object_utils(axi_lite_base_seq)

    rand int unsigned num_transactions;
    rand bit [31:0]   start_addr;
    rand bit [31:0]   end_addr;

    constraint reasonable_num_txns_c {
        num_transactions inside {[10:50]};
    }

    constraint addr_range_c {
        start_addr < end_addr;
        start_addr[1:0] == 2'b00; // Word-aligned
        end_addr[1:0] == 2'b00;
    }

    //     Component	Purpose
    // num_transactions	Child sequences can randomize how many txns to send
    // start_addr/end_addr	Define address range for all sequences
    // Constraints	Provide reasonable defaults that can be overridden
    // pre_body()	Automatically manages test phase objections
    // post_body()	Ensures test doesn't end before sequence completes
    // virtual task body()	virtual allows child classes to override

    function new(string name = "axi_lite_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this, $sformatf("%s starting", get_full_name()));
        end
    endtask

    task post_body();
        if(starting_phase != null) begin
            starting_phase.drop_objection(this, $sformatf("%s completed", get_full_name()));
        end

    endtask

    virtual task body();

        `uvm_info(get_type_name(), $sformatf("Base sequence with %0d transactions", num_transactions), UVM_MEDIUM)
    endtask


    function bit [31:0] get_random_addr();
        bit [31:0] addr;
        assert(std::randomize(addr) with {
            addr inside {[start_addr:end_addr]};
            addr[1:0] == 2'b00; //word aligned
        });
        return addr;
    endfunction

    function bit [31:0] get_next_addr(bit [31:0] curr_addr);
        return (curr_addr + 32'h4);
    endfunction

endclass

`endif
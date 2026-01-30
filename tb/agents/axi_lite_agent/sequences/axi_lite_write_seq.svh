`ifndef AXI_LITE_WRITE_SEQ_SVH
`define AXI_LITE_WRITE_SEQ_SVH

class axi_lite_write_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_write_seq)

    function new(string name = "axi_lite_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), 
                  $sformatf("Starting %0d write transactions", num_transactions),
                  UVM_LOW)

        repeat(num_transactions) begin
            `uvm_do_with(req, {
                req.access_type == axi_lite_transaction::WRITE;
                req.addr inside {[start_addr:end_addr]};
            })
        end
    endtask

endclass

`endif

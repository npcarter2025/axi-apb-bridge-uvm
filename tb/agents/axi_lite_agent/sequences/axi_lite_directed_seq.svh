`ifndef AXI_LITE_DIRECTED_SEQ_SVH
`define AXI_LITE_DIRECTED_SEQ_SVH

// Simple directed sequence for quick sanity checks
class axi_lite_directed_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_directed_seq)

    function new(string name = "axi_lite_directed_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting directed sequence", UVM_LOW)

        // Write to address 0x0
        `uvm_do_with(req, {
            req.access_type == WRITE;
            req.addr == 32'h0000_0000;
            req.wdata == 32'hDEAD_BEEF;
        })

        // Read back from address 0x0
        `uvm_do_with(req, {
            req.access_type == READ;
            req.addr == 32'h0000_0000;
        })

        // Write to address 0x100
        `uvm_do_with(req, {
            req.access_type == WRITE;
            req.addr == 32'h0000_0100;
            req.wdata == 32'hCAFE_BABE;
        })

        // Read back from address 0x100
        `uvm_do_with(req, {
            req.access_type == READ;
            req.addr == 32'h0000_0100;
        })
    endtask

endclass

`endif

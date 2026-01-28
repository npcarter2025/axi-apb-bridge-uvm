`ifndef AXI_LITE_TRANSACTION_SVH
`define AXI_LITE_TRANSACTION_SVH

class axi_lite_transaction extends uvm_sequence_item;
    
    // ============================================
    // NOTE: This class uses parameters from axi_lite_pkg
    // To change widths, modify axi_lite_pkg.sv
    // ============================================
    //   AXI_ADDR_WIDTH - Address bus width
    //   AXI_DATA_WIDTH - Data bus width
    //   AXI_STRB_WIDTH - Strobe width (DATA_WIDTH/8)
    // ============================================

    // ============================================
    // TRANSACTION TYPE
    // ============================================
    typedef enum {READ, WRITE} access_type_e;
    rand access_type_e access_type;

    // ============================================
    // REQUEST FIELDS (from axi_lite_req_t)
    // ============================================
    rand bit [AXI_ADDR_WIDTH-1:0] addr;
    rand bit [2:0]                prot;

    rand bit [AXI_DATA_WIDTH-1:0] wdata;
    rand bit [AXI_STRB_WIDTH-1:0] wstrb;

    // ============================================
    // CONSTRAINTS
    // ============================================
    constraint valid_strb_c {
        if (access_type == WRITE) {
            wstrb != 4'h0;  // At least one byte enabled for writes
        }
    }

    constraint aligned_addr_c {
        // Word-aligned based on data width
        if (AXI_DATA_WIDTH == 32)
            addr[1:0] == 2'b00;  // 32-bit aligned
        else if (AXI_DATA_WIDTH == 64)
            addr[2:0] == 3'b000; // 64-bit aligned
    }

    // ============================================
    // POST RANDOMIZE
    // ============================================
    function void post_randomize();
        if (is_read()) begin
            wdata = 32'h0;  // Clear unused write fields for reads
            wstrb = 4'h0;
        end
    endfunction

    // ============================================
    // RESPONSE FIELDS (from axi_lite_resp_t)
    // ============================================
    bit [1:0]                bresp;
    bit [AXI_DATA_WIDTH-1:0] rdata;
    bit [1:0]                rresp;


    `uvm_object_utils_begin(axi_lite_transaction)
        `uvm_field_enum(access_type_e, access_type, UVM_ALL_ON)
        `uvm_field_int(addr,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(prot,  UVM_ALL_ON)
        `uvm_field_int(wdata,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(wstrb,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(bresp,  UVM_ALL_ON)
        `uvm_field_int(rdata,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rresp,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_lite_transaction");
        super.new(name);
    endfunction

    function bit is_write();
        return (access_type == WRITE);
    endfunction

    function bit is_read();
        return (access_type == READ);
    endfunction

    // ============================================
    // DEBUG/DISPLAY FUNCTIONS
    // ============================================
    function string convert2string();
        string s;
        s = $sformatf("AXI-Lite %s: addr=0x%08h, prot=0x%0h", 
                      access_type.name(), addr, prot);
        if (is_write())
            s = {s, $sformatf(", wdata=0x%08h, wstrb=0x%h, bresp=%s", 
                              wdata, wstrb, decode_resp(bresp))};
        else
            s = {s, $sformatf(", rdata=0x%08h, rresp=%s", 
                              rdata, decode_resp(rresp))};
        return s;
    endfunction

    function string decode_resp(bit [1:0] resp);
        case (resp)
            2'b00: return "OKAY";
            2'b01: return "EXOKAY";
            2'b10: return "SLVERR";
            2'b11: return "DECERR";
            default: return "UNKNOWN";
        endcase
    endfunction

    
endclass

`endif
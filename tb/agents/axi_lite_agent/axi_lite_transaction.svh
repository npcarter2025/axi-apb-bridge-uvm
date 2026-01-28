`ifndef AXI_LITE_TRANSACTION_SVH
`define AXI_LITE_TRANSACTION_SVH

class axi_lite_transaction extends uvm_sequence_item;
      // AXI LITE slave port
//   input  axi_lite_req_t               axi_lite_req_i,
//   output axi_lite_resp_t              axi_lite_resp_o,
//typedef struct packed {
//   aw_chan_lite_t aw;       // Write address channel
//   logic          aw_valid; // Write address valid
//   w_chan_lite_t  w;        // Write data channel
//   logic          w_valid;  // Write data valid
//   logic          b_ready;  // Write response ready
//   ar_chan_lite_t ar;       // Read address channel
//   logic          ar_valid; // Read address valid
//   logic          r_ready;  // Read data ready
// } axi_lite_req_t;

    typedef enum {READ, WRITE} access_type_e;
    rand access_type_e access_type;


// typedef struct packed {
//   addr_t          addr; // [31:0]
//   axi_pkg::prot_t prot; // [2:0]
// } aw_chan_lite_t;

    rand bit [31:0] addr;
    rand bit [ 2:0] prot;

// typedef struct packed {
//   data_t data; // [31:0]
//   strb_t strb; // [3:0]
// } w_chan_lite_t;

    rand bit [31:0] wdata;
    rand bit [ 3:0] wstrb;

// typedef struct packed {
//   addr_t          addr; // [31:0]
//   axi_pkg::prot_t prot; // [2:0]
// } ar_chan_lite_t;

    // ============================================
    // CONSTRAINTS
    // ============================================
    constraint valid_strb_c {
        if (access_type == WRITE) {
            wstrb != 4'h0;  // At least one byte enabled for writes
        }
    }

    constraint aligned_addr_c {
        addr[1:0] == 2'b00;  // 32-bit word-aligned addresses
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

    
/////////// output
// typedef struct packed {
//   logic          aw_ready; // Write address ready
//   logic          w_ready;  // Write data ready
//   b_chan_lite_t  b;        // Write response channel
//   logic          b_valid;  // Write response valid
//   logic          ar_ready; // Read address ready
//   r_chan_lite_t  r;        // Read data channel
//   logic          r_valid;  // Read data valid
// } axi_lite_resp_t;

// typedef struct packed {
//   axi_pkg::resp_t resp; // [1:0]
// } b_chan_lite_t;

    bit [1:0] bresp;

// typedef struct packed {
//   data_t          data; // [31:0]
//   axi_pkg::resp_t resp; // [1:0]
// } r_chan_lite_t;
    bit [31:0] rdata;
    bit [ 1:0] rresp;


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
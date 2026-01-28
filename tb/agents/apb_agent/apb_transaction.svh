`ifndef APB_TRANSACTION_SVH
`define APB_TRANSACTION_SVH

class apb_transaction extends uvm_sequence_item;

    // ============================================
    // APB4 PROTOCOL REFERENCE
    // ============================================
    // apb_req_t (Master → Slave):
    //   paddr   [31:0] - Address
    //   pprot   [2:0]  - Protection
    //   psel           - Slave select (driver controls)
    //   penable        - Enable (driver controls)
    //   pwrite         - 1=Write, 0=Read (driver controls)
    //   pwdata  [31:0] - Write data
    //   pstrb   [3:0]  - Write strobes
    //
    // apb_resp_t (Slave → Master):
    //   pready         - Transfer complete
    //   prdata  [31:0] - Read data
    //   pslverr        - Slave error
    // ============================================

    // ============================================
    // TRANSACTION TYPE
    // ============================================
    typedef enum {READ, WRITE} access_type_e;
    rand access_type_e access_type;

    // ============================================
    // REQUEST FIELDS (from apb_req_t)
    // ============================================
    // Note: psel, penable, pwrite are controlled by driver
    // (they implement the APB state machine)
    rand bit [31:0] paddr;   // Address
    rand bit [2:0]  pprot;   // Protection type
    rand bit [31:0] pwdata;  // Write data (only for WRITE)
    rand bit [3:0]  pstrb;   // Byte strobes (only for WRITE)

    // ============================================
    // RESPONSE FIELDS (from apb_resp_t)
    // ============================================
    // Filled by driver/monitor after slave responds
    bit [31:0] prdata;       // Read data (only for READ)
    bit        pslverr;      // Slave error response

    // ============================================
    // CONSTRAINTS
    // ============================================
    constraint valid_strb_c {
        if (access_type == WRITE) {
            pstrb != 4'h0;  // At least one byte enabled for writes
        }
    }

    constraint aligned_addr_c {
        paddr[1:0] == 2'b00;  // 32-bit word-aligned addresses
    }

    // ============================================
    // POST RANDOMIZE
    // ============================================
    function void post_randomize();
        if (is_read()) begin
            pwdata = 32'h0;  // Clear unused write fields for reads
            pstrb  = 4'h0;
        end
    endfunction

    // ============================================
    // UVM AUTOMATION
    // ============================================
    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_enum(access_type_e, access_type, UVM_ALL_ON)
        `uvm_field_int(paddr,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pprot,   UVM_ALL_ON)
        `uvm_field_int(pwdata,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pstrb,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(prdata,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_object_utils_end

    // ============================================
    // CONSTRUCTOR
    // ============================================
    function new(string name = "apb_transaction");
        super.new(name);
    endfunction

    // ============================================
    // HELPER FUNCTIONS
    // ============================================
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
        s = $sformatf("APB %s: paddr=0x%08h, pprot=0x%0h", 
                      access_type.name(), paddr, pprot);
        if (is_write())
            s = {s, $sformatf(", pwdata=0x%08h, pstrb=0x%h, pslverr=%s", 
                              pwdata, pstrb, pslverr ? "ERROR" : "OKAY")};
        else
            s = {s, $sformatf(", prdata=0x%08h, pslverr=%s", 
                              prdata, pslverr ? "ERROR" : "OKAY")};
        return s;
    endfunction

endclass

`endif
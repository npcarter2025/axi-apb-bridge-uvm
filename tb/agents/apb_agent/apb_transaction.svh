`ifndef APB_TRANSACTION_SVH
`define APB_TRANSACTION_SVH

class apb_transaction extends uvm_sequence_item;

    // ============================================
    // NOTE: This class uses parameters from apb_pkg
    // To change widths, modify apb_pkg.sv
    // ============================================
    //   APB_ADDR_WIDTH - Address bus width
    //   APB_DATA_WIDTH - Data bus width
    //   APB_STRB_WIDTH - Strobe width (DATA_WIDTH/8)
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
    rand bit [APB_ADDR_WIDTH-1:0] paddr;   // Address
    rand bit [2:0]                pprot;   // Protection type
    rand bit [APB_DATA_WIDTH-1:0] pwdata;  // Write data (only for WRITE)
    rand bit [APB_STRB_WIDTH-1:0] pstrb;   // Byte strobes (only for WRITE)

    // ============================================
    // RESPONSE FIELDS (from apb_resp_t)
    // ============================================
    // Filled by driver/monitor after slave responds
    bit [APB_DATA_WIDTH-1:0] prdata;       // Read data (only for READ)
    bit                      pslverr;      // Slave error response
    
    // ============================================
    // DRIVER CONTROL FIELDS
    // ============================================
    // Used by slave sequences to control driver behavior
    int unsigned             response_delay; // Cycles to delay before asserting pready
    bit                      pwrite;         // Write enable (derived from access_type)

    // ============================================
    // CONSTRAINTS
    // ============================================
    constraint valid_strb_c {
        if (access_type == WRITE) {
            pstrb != 4'h0;  // At least one byte enabled for writes
        }
    }

    constraint aligned_addr_c {
        // Word-aligned based on data width
        if (APB_DATA_WIDTH == 32)
            paddr[1:0] == 2'b00;  // 32-bit aligned
        else if (APB_DATA_WIDTH == 64)
            paddr[2:0] == 3'b000; // 64-bit aligned
    }

    // ============================================
    // POST RANDOMIZE
    // ============================================
    function void post_randomize();
        if (is_read()) begin
            pwdata = 32'h0;  // Clear unused write fields for reads
            pstrb  = 4'h0;
        end
        // Update pwrite based on access_type
        pwrite = (access_type == WRITE);
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
        `uvm_field_int(response_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(pwrite,  UVM_ALL_ON)
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
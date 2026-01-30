// ============================================
// Top-Level Testbench for AXI-Lite to APB Bridge
// ============================================
// Minimal UVM testbench to get running quickly

`include "axi/typedef.svh"
`include "axi/assign.svh"

module tb_axi_lite_to_apb_top;

    // ============================================
    // Import Packages
    // ============================================
    import uvm_pkg::*;
    import tb_pkg::*;

    // ============================================
    // Parameters
    // ============================================
    localparam int unsigned ADDR_WIDTH = 32;
    localparam int unsigned DATA_WIDTH = 32;
    localparam int unsigned STRB_WIDTH = DATA_WIDTH / 8;
    localparam int unsigned NUM_APB_SLAVES = 1;  // Start with 1 slave for simplicity
    localparam int unsigned NUM_RULES = 1;
    
    localparam time CLK_PERIOD = 10ns;
    
    // ============================================
    // Type Definitions
    // ============================================
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef axi_pkg::xbar_rule_32_t rule_t;
    
    // AXI-Lite channel types
    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
    `AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
    `AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
    
    // APB struct types
    typedef struct packed {
        addr_t          paddr;
        axi_pkg::prot_t pprot;
        logic           psel;
        logic           penable;
        logic           pwrite;
        data_t          pwdata;
        strb_t          pstrb;
    } apb_req_t;
    
    typedef struct packed {
        logic  pready;
        data_t prdata;
        logic  pslverr;
    } apb_resp_t;
    
    // Address map (simple single slave at 0x0)
    localparam rule_t [NUM_RULES-1:0] ADDR_MAP = '{
        '{idx: 32'd0, start_addr: 32'h0000_0000, end_addr: 32'h0001_0000}
    };

    // ============================================
    // Clock and Reset
    // ============================================
    logic clk;
    logic rst_n;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Reset generation
    initial begin
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        `uvm_info("TB_TOP", "Reset released", UVM_LOW)
    end

    // ============================================
    // Interfaces
    // ============================================
    axi_lite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_lite_vif (
        .clk(clk),
        .rst_n(rst_n)
    );
    
    apb_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) apb_vif (
        .clk(clk),
        .rst_n(rst_n)
    );

    // ============================================
    // DUT Signals (struct-based)
    // ============================================
    axi_req_t axi_req;
    axi_resp_t axi_resp;
    apb_req_t [NUM_APB_SLAVES-1:0] apb_req;
    apb_resp_t [NUM_APB_SLAVES-1:0] apb_resp;

    // ============================================
    // Connect Interface to Structs
    // ============================================
    
    // AXI-Lite: Interface → DUT Request Struct
    assign axi_req.aw.addr = axi_lite_vif.awaddr;
    assign axi_req.aw.prot = axi_lite_vif.awprot;
    assign axi_req.aw_valid = axi_lite_vif.awvalid;
    
    assign axi_req.w.data = axi_lite_vif.wdata;
    assign axi_req.w.strb = axi_lite_vif.wstrb;
    assign axi_req.w_valid = axi_lite_vif.wvalid;
    
    assign axi_req.b_ready = axi_lite_vif.bready;
    
    assign axi_req.ar.addr = axi_lite_vif.araddr;
    assign axi_req.ar.prot = axi_lite_vif.arprot;
    assign axi_req.ar_valid = axi_lite_vif.arvalid;
    
    assign axi_req.r_ready = axi_lite_vif.rready;
    
    // AXI-Lite: DUT Response Struct → Interface
    assign axi_lite_vif.awready = axi_resp.aw_ready;
    assign axi_lite_vif.wready = axi_resp.w_ready;
    assign axi_lite_vif.bresp = axi_resp.b.resp;
    assign axi_lite_vif.bvalid = axi_resp.b_valid;
    assign axi_lite_vif.arready = axi_resp.ar_ready;
    assign axi_lite_vif.rdata = axi_resp.r.data;
    assign axi_lite_vif.rresp = axi_resp.r.resp;
    assign axi_lite_vif.rvalid = axi_resp.r_valid;
    
    // APB: DUT Request Struct → Interface
    assign apb_vif.paddr = apb_req[0].paddr;
    assign apb_vif.pprot = apb_req[0].pprot;
    assign apb_vif.psel = apb_req[0].psel;
    assign apb_vif.penable = apb_req[0].penable;
    assign apb_vif.pwrite = apb_req[0].pwrite;
    assign apb_vif.pwdata = apb_req[0].pwdata;
    assign apb_vif.pstrb = apb_req[0].pstrb;
    
    // APB: Interface → DUT Response Struct
    assign apb_resp[0].pready = apb_vif.pready;
    assign apb_resp[0].prdata = apb_vif.prdata;
    assign apb_resp[0].pslverr = apb_vif.pslverr;

    // ============================================
    // DUT Instantiation
    // ============================================
    axi_lite_to_apb #(
        .NoApbSlaves      (NUM_APB_SLAVES),
        .NoRules          (NUM_RULES),
        .AddrWidth        (ADDR_WIDTH),
        .DataWidth        (DATA_WIDTH),
        .PipelineRequest  (1'b0),
        .PipelineResponse (1'b0),
        .axi_lite_req_t   (axi_req_t),
        .axi_lite_resp_t  (axi_resp_t),
        .apb_req_t        (apb_req_t),
        .apb_resp_t       (apb_resp_t),
        .rule_t           (rule_t)
    ) dut (
        .clk_i          (clk),
        .rst_ni         (rst_n),
        .axi_lite_req_i (axi_req),
        .axi_lite_resp_o(axi_resp),
        .apb_req_o      (apb_req),
        .apb_resp_i     (apb_resp),
        .addr_map_i     (ADDR_MAP)
    );

    // ============================================
    // UVM Configuration
    // ============================================
    initial begin
        // Set interfaces in config_db so agents can find them
        uvm_config_db#(virtual axi_lite_if)::set(null, "uvm_test_top.env.axi_lite_agt*", "vif", axi_lite_vif);
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt*", "vif", apb_vif);
        
        // Run the test
        run_test();
    end
    
    // ============================================
    // Waveform Dumping
    // ============================================
    initial begin
        if ($test$plusargs("DUMP")) begin
            $dumpfile("dump.vcd");
            $dumpvars(0, tb_axi_lite_to_apb_top);
        end
    end
    
    // ============================================
    // Timeout Watchdog
    // ============================================
    initial begin
        #10ms;
        `uvm_fatal("TB_TOP", "Timeout! Test ran for 10ms")
    end

endmodule

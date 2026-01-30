// ============================================
// AXI4-Lite Interface for UVM Verification
// ============================================
// This interface contains all AXI4-Lite signals and provides
// clocking blocks and modports for UVM agents.

interface axi_lite_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n
);

    // ============================================
    // PARAMETERS
    // ============================================
    localparam int STRB_WIDTH = DATA_WIDTH / 8;

    // ============================================
    // AXI4-LITE SIGNALS
    // ============================================
    
    // Write Address Channel (AW)
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [2:0]            awprot;
    logic                  awvalid;
    logic                  awready;
    
    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0] wdata;
    logic [STRB_WIDTH-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;
    
    // Write Response Channel (B)
    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;
    
    // Read Address Channel (AR)
    logic [ADDR_WIDTH-1:0] araddr;
    logic [2:0]            arprot;
    logic                  arvalid;
    logic                  arready;
    
    // Read Data Channel (R)
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;

    // ============================================
    // CLOCKING BLOCKS
    // ============================================
    
    // Master Clocking Block (for Driver)
    // Master drives: request signals (addr, data, valid)
    // Master samples: response signals (ready, resp)
    clocking master_cb @(posedge clk);
        default input #1step output #0;
        
        // Write Address Channel
        output awaddr;
        output awprot;
        output awvalid;
        input  awready;
        
        // Write Data Channel
        output wdata;
        output wstrb;
        output wvalid;
        input  wready;
        
        // Write Response Channel
        input  bresp;
        input  bvalid;
        output bready;
        
        // Read Address Channel
        output araddr;
        output arprot;
        output arvalid;
        input  arready;
        
        // Read Data Channel
        input  rdata;
        input  rresp;
        input  rvalid;
        output rready;
    endclocking
    
    // Monitor Clocking Block (for Monitor)
    // Monitor only observes - all signals are inputs
    clocking monitor_cb @(posedge clk);
        default input #1step;
        
        // Write Address Channel
        input awaddr;
        input awprot;
        input awvalid;
        input awready;
        
        // Write Data Channel
        input wdata;
        input wstrb;
        input wvalid;
        input wready;
        
        // Write Response Channel
        input bresp;
        input bvalid;
        input bready;
        
        // Read Address Channel
        input araddr;
        input arprot;
        input arvalid;
        input arready;
        
        // Read Data Channel
        input rdata;
        input rresp;
        input rvalid;
        input rready;
    endclocking
    
    // Slave Clocking Block (for Slave/Responder - if needed)
    clocking slave_cb @(posedge clk);
        default input #1step output #0;
        
        // Write Address Channel
        input  awaddr;
        input  awprot;
        input  awvalid;
        output awready;
        
        // Write Data Channel
        input  wdata;
        input  wstrb;
        input  wvalid;
        output wready;
        
        // Write Response Channel
        output bresp;
        output bvalid;
        input  bready;
        
        // Read Address Channel
        input  araddr;
        input  arprot;
        input  arvalid;
        output arready;
        
        // Read Data Channel
        output rdata;
        output rresp;
        output rvalid;
        input  rready;
    endclocking

    // ============================================
    // MODPORTS
    // ============================================
    
    // Master modport (for AXI-Lite Master Driver)
    modport master (
        clocking master_cb,
        input clk,
        input rst_n,
        import wait_reset_done,
        import reset_master_signals
    );
    
    // Monitor modport (for AXI-Lite Monitor)
    modport monitor (
        clocking monitor_cb,
        input clk,
        input rst_n,
        import wait_reset_done
    );
    
    // Slave modport (for AXI-Lite Slave/Responder - if needed)
    modport slave (
        clocking slave_cb,
        input clk,
        input rst_n
    );
    
    // DUT modport (for reference - shows DUT's perspective)
    modport dut (
        // Write Address Channel
        input  awaddr,
        input  awprot,
        input  awvalid,
        output awready,
        
        // Write Data Channel
        input  wdata,
        input  wstrb,
        input  wvalid,
        output wready,
        
        // Write Response Channel
        output bresp,
        output bvalid,
        input  bready,
        
        // Read Address Channel
        input  araddr,
        input  arprot,
        input  arvalid,
        output arready,
        
        // Read Data Channel
        output rdata,
        output rresp,
        output rvalid,
        input  rready,
        
        input clk,
        input rst_n
    );

    // ============================================
    // HELPER TASKS/FUNCTIONS
    // ============================================
    
    // Wait for N clock cycles
    task wait_cycles(int n);
        repeat(n) @(posedge clk);
    endtask
    
    // Wait for reset deassertion
    task wait_reset_done();
        @(posedge clk);
        wait(rst_n == 1'b1);
        @(posedge clk);
    endtask
    
    // Reset all master-driven signals to idle
    task reset_master_signals();
        awaddr  <= '0;
        awprot  <= '0;
        awvalid <= 1'b0;
        wdata   <= '0;
        wstrb   <= '0;
        wvalid  <= 1'b0;
        bready  <= 1'b0;
        araddr  <= '0;
        arprot  <= '0;
        arvalid <= 1'b0;
        rready  <= 1'b0;
    endtask
    
    // Reset all slave-driven signals to idle
    task reset_slave_signals();
        awready <= 1'b0;
        wready  <= 1'b0;
        bresp   <= 2'b00;
        bvalid  <= 1'b0;
        arready <= 1'b0;
        rdata   <= '0;
        rresp   <= 2'b00;
        rvalid  <= 1'b0;
    endtask

    // ============================================
    // ASSERTIONS (Protocol Checks)
    // ============================================
    
    // AXI-Lite Spec: Once valid is asserted, it must stay high until ready
    property p_awvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (awvalid && !awready) |=> awvalid;
    endproperty
    assert_awvalid_stable: assert property(p_awvalid_stable)
        else $error("AXI-Lite Protocol Violation: awvalid deasserted before awready");
    
    property p_wvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && !wready) |=> wvalid;
    endproperty
    assert_wvalid_stable: assert property(p_wvalid_stable)
        else $error("AXI-Lite Protocol Violation: wvalid deasserted before wready");
    
    property p_arvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (arvalid && !arready) |=> arvalid;
    endproperty
    assert_arvalid_stable: assert property(p_arvalid_stable)
        else $error("AXI-Lite Protocol Violation: arvalid deasserted before arready");
    
    property p_bvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (bvalid && !bready) |=> bvalid;
    endproperty
    assert_bvalid_stable: assert property(p_bvalid_stable)
        else $error("AXI-Lite Protocol Violation: bvalid deasserted before bready");
    
    property p_rvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (rvalid && !rready) |=> rvalid;
    endproperty
    assert_rvalid_stable: assert property(p_rvalid_stable)
        else $error("AXI-Lite Protocol Violation: rvalid deasserted before rready");
    
    // AXI-Lite Spec: Once asserted, data must remain stable until handshake
    property p_awaddr_stable;
        @(posedge clk) disable iff (!rst_n)
        (awvalid && !awready) |=> $stable(awaddr);
    endproperty
    assert_awaddr_stable: assert property(p_awaddr_stable)
        else $error("AXI-Lite Protocol Violation: awaddr changed before handshake");
    
    property p_wdata_stable;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && !wready) |=> $stable(wdata);
    endproperty
    assert_wdata_stable: assert property(p_wdata_stable)
        else $error("AXI-Lite Protocol Violation: wdata changed before handshake");
    
    property p_araddr_stable;
        @(posedge clk) disable iff (!rst_n)
        (arvalid && !arready) |=> $stable(araddr);
    endproperty
    assert_araddr_stable: assert property(p_araddr_stable)
        else $error("AXI-Lite Protocol Violation: araddr changed before handshake");

endinterface : axi_lite_if

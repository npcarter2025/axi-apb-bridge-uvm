// ============================================
// APB4 (AMBA APB v2.0) Interface for UVM Verification
// ============================================
// This interface contains all APB4 signals and provides
// clocking blocks and modports for UVM agents.

interface apb_if #(
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
    // APB4 SIGNALS
    // ============================================
    
    // Address and Control Signals (Master → Slave)
    logic [ADDR_WIDTH-1:0] paddr;    // Address bus
    logic [2:0]            pprot;    // Protection type
    logic                  psel;     // Slave select
    logic                  penable;  // Enable (indicates 2nd cycle of transfer)
    logic                  pwrite;   // Direction (1=write, 0=read)
    
    // Write Data Signals (Master → Slave)
    logic [DATA_WIDTH-1:0] pwdata;   // Write data bus
    logic [STRB_WIDTH-1:0] pstrb;    // Write strobes (byte lane enables)
    
    // Response Signals (Slave → Master)
    logic                  pready;   // Slave ready (can extend transfer)
    logic [DATA_WIDTH-1:0] prdata;   // Read data bus
    logic                  pslverr;  // Slave error

    // ============================================
    // CLOCKING BLOCKS
    // ============================================
    
    // Master Clocking Block (for Driver in Master mode)
    // Master drives: address, control, write data
    // Master samples: ready, read data, error
    clocking master_cb @(posedge clk);
        default input #1step output #0;
        
        // Master drives these
        output paddr;
        output pprot;
        output psel;
        output penable;
        output pwrite;
        output pwdata;
        output pstrb;
        
        // Master samples these
        input  pready;
        input  prdata;
        input  pslverr;
    endclocking
    
    // Monitor Clocking Block (for Monitor)
    // Monitor only observes - all signals are inputs
    clocking monitor_cb @(posedge clk);
        default input #1step;
        
        // Monitor observes everything
        input paddr;
        input pprot;
        input psel;
        input penable;
        input pwrite;
        input pwdata;
        input pstrb;
        input pready;
        input prdata;
        input pslverr;
    endclocking
    
    // Slave Clocking Block (for Driver in Slave/Responder mode)
    // Slave samples: address, control, write data
    // Slave drives: ready, read data, error
    clocking slave_cb @(posedge clk);
        default input #1step output #0;
        
        // Slave samples these
        input  paddr;
        input  pprot;
        input  psel;
        input  penable;
        input  pwrite;
        input  pwdata;
        input  pstrb;
        
        // Slave drives these
        output pready;
        output prdata;
        output pslverr;
    endclocking

    // ============================================
    // MODPORTS
    // ============================================
    
    // Master modport (for APB Master Driver)
    modport master (
        clocking master_cb,
        input clk,
        input rst_n
    );
    
    // Monitor modport (for APB Monitor)
    modport monitor (
        clocking monitor_cb,
        input clk,
        input rst_n
    );
    
    // Slave modport (for APB Slave/Responder)
    modport slave (
        clocking slave_cb,
        input clk,
        input rst_n
    );
    
    // DUT modport (for reference - shows DUT's perspective)
    modport dut_master (
        // Master drives
        output paddr,
        output pprot,
        output psel,
        output penable,
        output pwrite,
        output pwdata,
        output pstrb,
        
        // Slave responds
        input  pready,
        input  prdata,
        input  pslverr,
        
        input clk,
        input rst_n
    );
    
    modport dut_slave (
        // Master drives
        input  paddr,
        input  pprot,
        input  psel,
        input  penable,
        input  pwrite,
        input  pwdata,
        input  pstrb,
        
        // Slave responds
        output pready,
        output prdata,
        output pslverr,
        
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
        paddr   <= '0;
        pprot   <= '0;
        psel    <= 1'b0;
        penable <= 1'b0;
        pwrite  <= 1'b0;
        pwdata  <= '0;
        pstrb   <= '0;
    endtask
    
    // Reset all slave-driven signals to idle
    task reset_slave_signals();
        pready  <= 1'b0;
        prdata  <= '0;
        pslverr <= 1'b0;
    endtask
    
    // Wait for APB transfer to complete (master perspective)
    task wait_transfer_complete();
        @(posedge clk);
        wait(psel && penable && pready);
        @(posedge clk);
    endtask
    
    // Check if currently in SETUP phase
    function bit is_setup_phase();
        return (psel && !penable);
    endfunction
    
    // Check if currently in ACCESS phase
    function bit is_access_phase();
        return (psel && penable);
    endfunction

    // ============================================
    // ASSERTIONS (Protocol Checks)
    // ============================================
    
    // APB Spec: penable must not be high when psel is low
    property p_penable_requires_psel;
        @(posedge clk) disable iff (!rst_n)
        penable |-> psel;
    endproperty
    assert_penable_requires_psel: assert property(p_penable_requires_psel)
        else $error("APB Protocol Violation: penable asserted without psel");
    
    // APB Spec: Address/control must be stable during ACCESS phase
    property p_paddr_stable_during_access;
        @(posedge clk) disable iff (!rst_n)
        (psel && penable && !pready) |=> $stable(paddr);
    endproperty
    assert_paddr_stable: assert property(p_paddr_stable_during_access)
        else $error("APB Protocol Violation: paddr changed during ACCESS phase");
    
    property p_pwrite_stable_during_access;
        @(posedge clk) disable iff (!rst_n)
        (psel && penable && !pready) |=> $stable(pwrite);
    endproperty
    assert_pwrite_stable: assert property(p_pwrite_stable_during_access)
        else $error("APB Protocol Violation: pwrite changed during ACCESS phase");
    
    property p_pprot_stable_during_access;
        @(posedge clk) disable iff (!rst_n)
        (psel && penable && !pready) |=> $stable(pprot);
    endproperty
    assert_pprot_stable: assert property(p_pprot_stable_during_access)
        else $error("APB Protocol Violation: pprot changed during ACCESS phase");
    
    // APB Spec: Write data must be stable during ACCESS phase
    property p_pwdata_stable_during_write;
        @(posedge clk) disable iff (!rst_n)
        (psel && penable && pwrite && !pready) |=> $stable(pwdata);
    endproperty
    assert_pwdata_stable: assert property(p_pwdata_stable_during_write)
        else $error("APB Protocol Violation: pwdata changed during ACCESS phase");
    
    property p_pstrb_stable_during_write;
        @(posedge clk) disable iff (!rst_n)
        (psel && penable && pwrite && !pready) |=> $stable(pstrb);
    endproperty
    assert_pstrb_stable: assert property(p_pstrb_stable_during_write)
        else $error("APB Protocol Violation: pstrb changed during ACCESS phase");
    
    // APB Spec: psel must remain high during entire transfer
    property p_psel_stable_during_transfer;
        @(posedge clk) disable iff (!rst_n)
        (psel && !penable) |=> psel;  // SETUP → ACCESS: psel stays high
    endproperty
    assert_psel_stable: assert property(p_psel_stable_during_transfer)
        else $error("APB Protocol Violation: psel deasserted between SETUP and ACCESS");
    
    // APB Spec: penable follows psel (2-phase protocol)
    property p_penable_follows_psel;
        @(posedge clk) disable iff (!rst_n)
        ($rose(psel) && !penable) |=> penable;
    endproperty
    assert_penable_follows: assert property(p_penable_follows_psel)
        else $error("APB Protocol Violation: penable did not follow psel (missing ACCESS phase)");
    
    // Coverage: Track APB states
    covergroup cg_apb_states @(posedge clk);
        option.per_instance = 1;
        
        cp_state: coverpoint {psel, penable} {
            bins IDLE   = {2'b00};
            bins SETUP  = {2'b10};
            bins ACCESS = {2'b11};
            illegal_bins INVALID = {2'b01};  // penable without psel
        }
        
        cp_pwrite: coverpoint pwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }
        
        cp_pready: coverpoint pready {
            bins NOT_READY = {0};
            bins READY     = {1};
        }
        
        cp_pslverr: coverpoint pslverr {
            bins OKAY  = {0};
            bins ERROR = {1};
        }
        
        // Cross coverage: State x Operation
        cross cp_state, cp_pwrite;
        
        // Cross coverage: Ready response during ACCESS
        cross cp_state, cp_pready {
            ignore_bins not_access = binsof(cp_state) intersect {2'b00, 2'b10};
        }
        
        // Cross coverage: Error response
        cross cp_state, cp_pslverr {
            ignore_bins not_access = binsof(cp_state) intersect {2'b00, 2'b10};
        }
        
    endgroup
    
    cg_apb_states cg_states = new();

    // ============================================
    // DEBUG DISPLAY FUNCTIONS
    // ============================================
    
    // Return current phase as string
    function string get_phase_name();
        if (!psel)
            return "IDLE";
        else if (psel && !penable)
            return "SETUP";
        else if (psel && penable)
            return "ACCESS";
        else
            return "INVALID";
    endfunction
    
    // Display current transaction info
    function void display_transaction();
        $display("[%0t] APB %s: Phase=%s, Addr=0x%h, Write=%b, Ready=%b, Error=%b",
                 $time, pwrite ? "WRITE" : "READ", get_phase_name(),
                 paddr, pwrite, pready, pslverr);
        if (pwrite && penable)
            $display("         Write Data=0x%h, Strb=0x%h", pwdata, pstrb);
        else if (!pwrite && penable && pready)
            $display("         Read Data=0x%h", prdata);
    endfunction

endinterface : apb_if

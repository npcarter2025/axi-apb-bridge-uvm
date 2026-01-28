// ============================================================================
// VCS-Specific Compilation Options
// ============================================================================
// AMD-style tool-specific filelist
// This file contains ONLY VCS-specific compiler options

// VCS Compiler Options
-sverilog
-full64
-timescale=1ns/1ps

// Debug Options
-debug_access+all
-kdb
-lca

// Linker Options
-LDFLAGS -Wl,--no-as-needed

// VCS Defines
+define+VCS
+define+SIMULATION

// Include common tool-independent files
// Path relative to where VCS is run from (sim/build/)
-f ../files/common/top.f

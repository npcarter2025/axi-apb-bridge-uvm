// ============================================================================
// Top-Level Filelist - Tool Independent
// ============================================================================
// AMD-style modular filelist
// This file includes all other common filelists
//
// Usage: Tool-specific makefiles include this file along with their
//        tool-specific options
//
// Note: All paths in included files are relative to project root

// Include all dependency and source filelists
-f deps_common_cells.f
-f deps_axi.f
-f rtl.f
-f tb.f

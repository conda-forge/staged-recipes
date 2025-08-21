# Patches for Mumble VoIP Package

This directory contains patches that are applied to the mumble source code during the conda build process.

## Patch Descriptions

### 0001-fix-windows-msvc-flags.patch
**Purpose**: Fixes Windows MSVC compiler flag conflicts when building protobuf generated files.

**Problem**: 
The original mumble build system causes compilation errors on Windows with MSVC due to:
1. **D9025 Warning**: Conflicting `/W4` and `/w` compiler flags
   - The project enables `/W4` (warning level 4) globally
   - Protobuf generated files use `/w` (disable all warnings) directly
   - MSVC reports: `warning D9025 : overriding '/W4' with '/w'`

2. **C4530 Error**: Missing exception handling support
   - Error: `C++ exception handler used, but unwind semantics are not enabled. Specify /EHsc`
   - The `/EHsc` flag was not being applied consistently

**Solution**:
The patch modifies `src/CMakeLists.txt` to:

1. **Replace blanket warning disable**: Instead of using `-w` for all compilers, it now:
   - Uses specific warning disables for MSVC: `/wd4996 /wd4244 /wd4267 /wd4005 /wd4800 /wd4018 /wd4065`
   - Keeps `-w` for GCC/Clang compilers
   - Always includes `/EHsc` for MSVC to ensure exception handling

2. **Ensure exception handling**: Adds explicit `/EHsc` flag to the shared target for MSVC

**Files Modified**:
- `src/CMakeLists.txt`: Updated protobuf file compilation flags

**Result**:
- Eliminates D9025 warnings about conflicting flags
- Prevents C4530 errors about missing exception handling
- Maintains warning suppression for protobuf generated files
- Ensures proper C++ exception handling on Windows

This patch is essential for successful Windows builds using MSVC compiler.
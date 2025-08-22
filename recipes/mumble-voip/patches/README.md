# Patches for Mumble VoIP Package

This directory contains minimal patches applied to the mumble source code during the conda build process.

## Current Patches

### 0001-fix-msvc-protobuf-warnings.patch
**Purpose**: Fixes MSVC compiler flag conflicts specifically for protobuf generated files.

**Problem**: 
The original CMakeLists.txt uses `-w` (disable all warnings) for protobuf generated files, which conflicts with MSVC's `/W4` flag and causes D9025 warnings about conflicting compiler flags.

**Solution**:
The patch replaces the problematic `-w` flag with MSVC-specific warning disables only for protobuf files:
```cmake
if(MSVC)
    # For MSVC, use specific warning disables to avoid flag conflicts
    set_source_files_properties("${CURRENT_FILE}" PROPERTIES 
        COMPILE_FLAGS "/wd4996 /wd4244 /wd4267 /wd4005 /wd4800 /wd4018 /wd4065 /wd4100"
    )
else()
    # For GCC/Clang, use -w to disable all warnings
    set_source_files_properties("${CURRENT_FILE}" PROPERTIES COMPILE_FLAGS "-w")
endif()
```

**Files Modified**:
- `src/CMakeLists.txt`: Updated protobuf file warning handling for MSVC

**Additional Configuration**:
The recipe also includes global `/EHsc` flags for proper exception handling:
```yaml
"windows" => {
  cxx_flags: "/EHsc"
  c_flags: "/std:c11 /EHsc"
}
```

**Result**:
- Eliminates D9025 warnings about conflicting flags for protobuf files
- Suppresses common warnings in generated protobuf code (`/wd4996`, `/wd4244`, etc.)
- Maintains warning suppression approach for GCC/Clang builds
- Combined with global `/EHsc`, ensures successful Windows builds

This targeted approach handles protobuf-specific issues without suppressing warnings globally.

## Removed Patches

### 0002-fix-macos-avfoundation-compatibility.patch (REMOVED)
**Status**: Removed - replaced with updated build target.

**Original Problem**: 
Mumble uses `AVAuthorizationStatus` (introduced in macOS 10.14) but conda-forge was targeting macOS 10.13 for backward compatibility.

**New Solution**:
The conda build configuration was updated to target macOS 10.14:
```yaml
c_stdlib_version: # [osx and x86_64]
  - "10.14" # [osx and x86_64]
```

**Benefit**: This eliminates the need for complex compatibility patches by aligning the build target with Mumble's API requirements. The AVFoundation APIs are now natively available at build time.

## Current Status

The build now uses a hybrid approach:

1. **Windows**: Minimal protobuf warning patch + global `/EHsc` compiler flags
2. **macOS**: Updated build target to 10.14 (no patches needed)
3. **Linux**: No patches needed

This approach provides clean, maintainable builds with minimal source code modifications, targeting only the specific issues that cannot be resolved through configuration alone.
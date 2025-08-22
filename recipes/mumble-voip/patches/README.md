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

3. **C4100 Warning**: Unreferenced parameter warnings in generated protobuf code
   - Warning: `'parameter_name': unreferenced parameter`
   - Protobuf generated code often contains unused parameters that trigger this warning

**Solution**:
The patch modifies `src/CMakeLists.txt` to:

1. **Replace blanket warning disable**: Instead of using `-w` for all compilers, it now:
   - Uses specific warning disables for MSVC: `/wd4996 /wd4244 /wd4267 /wd4005 /wd4800 /wd4018 /wd4065 /wd4100`
   - Keeps `-w` for GCC/Clang compilers
   - Always includes `/EHsc` for MSVC to ensure exception handling

2. **Ensure exception handling**: Adds explicit `/EHsc` flag to the shared target for MSVC

**Files Modified**:
- `src/CMakeLists.txt`: Updated protobuf file compilation flags

**Result**:
- Eliminates D9025 warnings about conflicting flags
- Prevents C4530 errors about missing exception handling
- Suppresses C4100 warnings about unreferenced parameters in protobuf code
- Maintains warning suppression for protobuf generated files
- Ensures proper C++ exception handling on Windows

This patch is essential for successful Windows builds using MSVC compiler.

### 0002-fix-macos-avfoundation-compatibility.patch
**Purpose**: Fixes macOS build compatibility with macOS 10.13 SDK by handling AVFoundation API availability.

**Problem**: 
The mumble source code uses `AVAuthorizationStatus` and related microphone permission APIs that were introduced in macOS 10.14, but conda-forge builds target macOS 10.13 for backward compatibility. This causes compilation errors:

```
/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk/System/Library/Frameworks/AVFoundation.framework/Headers/AVCaptureDevice.h:1433:28: note: 'AVAuthorizationStatus' has been explicitly marked unavailable here
```

**Solution**:
The patch adds conditional compilation directives that:

1. **Check macOS version availability**: Uses `MAC_OS_X_VERSION_MIN_REQUIRED` to detect when building for macOS < 10.14
2. **Define compatibility macro**: Introduces `MUMBLE_NO_AVAUTHORIZATION` when targeting older macOS versions
3. **Provide fallback implementations**: 
   - For `AudioInput::checkMacPermissions()`: Returns `true` (assumes permissions granted)
   - For main.cpp microphone permission requests: Skips the permission check entirely
4. **Conditional header includes**: Only includes AVFoundation headers when the APIs are available

**Files Modified**:
- `src/mumble/AudioInput.cpp`: Adds version checks and fallback permission method
- `src/mumble/AudioInput.h`: Conditional AVFoundation header inclusion
- `src/mumble/main.cpp`: Conditional microphone permission request code

**Result**:
- Enables successful builds on macOS 10.13 SDK
- Maintains full functionality on macOS 10.14+ (runtime availability checks still work)
- Provides reasonable fallback behavior for older macOS versions
- No functional changes for users running macOS 10.14+

This patch is essential for conda-forge macOS builds that target the 10.13 deployment target.
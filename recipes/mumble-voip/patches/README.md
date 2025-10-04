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

### 0002-fix-macos-implicit-int-float-conversion.patch
**Purpose**: Fixes implicit int-to-float conversion warning in TextToSpeech_macx.mm on macOS.

**Problem**: 
The TextToSpeech_macx.mm file contains code that triggers a compiler warning when `-Werror` is enabled:
```
TextToSpeech_macx.mm:138:48: error: implicit conversion from 'int' to 'float' may lose precision [-Werror,-Wimplicit-int-float-conversion]
  138 |                 [[m_synthesizerHelper synthesizer] setVolume:volume / 100.0f];
      |                                                              ^~~~~~ ~
```

**Solution**:
The patch explicitly casts the `volume` parameter to `float` before the division:
```objective-c
[[m_synthesizerHelper synthesizer] setVolume:(float)volume / 100.0f];
```

**Files Modified**:
- `src/mumble/TextToSpeech_macx.mm`: Line 138, explicit cast added

**Result**:
- Eliminates the implicit conversion warning that was being treated as an error
- Maintains the same functionality with explicit type conversion
- Allows the build to succeed with `-Werror` enabled

### 0003-fix-macos-updateentry-struct-initialization.patch
**Purpose**: Fixes aggregate initialization error with UpdateEntry struct on macOS.

**Problem**: 
The PluginUpdater.cpp file contains code that uses brace initialization with a struct that only has a default constructor. This triggers a compiler error on macOS:
```
PluginUpdater.cpp:48:18: error: no matching constructor for initialization of 'UpdateEntry'
   48 |                                         UpdateEntry entry = { plugin->getID(), updateURL, updateURL.fileName(), 0 };
      |                                                     ^       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

**Solution**:
The patch replaces the brace initialization with explicit member assignment:
```cpp
UpdateEntry entry;
entry.pluginID = plugin->getID();
entry.updateURL = updateURL;
entry.fileName = updateURL.fileName();
entry.redirects = 0;
```

**Files Modified**:
- `src/mumble/PluginUpdater.cpp`: Line 48, replaced brace initialization with member assignment

**Result**:
- Eliminates the compilation error on macOS while maintaining identical functionality
- Makes the code more explicit and portable across different compiler implementations
- Allows the build to succeed on macOS with strict aggregate initialization rules

### 0004-fix-macos-avcapturedevice-sdk-compatibility.patch
**Purpose**: Fixes macOS AVCaptureDevice API availability issues when building with older SDKs.

**Problem**: 
The CoreAudio.mm file uses `authorizationStatusForMediaType:` which was introduced in macOS 10.14, but the build might use an older SDK (like 10.13). The `@available()` check only prevents runtime execution on older systems, but doesn't prevent compilation errors when the API isn't available in the SDK:
```
CoreAudio.mm:503:28: error: 'authorizationStatusForMediaType:' is unavailable: not available on macOS
  503 |                 switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio])
      |                                          ^
```

**Solution**:
The patch adds both compile-time and runtime availability checks:
```objective-c
// Check if the API is available both at compile time and runtime
AVAuthorizationStatus authStatus;
if (__builtin_available(macOS 10.14, *) && 
    [AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
} else {
    // Fallback: assume permission is granted on older systems/SDKs
    return false;
}
```

**Files Modified**:
- `src/mumble/CoreAudio.mm`: Lines around 503, added compile-time availability checks with fallback behavior

**Result**:
- Allows compilation with older macOS SDKs while preserving modern API functionality when available
- Uses `__builtin_available` for compile-time checks and `respondsToSelector:` for runtime safety
- Provides graceful fallback for older SDK/system combinations
- Maintains full functionality on macOS 10.14+ while ensuring backward compatibility

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
2. **macOS**: Updated build target to 10.14 + implicit conversion fix patch + struct initialization fix patch + AVCaptureDevice SDK compatibility patch
3. **Linux**: No patches needed

This approach provides clean, maintainable builds with minimal source code modifications, targeting only the specific issues that cannot be resolved through configuration alone.
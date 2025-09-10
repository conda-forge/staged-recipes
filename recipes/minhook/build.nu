#!/usr/bin/env nu

# MinHook build script using nushell for cross-platform compatibility

print "🔨 MinHook build script starting..."

# Check environment variables
print $"📁 Current directory: (pwd)"
print $"📂 SRC_DIR: ($env.SRC_DIR)"
print $"📋 LIBRARY_PREFIX: ($env.LIBRARY_PREFIX)"
print $"📚 LIBRARY_LIB: ($env.LIBRARY_LIB)"
print $"📝 LIBRARY_INC: ($env.LIBRARY_INC)"

# Verify source directory exists
if not ($env.SRC_DIR | path exists) {
    print "❌ Error: SRC_DIR does not exist"
    exit 1
}

print "✅ Using native CMakeLists.txt from MinHook 1.3.4"

# Set build configuration
let build_type = "Release"

# Create and enter build directory
mkdir build
cd build

print "🔧 Configuring with CMake..."

# Show CMake version for debugging
let cmake_version = (^cmake --version | complete)
if $cmake_version.exit_code == 0 {
    print $"📋 CMake version: ($cmake_version.stdout | lines | first)"
} else {
    print "❌ Error: CMake not found or not working"
    exit 1
}

# Configure with CMake using native CMakeLists.txt
let cmake_result = (^cmake
    -G "Ninja"
    $"-DCMAKE_BUILD_TYPE=($build_type)"
    $"-DCMAKE_INSTALL_PREFIX=($env.LIBRARY_PREFIX)"
    "-DBUILD_SHARED_LIBS=OFF"
    $env.SRC_DIR
    | complete)

if $cmake_result.exit_code != 0 {
    print "❌ Error: CMake configuration failed"
    print $"📋 stdout: ($cmake_result.stdout)"
    print $"📋 stderr: ($cmake_result.stderr)"
    exit 1
}
print "✅ CMake configuration successful"

print "🏗️  Building with CMake..."

# Build
let build_result = (^cmake --build . --config $build_type | complete)

if $build_result.exit_code != 0 {
    print "❌ Error: CMake build failed"
    print $"📋 stdout: ($build_result.stdout)"
    print $"📋 stderr: ($build_result.stderr)"
    exit 1
}
print "✅ CMake build successful"

print "📦 Installing with CMake..."

# Install
let install_result = (^cmake --install . --config $build_type | complete)

if $install_result.exit_code != 0 {
    print "❌ Error: CMake install failed"
    print $"📋 stdout: ($install_result.stdout)"
    print $"📋 stderr: ($install_result.stderr)"
    exit 1
}
print "✅ CMake install successful"

# Rename library to standard name without architecture suffix
print "🔄 Checking for MinHook 1.3.4 library naming..."
let lib_x64 = ($env.LIBRARY_LIB | path join "minhook.x64.lib")
let lib_x32 = ($env.LIBRARY_LIB | path join "minhook.x32.lib")
let lib_standard = ($env.LIBRARY_LIB | path join "minhook.lib")

# MinHook 1.3.4 uses architecture-specific naming by default
if ($lib_x64 | path exists) {
    print "📝 Found x64 library, creating standard name alias"
    cp $lib_x64 $lib_standard
} else if ($lib_x32 | path exists) {
    print "📝 Found x32 library, creating standard name alias"
    cp $lib_x32 $lib_standard
} else {
    print "ℹ️  Checking if library exists with different naming scheme"
    let lib_files = (ls ($env.LIBRARY_LIB) | where name =~ minhook | get name)
    if ($lib_files | length) > 0 {
        print $"📋 Found MinHook libraries: ($lib_files)"
        # Use the first one found as the standard name
        let first_lib = ($lib_files | first)
        if $first_lib != $lib_standard {
            cp $first_lib $lib_standard
        }
    }
}

# Verify installation
print "🔍 Verifying installation..."

# Check for standard library name
if ($lib_standard | path exists) {
    print "✅ MinHook library (standard name) installed successfully"
    try {
        let lib_size = (ls $lib_standard | get size | first)
        print $"📋 Library size: ($lib_size)"
    } catch {
        print "📋 Library file found (size unavailable)"
    }
} else {
    # Check if any MinHook library exists
    let lib_files = (ls ($env.LIBRARY_LIB) | where name =~ minhook)
    if ($lib_files | length) > 0 {
        print "✅ MinHook library found with architecture-specific naming"
        $lib_files | each { |lib|
            print $"📋 Found: ($lib.name)"
        }
    } else {
        print "❌ Error: MinHook library not found after installation"
        print $"📋 Library directory contents: (ls ($env.LIBRARY_LIB) | get name)"
        exit 1
    }
}

let header_file = ($env.LIBRARY_INC | path join "MinHook.h")
if ($header_file | path exists) {
    print "✅ MinHook header installed successfully"
} else {
    print "❌ Error: MinHook header not found after installation"
    print $"📋 Include directory contents: (ls ($env.LIBRARY_INC) | get name)"
    exit 1
}

print "🎉 Build completed successfully!"

#!/usr/bin/env nu

# SPSCQueue build script using nushell for cross-platform compatibility

print "🔨 SPSCQueue build script starting..."

# Check environment variables
print $"📁 Current directory: (pwd)"
print $"📂 SRC_DIR: ($env.SRC_DIR)"
print $"🖥️  Platform: ($nu.os-info.name)"

# Verify source directory exists
if not ($env.SRC_DIR | path exists) {
    print "❌ Error: SRC_DIR does not exist"
    exit 1
}

# Replace CMakeLists.txt with conda-compatible version
let recipe_cmake = ($env.RECIPE_DIR | path join "CMakeLists.txt")
let target_cmake = "./CMakeLists.txt"

if ($recipe_cmake | path exists) {
    print "📝 Replacing CMakeLists.txt with conda-compatible version"
    cp $recipe_cmake $target_cmake
} else {
    print "❌ Error: Recipe CMakeLists.txt not found"
    exit 1
}

# Create and enter build directory
print "📁 Creating build directory..."
mkdir build
cd build

# Show CMake version for debugging
print "🔧 Configuring with CMake..."
let cmake_version = (^cmake --version | complete)
if $cmake_version.exit_code == 0 {
    print $"📋 CMake version: ($cmake_version.stdout | lines | first)"
} else {
    print "❌ Error: CMake not found or not working"
    exit 1
}

# Prepare CMake arguments based on platform
mut cmake_args = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_STANDARD=11"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-DBUILD_TESTING=OFF"
]

# Add platform-specific CMake arguments
if ($nu.os-info.name == "windows") {
    $cmake_args = ($cmake_args | append [
        "-GNinja"
        $"-DCMAKE_INSTALL_PREFIX=($env.LIBRARY_PREFIX)"
        $"-DCMAKE_INSTALL_LIBDIR=($env.LIBRARY_LIB)"
        $"-DCMAKE_INSTALL_INCLUDEDIR=($env.LIBRARY_INC)"
    ])
    print $"📋 LIBRARY_PREFIX: ($env.LIBRARY_PREFIX)"
    print $"📚 LIBRARY_LIB: ($env.LIBRARY_LIB)"
    print $"📝 LIBRARY_INC: ($env.LIBRARY_INC)"
} else {
    $cmake_args = ($cmake_args | append [
        "-GUnix Makefiles"
        $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
        $"-DCMAKE_INSTALL_LIBDIR=($env.PREFIX | path join "lib")"
        $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX | path join "include")"
    ])
    print $"📋 PREFIX: ($env.PREFIX)"
    print $"📚 LIB_DIR: ($env.PREFIX | path join "lib")"
    print $"📝 INC_DIR: ($env.PREFIX | path join "include")"
}

# Configure with CMake
$cmake_args = ($cmake_args | append $env.SRC_DIR)
let cmake_result = (^cmake ...$cmake_args | complete)

if $cmake_result.exit_code != 0 {
    print "❌ Error: CMake configuration failed"
    print $"📋 stdout: ($cmake_result.stdout)"
    print $"📋 stderr: ($cmake_result.stderr)"
    exit 1
}
print "✅ CMake configuration successful"

# Build (header-only, mainly for validation)
print "🏗️  Building with CMake..."
let build_result = (^cmake --build . --config "Release" | complete)

if $build_result.exit_code != 0 {
    print "❌ Error: CMake build failed"
    print $"📋 stdout: ($build_result.stdout)"
    print $"📋 stderr: ($build_result.stderr)"
    exit 1
}
print "✅ CMake build successful"

# Install headers
print "📦 Installing with CMake..."
let install_result = (^cmake --install . --config "Release" | complete)

if $install_result.exit_code != 0 {
    print "❌ Error: CMake install failed"
    print $"📋 stdout: ($install_result.stdout)"
    print $"📋 stderr: ($install_result.stderr)"
    exit 1
}
print "✅ CMake install successful"

# Verify installation
print "🔍 Verifying installation..."

let header_file = if ($nu.os-info.name == "windows") {
    ($env.LIBRARY_INC | path join "rigtorp" "SPSCQueue.h")
} else {
    ($env.PREFIX | path join "include" "rigtorp" "SPSCQueue.h")
}

if ($header_file | path exists) {
    print "✅ SPSCQueue header installed successfully"
    print $"📋 Header location: ($header_file)"
} else {
    print "❌ Error: SPSCQueue header not found after installation"
    print $"📋 Expected location: ($header_file)"

    # Debug: show what was actually installed
    let include_base = if ($nu.os-info.name == "windows") {
        $env.LIBRARY_INC
    } else {
        ($env.PREFIX | path join "include")
    }

    if ($include_base | path exists) {
        print $"📋 Include directory contents: (ls ($include_base) | get name)"

        let rigtorp_dir = ($include_base | path join "rigtorp")
        if ($rigtorp_dir | path exists) {
            print $"📋 rigtorp directory contents: (ls ($rigtorp_dir) | get name)"
        }
    }
    exit 1
}

print "🎉 SPSCQueue build completed successfully!"

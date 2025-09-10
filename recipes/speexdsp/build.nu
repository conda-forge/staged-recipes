#!/usr/bin/env nu

# SpeexDSP simplified build script for rattler-build

def main [] {
    match $nu.os-info.name {
        "windows" => {
            build_windows_cmake
        }
        _ => {
            build_unix_autotools
        }
    }
}

def build_unix_autotools [] {
    # Generate configure script
    ^sh -c "./autogen.sh"

    # Configure and build
    let configure_args = [
        $"--prefix=($env.PREFIX)"
        "--disable-static"
        "--enable-shared"
        "--disable-examples"
        "--enable-sse"
        "--enable-fixed-point"
    ]

    ^./configure ...$configure_args
    ^make $"-j($env.CPU_COUNT? | default "4")"
    ^make install
}

def build_windows_cmake [] {
    print "🔨 Building SpeexDSP audio processing library..."
    print "🪟 Building on Windows with CMake + MSVC..."

    # Copy recipe CMake files
    print "📝 Copying CMakeLists.txt from recipe..."
    cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "./CMakeLists.txt"
    print "📝 Copying cmake directory from recipe..."
    cp -r ($env.RECIPE_DIR | path join "cmake") "./cmake"

    # Create build directory
    print "📁 Creating build directory..."
    mkdir build
    cd build

    # Configure and build with CMake
    print "🔧 Configuring with CMake..."
    let cmake_version_output = (^cmake --version | str trim)
    print $"📋 CMake version: ($cmake_version_output | lines | first)"
    print $"📋 LIBRARY_PREFIX: ($env.PREFIX)\\Library"
    print $"📚 LIBRARY_LIB: ($env.PREFIX)\\Library\\lib"
    print $"📝 LIBRARY_INC: ($env.PREFIX)\\Library\\include"
    print $"🔧 LIBRARY_BIN: ($env.PREFIX)\\Library\\bin"

    let cmake_args = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=ON"
        "-DENABLE_SSE=ON"
        "-DENABLE_FIXED_POINT=OFF"
        "-DENABLE_FLOAT_API=ON"
        "-DBUILD_EXAMPLES=OFF"
        "-GNinja"
        $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)\\Library"
        $"-DCMAKE_INSTALL_LIBDIR=($env.PREFIX)\\Library\\lib"
        $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX)\\Library\\include"
        $"-DCMAKE_INSTALL_BINDIR=($env.PREFIX)\\Library\\bin"
        $env.SRC_DIR
    ]

    print $"📋 CMake args: (($cmake_args | str join ' '))"

    print "🔍 Checking FFT configuration..."
    print "📋 Expected FFT defines: USE_KISS_FFT, HAVE_KISS_FFT, HAVE_CONFIG_H"
    print "📋 Config header will be generated at: build/config.h"

    try {
        ^cmake ...$cmake_args
        print "✅ CMake configuration successful"
    } catch {
        print "❌ Error: CMake configuration failed"
        exit 1
    }

    print "🏗️  Building with CMake..."
    print "🔍 Building with FFT implementation: KissFFT (USE_KISS_FFT=1)"
    try {
        ^cmake --build . --config Release
        print "✅ CMake build successful"
    } catch { |e|
        print "❌ Error: CMake build failed"
        print "🔍 FFT configuration issue - checking if USE_KISS_FFT is properly defined"
        if ($e | get -o "stdout") != null {
            print $"📋 stdout: ($e.stdout)"
        }
        if ($e | get -o "stderr") != null {
            print $"📋 stderr: ($e.stderr)"
        }
        exit 1
    }

    print "📦 Installing with CMake..."
    try {
        ^cmake --install . --config Release
        print "✅ CMake install successful"
    } catch {
        print "❌ Error: CMake install failed"
        exit 1
    }

    print "🔍 Verifying installation..."
    print $"PREFIX environment variable: ($env.PREFIX)"
    print $"LIBRARY_PREFIX environment variable: ($env.PREFIX)\\Library"
    print $"LIBRARY_INC environment variable: ($env.PREFIX)\\Library\\include"
    print "OS: windows"

    print $"Looking for library at: ($env.PREFIX)\\Library\\lib/speexdsp.lib"
    print $"Looking for header at: ($env.PREFIX)\\Library\\include/speex/speex_preprocess.h"

    print $"Contents of ($env.PREFIX)\\Library\\lib:"
    (ls ($env.PREFIX + "\\Library\\lib") | each { |file| print $"  ($env.PREFIX)\\Library\\lib\\($file.name)" })

    print $"Contents of ($env.PREFIX)\\Library\\include:"
    (ls ($env.PREFIX + "\\Library\\include") | each { |file| print $"  ($env.PREFIX)\\Library\\include\\($file.name)" })

    if (($env.PREFIX + "\\Library\\include\\speex") | path exists) {
        print $"Contents of ($env.PREFIX)\\Library\\include/speex:"
        (ls ($env.PREFIX + "\\Library\\include\\speex") | each { |file| print $"  ($env.PREFIX)\\Library\\include\\speex\\($file.name)" })
    }

    print "✓ SpeexDSP installed successfully"
    print $"  Library: ($env.PREFIX)\\Library\\lib/speexdsp.lib"
    print $"  Headers: ($env.PREFIX)\\Library\\include/speex/speex_preprocess.h"
}

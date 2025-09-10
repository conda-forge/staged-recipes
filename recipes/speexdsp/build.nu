#!/usr/bin/env nu

# SpeexDSP nushell build script
# Combines Unix and Windows build logic

def main [] {
    print "Building SpeexDSP audio processing library..."

    match $nu.os-info.name {
        "windows" => {
            build_windows
        }
        _ => {
            build_unix
        }
    }

    # Verify installation
    verify_installation
}

def build_unix [] {
    print "Building on Unix system..."

    # Run autogen to generate configure script
    print "Running autogen.sh..."
    ^sh -c "./autogen.sh"

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "autogen.sh failed"}
    }

    # Configure SpeexDSP
    let prefix_path = $env.PREFIX
    print "Configuring with autotools..."
    print $"Using prefix path: ($prefix_path)"
    # Add verbose flags and ensure proper environment
    let configure_args = [
        $"--prefix=($prefix_path)"
        "--disable-static"
        "--enable-shared"
        "--disable-examples"
        "--enable-sse"
        "--enable-fixed-point"
        "--enable-silent-rules=no"
    ]

    print $"Configure args: ($configure_args | str join ' ')"
    ^./configure ...$configure_args

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Configure failed"}
    }

    # Build with parallel jobs and verbose output
    let cpu_count = ($env.CPU_COUNT? | default "4")
    print $"Building with ($cpu_count) parallel jobs..."
    ^make $"-j($cpu_count)" "V=1"

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Build failed"}
    }

    # Install
    print "Installing..."
    ^make install

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Installation failed"}
    }
}

def build_windows [] {
    print "Building on Windows using MSYS2/MinGW..."

    # Set up MSYS2 environment
    $env.MSYSTEM = "MINGW64"
    $env.PATH = ($env.PATH | split row (char esep) | prepend [$"($env.PREFIX)/Library/usr/bin", $"($env.PREFIX)/Library/mingw-w64/bin"] | str join (char esep))

    # Run autotools configuration
    print "Running autogen.sh..."
    ^bash -c "./autogen.sh"

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "autogen.sh failed"}
    }

    # Configure with MinGW
    let prefix_unix = ($env.PREFIX | str replace -a '\\' '/')
    print "Configuring with autotools..."
    print $"Using prefix path: ($prefix_unix)"
    let configure_args = ["./configure" $"--prefix=($prefix_unix)" "--disable-static" "--enable-shared" "--build=x86_64-w64-mingw32"]
    ^bash -c ($configure_args | str join " ")

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Configure failed"}
    }

    # Build
    let cpu_count = ($env.CPU_COUNT? | default "4")
    print $"Building with ($cpu_count) parallel jobs..."
    ^bash -c $"make -j($cpu_count)"

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Build failed"}
    }

    # Install
    print "Installing..."
    ^bash -c "make install"

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Installation failed"}
    }
}

def verify_installation [] {
    print "Verifying installation..."

    match $nu.os-info.name {
        "windows" => {
            let lib_path = $"($env.PREFIX)/Library/lib/speexdsp.lib"
            let header_path = $"($env.PREFIX)/Library/include/speex/speex_preprocess.h"

            if not ($lib_path | path exists) {
                error make {msg: $"ERROR: SpeexDSP library not found at ($lib_path)"}
            }

            if not ($header_path | path exists) {
                error make {msg: $"ERROR: SpeexDSP headers not found at ($header_path)"}
            }

            print "✓ SpeexDSP installed successfully on Windows"
            print $"  Library: ($lib_path)"
            print $"  Headers: ($header_path)"
        }
        _ => {
            let shlib_ext = match $nu.os-info.name {
                "macos" => ".dylib"
                _ => ".so"
            }

            let lib_path = $"($env.PREFIX)/lib/libspeexdsp($shlib_ext)"
            let header_path = $"($env.PREFIX)/include/speex/speex_preprocess.h"
            let pkgconfig_path = $"($env.PREFIX)/lib/pkgconfig/speexdsp.pc"

            if not ($lib_path | path exists) {
                error make {msg: $"ERROR: SpeexDSP library not found at ($lib_path)"}
            }

            if not ($header_path | path exists) {
                error make {msg: $"ERROR: SpeexDSP headers not found at ($header_path)"}
            }

            if not ($pkgconfig_path | path exists) {
                error make {msg: $"ERROR: SpeexDSP pkg-config file not found at ($pkgconfig_path)"}
            }

            print "✓ SpeexDSP installed successfully on Unix"
            print $"  Library: ($lib_path)"
            print $"  Headers: ($header_path)"
            print $"  Pkg-config: ($pkgconfig_path)"
        }
    }
}

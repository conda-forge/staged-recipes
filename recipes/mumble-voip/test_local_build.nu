#!/usr/bin/env nu

# Local Build Testing Script for mumble-voip
# This script helps developers test the build configuration locally

def main [] {
    print "=== Mumble VoIP Local Build Test ==="
    print ""

    # Check prerequisites
    print "Checking prerequisites..."

    let cmake_available = (try { ^cmake --version | ignore; true } catch { false })
    let ninja_available = (try { ^ninja --version | ignore; true } catch { false })
    let git_available = (try { ^git --version | ignore; true } catch { false })
    let nushell_available = true  # We're running this script, so nushell is available

    print $"✓ CMake: ($cmake_available)"
    print $"✓ Ninja: ($ninja_available)"
    print $"✓ Git: ($git_available)"
    print $"✓ Nushell: ($nushell_available)"

    if not $cmake_available {
        print "❌ CMake is required but not found"
        exit 1
    }

    print ""
    print "=== Environment Check ==="

    # Check if we're in a conda environment
    let conda_env = ($env.CONDA_DEFAULT_ENV? | default "none")
    let prefix = ($env.PREFIX? | default "none")

    if $prefix != "none" {
        print $"✓ Conda environment detected: ($prefix)"
        print $"  Environment name: ($conda_env)"
    } else {
        print "⚠ No conda environment detected (PREFIX not set)"
        print "  This test will show what happens without conda dependencies"
    }

    print ""
    print "=== Recipe Configuration Test ==="

    # Validate recipe.yaml exists and has required content
    if ("recipe.yaml" | path exists) {
        print "✓ recipe.yaml found"
        let recipe_content = (open recipe.yaml | to text)

        # Check for system dependencies
        let system_deps = [
            "soci-core"
            "nlohmann_json"
            "spdlog"
            "utfcpp"
            "boost"
            "protobuf"
            "openssl"
        ]

        print "Required system dependencies:"
        for dep in $system_deps {
            if ($recipe_content | str contains $dep) {
                print $"  ✓ ($dep)"
            } else {
                print $"  ❌ ($dep) - missing from recipe"
            }
        }
    } else {
        print "❌ recipe.yaml not found"
        exit 1
    }

    print ""
    print "=== CMake Configuration Test ==="

    # Run our validation script if it exists
    if ("validate_cmake.nu" | path exists) {
        print "Running CMake validation..."
        try {
            ^nu validate_cmake.nu
        } catch { |err|
            print $"CMake validation had issues: ($err.msg)"
        }
    } else {
        print "⚠ validate_cmake.nu not found - skipping detailed CMake validation"
    }

    print ""
    print "=== Mock Build Test ==="

    # Create a test environment to see what would happen during build
    let test_dir = "local_build_test"

    if ($test_dir | path exists) {
        rm -rf $test_dir
    }

    mkdir $test_dir
    cd $test_dir

    print "Setting up mock source directory structure..."
    mkdir src/mumble

    # Copy CMake configuration files
    if ("../cmake_system_libs.cmake" | path exists) {
        cp ../cmake_system_libs.cmake .
        print "✓ Copied cmake_system_libs.cmake"
    }

    if ("../conda_toolchain.cmake" | path exists) {
        cp ../conda_toolchain.cmake .
        print "✓ Copied conda_toolchain.cmake"
    }

    # Create a minimal CMakeLists.txt that mimics mumble's structure
    let mock_cmake = "cmake_minimum_required(VERSION 3.16)
project(mumble_mock LANGUAGES C CXX)

# Include our system library configuration
include(conda_toolchain.cmake)
include(cmake_system_libs.cmake)

# Test that we can at least configure without errors
message(STATUS \"Mock mumble configuration test\")
message(STATUS \"This would be where mumble's real CMakeLists.txt content goes\")

# Create a simple executable to test linking
add_executable(mumble_test_dummy dummy.cpp)
"

    $mock_cmake | save CMakeLists.txt

    # Create dummy source file
    let dummy_cpp = "#include <iostream>
int main() {
    std::cout << \"Mock mumble build test\" << std::endl;
    return 0;
}
"
    $dummy_cpp | save dummy.cpp

    print "Running mock CMake configuration..."
    let cmake_result = (try {
        let output = (^cmake -B build -G Ninja . | str trim)
        {success: true, output: $output}
    } catch { |err|
        {success: false, output: $err.msg}
    })

    if $cmake_result.success {
        print "✓ Mock CMake configuration succeeded"
        print "Key messages from configuration:"
        let output_lines = ($cmake_result.output | lines)

        # Filter for important lines using separate filters
        let found_lines = ($output_lines | where {|line| $line | str contains "Found"})
        let warning_lines = ($output_lines | where {|line| $line | str contains "Warning"})
        let error_lines = ($output_lines | where {|line| $line | str contains "Error"})
        let path_lines = ($output_lines | where {|line| ($line | str contains "CMAKE_PREFIX_PATH") or ($line | str contains "PKG_CONFIG_PATH")})

        # Combine and take first 15
        let all_important = ($found_lines | append $warning_lines | append $error_lines | append $path_lines | take 15)

        for line in $all_important {
            print $"  ($line)"
        }

        # Try to build the dummy executable
        print ""
        print "Attempting to build dummy executable..."
        let build_result = (try {
            ^cmake --build build
            true
        } catch {
            false
        })

        if $build_result {
            print "✓ Mock build succeeded"
        } else {
            print "❌ Mock build failed (this may be expected without all dependencies)"
        }

    } else {
        print "❌ Mock CMake configuration failed:"
        print $"  ($cmake_result.output)"
    }

    # Cleanup
    cd ..
    rm -rf $test_dir

    print ""
    print "=== Build Script Preparation Test ==="

    # Test that our build scripts would be able to run
    let build_scripts = ["build-client.nu", "build-server.nu"]

    for script in $build_scripts {
        if ($script | path exists) {
            print $"✓ ($script) exists"

            # Check that the script has the new configuration
            let script_content = (open $script)
            let has_cmake_config = ($script_content | str contains "cmake_system_libs.cmake")
            let has_toolchain = ($script_content | str contains "conda_toolchain.cmake")
            let has_bundled_off = ($script_content | str contains "bundled-json=OFF")
            let has_speexdsp_off = ($script_content | str contains "bundled-speexdsp=OFF")

            print $"  CMake config inclusion: ($has_cmake_config)"
            print $"  Toolchain inclusion: ($has_toolchain)"
            print $"  Bundled libraries disabled: ($has_bundled_off)"
            print $"  SpeexDSP bundled disabled: ($has_speexdsp_off)"

            if ($has_cmake_config and $has_toolchain and $has_bundled_off) {
                print $"  ✅ ($script) is properly configured for system libraries"
            } else {
                print $"  ⚠ ($script) may need updates"
            }
        } else {
            print $"❌ ($script) not found"
        }
    }

    print ""
    print "=== Next Steps ==="
    print ""
    print "To test with actual mumble source and dependencies:"
    print "1. Set up a conda environment with build dependencies:"
    print "   conda create -n mumble-test cmake ninja boost protobuf openssl qt"
    print ""
    print "2. Install system libraries:"
    print "   conda install -n mumble-test soci-core nlohmann_json spdlog utfcpp"
    print ""
    print "3. Run the actual build test:"
    print "   AZURE=True pixi run python ../../build-locally.py linux64"
    print ""
    print "4. Or test individual components:"
    print "   pixi run rattler-build build --recipe-dir . --target-platform linux-64"
    print ""
    print "=== Local Build Test Complete ==="

    if $cmake_result.success {
        print "✅ Configuration looks good for conda-forge build"
    } else {
        print "⚠ Some issues detected - review output above"
    }
}

#!/usr/bin/env nu

# CMake Configuration Validation Script for mumble-voip
# Tests the CMake configuration files for syntax and basic functionality

def main [] {
    print "=== Mumble VoIP CMake Configuration Validation ==="
    print ""

    # Check if CMake is available
    let cmake_available = (try {
        ^cmake --version | ignore
        true
    } catch {
        false
    })

    if not $cmake_available {
        print "❌ CMake not found - cannot validate configuration"
        exit 1
    }

    let cmake_version = (^cmake --version | head -1 | str trim)
    print $"✓ CMake available: ($cmake_version)"

    # Check if configuration files exist
    let config_files = [
        "cmake_system_libs.cmake"
        "conda_toolchain.cmake"
    ]

    mut all_files_exist = true
    for file in $config_files {
        if ($file | path exists) {
            print $"✓ Found: ($file)"
        } else {
            print $"❌ Missing: ($file)"
            $all_files_exist = false
        }
    }

    if not $all_files_exist {
        print ""
        print "❌ Some CMake configuration files are missing"
        exit 1
    }

    print ""
    print "=== Testing conda_toolchain.cmake ==="

    # Test conda toolchain
    let toolchain_result = (try {
        let output = (^cmake -P conda_toolchain.cmake | str trim)
        {success: true, output: $output}
    } catch { |err|
        {success: false, output: $err.msg}
    })

    if $toolchain_result.success {
        print "✓ conda_toolchain.cmake syntax validation passed"
        print "Output preview:"
        let lines = ($toolchain_result.output | lines | take 5)
        for line in $lines {
            print $"  ($line)"
        }
    } else {
        print "❌ conda_toolchain.cmake validation failed:"
        print $"  Error: ($toolchain_result.output)"
    }

    print ""
    print "=== Testing cmake_system_libs.cmake ==="

    # Test system libraries configuration
    let syslibs_result = (try {
        let output = (^cmake -P cmake_system_libs.cmake | str trim)
        {success: true, output: $output}
    } catch { |err|
        {success: false, output: $err.msg}
    })

    if $syslibs_result.success {
        print "✓ cmake_system_libs.cmake syntax validation passed"
        print "Library detection summary:"
        let lines = ($syslibs_result.output | lines)

        # Look for status messages about libraries
        let status_lines = ($lines | where {|line| $line =~ "Found|not found"} | take 10)
        for line in $status_lines {
            print $"  ($line)"
        }

        if ($status_lines | length) == 0 {
            print "  (No library status messages found - this may be normal in test environment)"
        }
    } else {
        print "❌ cmake_system_libs.cmake validation failed:"
        print $"  Error: ($syslibs_result.output)"
    }

    print ""
    print "=== Testing Combined Configuration ==="

    # Test both configurations together in a minimal CMake project
    let test_dir = "cmake_test_temp"
    mkdir $test_dir

    # Create minimal CMakeLists.txt for testing
    let test_cmake_content = "cmake_minimum_required(VERSION 3.16)
project(mumble_test)

# Include our configurations
include(../conda_toolchain.cmake)
include(../cmake_system_libs.cmake)

message(STATUS \"Combined configuration test completed successfully\")
"

    $test_cmake_content | save $"($test_dir)/CMakeLists.txt"

    let combined_result = (try {
        cd $test_dir
        let output = (^cmake . | str trim)
        cd ..
        {success: true, output: $output}
    } catch { |err|
        cd ..
        {success: false, output: $err.msg}
    })

    # Cleanup test directory
    rm -rf $test_dir

    if $combined_result.success {
        print "✓ Combined configuration test passed"

        # Show key messages from output
        let output_lines = ($combined_result.output | lines)
        let config_messages = ($output_lines | where {|line| $line =~ "Found|Warning|Error"} | take 10)
        if ($config_messages | length) > 0 {
            print "Key configuration messages:"
            for line in $config_messages {
                print $"  ($line)"
            }
        }
    } else {
        print "❌ Combined configuration test failed:"
        print $"  Error: ($combined_result.output)"
    }

    print ""
    print "=== Build Script Validation ==="

    # Check build scripts exist and basic syntax
    let build_scripts = [
        "build-client.nu"
        "build-server.nu"
    ]

    for script in $build_scripts {
        if ($script | path exists) {
            print $"✓ Found: ($script)"

            # Basic content check
            let content = (open $script)
            if ($content | str contains "cmake_system_libs.cmake") and ($content | str contains "conda_toolchain.cmake") {
                print $"  ✓ Script references CMake configuration files"
            } else {
                print $"  ⚠ Script may not be using new CMake configuration"
            }
        } else {
            print $"❌ Missing: ($script)"
        }
    }

    print ""
    print "=== Recipe Configuration Check ==="

    # Check recipe.yaml for system dependencies
    if ("recipe.yaml" | path exists) {
        print "✓ Found: recipe.yaml"

        let recipe_content = (open recipe.yaml | to text)

        # Check for key system dependencies
        let system_deps = [
            "soci-core"
            "nlohmann_json"
            "spdlog"
            "utfcpp"
            "speexdsp"
        ]

        print "System dependency check:"
        for dep in $system_deps {
            if ($recipe_content | str contains $dep) {
                print $"  ✓ ($dep) found in recipe"
            } else {
                print $"  ⚠ ($dep) not found in recipe"
            }
        }

        # Check for bundled source removals
        if ($recipe_content | str contains "Use system SOCI library") {
            print "  ✓ SOCI bundled source commented out"
        } else {
            print "  ⚠ SOCI bundled source status unclear"
        }

    } else {
        print "❌ Missing: recipe.yaml"
    }

    print ""
    print "=== Validation Summary ==="

    let validations = [
        {name: "CMake availability", status: $cmake_available}
        {name: "Configuration files exist", status: $all_files_exist}
        {name: "Toolchain syntax", status: $toolchain_result.success}
        {name: "System libs syntax", status: $syslibs_result.success}
        {name: "Combined configuration", status: $combined_result.success}
    ]

    let passed = ($validations | where status == true | length)
    let total = ($validations | length)

    print $"Passed: ($passed)/($total) validations"

    if $passed == $total {
        print "✅ All validations passed - CMake configuration is ready for testing"
        exit 0
    } else {
        print "❌ Some validations failed - review issues above"
        let failed_validations = ($validations | where status == false)
        print "Failed validations:"
        for validation in $failed_validations {
            print $"  - ($validation.name)"
        }
        exit 1
    }
}

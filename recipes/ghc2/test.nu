#!/usr/bin/env nu

# Test script for GHC installation
#
# This script performs comprehensive testing of a GHC (Glasgow Haskell Compiler) installation
# to verify that all components are properly installed and functional.
#
# Usage: test.nu [--debug]
#
# Options:
#   --debug    Report errors but don't fail the test. When this flag is used,
#              the script will continue running even if tests fail, allowing
#              you to see all issues at once. Without this flag (default behavior),
#              the script will exit immediately on the first test failure.
#
# Tests performed:
#   1. GHC binary existence and executability
#   2. GHC version verification
#   3. GHC help command functionality
#   4. Basic Haskell compilation and execution
#   5. GHCi (interactive mode) startup
#   6. ghc-pkg package manager functionality
#   7. runghc script execution
#   8. GHC numeric version output
#
# Environment variables used:
#   PREFIX      - Installation prefix where GHC binaries are located
#   PKG_VERSION - Expected GHC version to validate against

def main [--debug] {
    let debug_mode = ($debug | default false)

    if $debug_mode {
        print "Running in debug mode - errors will be reported but not fail the test"
    }

    print "Starting GHC tests..."
    print $"PREFIX: ($env.PREFIX)"
    print ""

    let tests = [
        {
            name: "GHC binary existence"
            test: {
                let ghc_path = ($env.PREFIX | path join "bin" "ghc")
                if not ($ghc_path | path exists) {
                    error make { msg: $"GHC binary not found at ($ghc_path)" }
                }
                if not (ls -l $ghc_path | get 0.permissions | str contains "x") {
                    error make { msg: $"GHC binary is not executable: ($ghc_path)" }
                }
            }
        }
        {
            name: "GHC version check"
            test: {
                let version_output = (^($env.PREFIX | path join "bin" "ghc") --version | complete)
                if $version_output.exit_code != 0 {
                    error make { msg: $"GHC version command failed: ($version_output.stderr)" }
                }

                let expected_version = $env.PKG_VERSION
                if not ($version_output.stdout | str contains $expected_version) {
                    error make { msg: $"Version mismatch. Expected ($expected_version), got: ($version_output.stdout)" }
                }
            }
        }
        {
            name: "GHC help command"
            test: {
                let help_output = (^($env.PREFIX | path join "bin" "ghc") --help | complete)
                if $help_output.exit_code != 0 {
                    error make { msg: $"GHC help command failed: ($help_output.stderr)" }
                }
                if not ($help_output.stdout | str contains "Usage:") {
                    error make { msg: "GHC help output doesn't contain expected content" }
                }
            }
        }
        {
            name: "Basic Haskell compilation"
            test: {
                # Create a simple test program
                let test_file = "test_hello.hs"
                'main = putStrLn "Hello from GHC!"' | save $test_file

                # Compile the program
                let compile_output = (^($env.PREFIX | path join "bin" "ghc") $test_file -o test_hello | complete)
                if $compile_output.exit_code != 0 {
                    error make { msg: $"Compilation failed: ($compile_output.stderr)" }
                }

                # Check if executable was created
                if not ("test_hello" | path exists) {
                    error make { msg: "Compiled executable not found" }
                }

                # Run the executable
                let run_output = (./test_hello | complete)
                if $run_output.exit_code != 0 {
                    error make { msg: $"Execution failed: ($run_output.stderr)" }
                }

                if not ($run_output.stdout | str contains "Hello from GHC!") {
                    error make { msg: $"Unexpected output: ($run_output.stdout)" }
                }

                # Clean up
                rm -f $test_file test_hello
                # Also remove any .hi or .o files
                rm -f test_hello.hi test_hello.o
            }
        }
        {
            name: "GHCi interactive mode"
            test: {
                let ghci_path = ($env.PREFIX | path join "bin" "ghci")
                if not ($ghci_path | path exists) {
                    error make { msg: $"GHCi binary not found at ($ghci_path)" }
                }

                # Test that GHCi can start and evaluate a simple expression
                let ghci_output = (echo ":quit" | ^$ghci_path | complete)
                if $ghci_output.exit_code != 0 {
                    error make { msg: $"GHCi failed to start: ($ghci_output.stderr)" }
                }
            }
        }
        {
            name: "ghc-pkg package manager"
            test: {
                let ghc_pkg_path = ($env.PREFIX | path join "bin" "ghc-pkg")
                if not ($ghc_pkg_path | path exists) {
                    error make { msg: $"ghc-pkg binary not found at ($ghc_pkg_path)" }
                }

                let pkg_output = (^$ghc_pkg_path list | complete)
                if $pkg_output.exit_code != 0 {
                    error make { msg: $"ghc-pkg list failed: ($pkg_output.stderr)" }
                }

                # Should contain at least base package
                if not ($pkg_output.stdout | str contains "base") {
                    error make { msg: "ghc-pkg doesn't show base package" }
                }
            }
        }
        {
            name: "runghc script runner"
            test: {
                let runghc_path = ($env.PREFIX | path join "bin" "runghc")
                if not ($runghc_path | path exists) {
                    error make { msg: $"runghc binary not found at ($runghc_path)" }
                }

                # Create a simple script
                let script_file = "test_script.hs"
                'main = putStrLn "Hello from runghc!"' | save $script_file

                let script_output = (^$runghc_path $script_file | complete)
                if $script_output.exit_code != 0 {
                    error make { msg: $"runghc failed: ($script_output.stderr)" }
                }

                if not ($script_output.stdout | str contains "Hello from runghc!") {
                    error make { msg: $"Unexpected runghc output: ($script_output.stdout)" }
                }

                # Clean up
                rm -f $script_file
            }
        }
        {
            name: "GHC numeric version"
            test: {
                let numeric_output = (^($env.PREFIX | path join "bin" "ghc") --numeric-version | complete)
                if $numeric_output.exit_code != 0 {
                    error make { msg: $"GHC numeric version command failed: ($numeric_output.stderr)" }
                }

                let expected_version = $env.PKG_VERSION
                let numeric_version = ($numeric_output.stdout | str trim)
                if $numeric_version != $expected_version {
                    error make { msg: $"Numeric version mismatch. Expected ($expected_version), got: ($numeric_version)" }
                }
            }
        }
    ]

    let test_count = ($tests | length)

    # Run all tests and collect results
    let results = ($tests | enumerate | each { |item|
        let test = $item.item
        let test_num = $item.index + 1
        print $"Running test ($test_num): ($test.name)"

        try {
            do $test.test
            print $"✓ ($test.name) - PASSED"
            {name: $test.name, status: "passed", error: null}
        } catch { |error|
            print $"✗ ($test.name) - FAILED: ($error.msg)"

            if not $debug_mode {
                print $"Test failed: ($test.name)"
                exit 1
            }
            {name: $test.name, status: "failed", error: $error.msg}
        }
    })

    let error_count = ($results | where status == "failed" | length)

    # Summary
    print ""
    print "Test Summary:"
    print $"Total tests: ($test_count)"
    print $"Errors: ($error_count)"

    if $error_count > 0 {
        if $debug_mode {
            print $"⚠️  ($error_count) test(s) failed, but continuing due to debug mode"
            print "GHC installation has issues but test continues"
        } else {
            print $"❌ ($error_count) test(s) failed"
            exit 1
        }
    } else {
        print "✅ All tests passed!"
        print "GHC installation verified successfully!"
    }
}

#!/usr/bin/env python3
"""Test: cppo functional tests

Tests cppo C preprocessor functionality:
- Conditional compilation (#ifdef/#else/#endif)
- Macro expansion (#define)
- Include files (#include)
- Macros with arguments
- Command-line defines (-D)
"""

import os
import shutil
import subprocess
import sys
import tempfile


def write_file(path, content):
    """Write content to file."""
    with open(path, "w") as f:
        f.write(content)


def read_file(path):
    """Read file content."""
    with open(path, "r") as f:
        return f.read()


def run_cppo(input_file, output_file, extra_args=None):
    """Run cppo and return success status."""
    cmd = ["cppo", "-n", input_file, "-o", output_file]
    if extra_args:
        cmd = ["cppo", "-n"] + extra_args + [input_file, "-o", output_file]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def main():
    print("=== cppo Functional Tests ===")

    errors = 0
    test_dir = tempfile.mkdtemp(prefix="cppo_test_")
    original_dir = os.getcwd()

    try:
        os.chdir(test_dir)

        # Test 1: Conditional compilation
        print("\nTest 1: Conditional compilation")
        write_file(
            "test1.mlp",
            """#define FEATURE_X
#ifdef FEATURE_X
let feature_x = true
#else
let feature_x = false
#endif
""",
        )
        if run_cppo("test1.mlp", "test1.ml"):
            content = read_file("test1.ml")
            if "feature_x = true" in content and "feature_x = false" not in content:
                print("  [OK]")
            else:
                print("  [FAIL] Wrong output")
                print(f"  Content: {content}")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

        # Test 2: Macro expansion
        print("\nTest 2: Macro expansion")
        write_file(
            "test2.mlp",
            """#define VERSION "1.0.0"
let version = VERSION
""",
        )
        if run_cppo("test2.mlp", "test2.ml"):
            content = read_file("test2.ml")
            if '"1.0.0"' in content:
                print("  [OK]")
            else:
                print("  [FAIL] Macro not expanded")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

        # Test 3: Include files
        print("\nTest 3: Include files")
        write_file("common.mlp", "let common_value = 42\n")
        write_file(
            "test3.mlp",
            """#include "common.mlp"
let use_common = common_value + 1
""",
        )
        if run_cppo("test3.mlp", "test3.ml"):
            content = read_file("test3.ml")
            if "common_value = 42" in content:
                print("  [OK]")
            else:
                print("  [FAIL] Include not processed")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

        # Test 4: Macros with arguments
        print("\nTest 4: Macros with arguments")
        write_file(
            "test4.mlp",
            """#define MAX(a,b) if a > b then a else b
let max_value = MAX(10, 20)
""",
        )
        if run_cppo("test4.mlp", "test4.ml"):
            content = read_file("test4.ml")
            if "max_value" in content and "10" in content and "20" in content:
                print("  [OK]")
            else:
                print("  [FAIL] Macro expansion failed")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

        # Test 5: Undefined conditional
        print("\nTest 5: Undefined conditional")
        write_file(
            "test5.mlp",
            """#ifdef UNDEFINED
let undefined_feature = true
#else
let undefined_feature = false
#endif
""",
        )
        if run_cppo("test5.mlp", "test5.ml"):
            content = read_file("test5.ml")
            if "undefined_feature = false" in content:
                print("  [OK]")
            else:
                print("  [FAIL] Wrong branch taken")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

        # Test 6: Command-line define
        print("\nTest 6: Command-line define")
        write_file(
            "test6.mlp",
            """#ifdef CLI_DEFINE
let from_cli = true
#else
let from_cli = false
#endif
""",
        )
        if run_cppo("test6.mlp", "test6.ml", ["-D", "CLI_DEFINE"]):
            content = read_file("test6.ml")
            if "from_cli = true" in content:
                print("  [OK]")
            else:
                print("  [FAIL] -D not processed")
                errors += 1
        else:
            print("  [FAIL] cppo failed")
            errors += 1

    finally:
        os.chdir(original_dir)
        shutil.rmtree(test_dir, ignore_errors=True)

    if errors > 0:
        print(f"\n=== FAILED: {errors} error(s) ===")
        return 1

    print("\n=== All cppo functional tests passed ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())

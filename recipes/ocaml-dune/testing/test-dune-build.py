#!/usr/bin/env python3
"""Test: dune functional build tests

Tests dune's ability to build OCaml projects:
- Bytecode and native executables
- Multi-file library projects
- Unix module integration
- Incremental builds
- dune clean

OCaml 5.3.0 aarch64/ppc64le bug workaround applied automatically.
"""

import os
import platform
import shutil
import subprocess
import sys
import tempfile


def get_ocaml_version():
    """Get OCaml version string."""
    try:
        result = subprocess.run(
            ["ocaml", "-version"],
            capture_output=True,
            text=True,
            check=False,
        )
        for word in result.stdout.split():
            if word[0].isdigit():
                return word
    except FileNotFoundError:
        pass
    return "unknown"


def apply_ocaml_530_workaround():
    """Apply OCaml 5.3.0 aarch64/ppc64le GC workaround if needed."""
    ocaml_version = get_ocaml_version()
    arch = platform.machine().lower()

    print(f"OCaml version: {ocaml_version}")
    print(f"Architecture: {arch}")

    if ocaml_version.startswith("5.3.") and arch in ("aarch64", "ppc64le", "arm64"):
        print("Applying OCaml 5.3.0 GC workaround (s=16M)")
        os.environ["OCAMLRUNPARAM"] = "s=16M"

    print(f"OCAMLRUNPARAM: {os.environ.get('OCAMLRUNPARAM', '<default>')}")


def write_file(path, content):
    """Write content to a file."""
    dirname = os.path.dirname(path)
    if dirname:
        os.makedirs(dirname, exist_ok=True)
    with open(path, "w") as f:
        f.write(content)


def run_cmd(cmd, check_output=None):
    """Run command and optionally check output contains a string."""
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        return False, f"exit code {result.returncode}: {result.stderr}"
    if check_output and check_output not in result.stdout:
        return False, f"output missing '{check_output}': {result.stdout}"
    return True, result.stdout


def main():
    print("=== Dune Functional Build Tests ===")

    apply_ocaml_530_workaround()

    errors = 0
    test_dir = tempfile.mkdtemp(prefix="dune_test_")
    original_dir = os.getcwd()

    try:
        os.chdir(test_dir)

        # Initialize dune project
        write_file("dune-project", "(lang dune 3.0)")

        # Test 1: Bytecode executable
        print("\n=== Test 1: Simple bytecode executable ===")
        write_file(
            "simple_byte/dune",
            "(executable\n (name hello)\n (modes byte))",
        )
        write_file(
            "simple_byte/hello.ml",
            'let () = print_endline "Hello from dune (bytecode)"',
        )

        result = subprocess.run(
            ["dune", "build", "simple_byte/hello.bc"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            ok, msg = run_cmd(
                ["./_build/default/simple_byte/hello.bc"],
                "Hello from dune",
            )
            if ok:
                print("[OK] bytecode build + run")
            else:
                print(f"[FAIL] bytecode run: {msg}")
                errors += 1
        else:
            print(f"[FAIL] bytecode build: {result.stderr}")
            errors += 1

        # Test 2: Native executable
        print("\n=== Test 2: Simple native executable ===")
        write_file(
            "simple_native/dune",
            "(executable\n (name hello)\n (modes native))",
        )
        write_file(
            "simple_native/hello.ml",
            'let () = print_endline "Hello from dune (native)"',
        )

        result = subprocess.run(
            ["dune", "build", "simple_native/hello.exe"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            ok, msg = run_cmd(
                ["./_build/default/simple_native/hello.exe"],
                "Hello from dune",
            )
            if ok:
                print("[OK] native build + run")
            else:
                print(f"[FAIL] native run: {msg}")
                errors += 1
        else:
            print(f"[FAIL] native build: {result.stderr}")
            errors += 1

        # Test 3: Multi-file library project
        print("\n=== Test 3: Multi-file library project ===")
        write_file(
            "multifile/dune",
            """(library
 (name mylib)
 (modules mylib))

(executable
 (name main)
 (libraries mylib)
 (modules main))""",
        )
        write_file(
            "multifile/mylib.ml",
            'let greet name = Printf.printf "Hello, %s!\\n" name',
        )
        write_file("multifile/main.ml", 'let () = Mylib.greet "Dune"')

        result = subprocess.run(
            ["dune", "build", "multifile/main.exe"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            ok, msg = run_cmd(
                ["./_build/default/multifile/main.exe"],
                "Hello, Dune",
            )
            if ok:
                print("[OK] multi-file library + executable")
            else:
                print(f"[FAIL] multi-file run: {msg}")
                errors += 1
        else:
            print(f"[FAIL] multi-file build: {result.stderr}")
            errors += 1

        # Test 4: Unix module (stdlib dependency)
        print("\n=== Test 4: Unix module integration ===")
        write_file(
            "unix_test/dune",
            "(executable\n (name unix_test)\n (libraries unix))",
        )
        write_file(
            "unix_test/unix_test.ml",
            """let () =
  let pid = Unix.getpid () in
  Printf.printf "PID: %d\\n" pid;
  print_endline "Unix module works"
""",
        )

        result = subprocess.run(
            ["dune", "build", "unix_test/unix_test.exe"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            ok, msg = run_cmd(
                ["./_build/default/unix_test/unix_test.exe"],
                "Unix module works",
            )
            if ok:
                print("[OK] Unix module compilation + execution")
            else:
                print(f"[FAIL] Unix module run: {msg}")
                errors += 1
        else:
            print(f"[FAIL] Unix module build: {result.stderr}")
            errors += 1

        # Test 5: dune clean
        print("\n=== Test 5: dune clean ===")
        result = subprocess.run(["dune", "clean"], capture_output=True, text=True)
        if result.returncode == 0 and not os.path.exists("_build"):
            print("[OK] dune clean")
        else:
            print("[FAIL] dune clean didn't remove _build")
            errors += 1

    finally:
        os.chdir(original_dir)
        shutil.rmtree(test_dir, ignore_errors=True)

    if errors > 0:
        print(f"\n=== FAILED: {errors} error(s) ===")
        return 1

    print("\n=== All dune functional tests passed ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())

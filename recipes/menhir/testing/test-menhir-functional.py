#!/usr/bin/env python3
"""Test: menhir functional tests

Tests menhir parser generator functionality:
- Parser generation from .mly grammar
- Conflict reporting (--explain)
- Base parser generation (--base)
- Type inference (--infer)
- Help and diagnostics

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
    """Write content to file."""
    with open(path, "w") as f:
        f.write(content)


def read_file(path):
    """Read file content."""
    with open(path, "r") as f:
        return f.read()


def main():
    print("=== Menhir Functional Tests ===")

    apply_ocaml_530_workaround()

    errors = 0
    test_dir = tempfile.mkdtemp(prefix="menhir_test_")
    original_dir = os.getcwd()

    try:
        os.chdir(test_dir)

        # Test 1: Simple calculator grammar
        print("\n=== Test 1: Generate parser from .mly grammar ===")
        write_file(
            "calc.mly",
            """%token <int> INT
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN
%token EOL

%left PLUS MINUS
%left TIMES DIV

%start <int> main
%type <int> expr

%%

main:
  | e = expr EOL { e }

expr:
  | i = INT { i }
  | LPAREN e = expr RPAREN { e }
  | e1 = expr PLUS e2 = expr { e1 + e2 }
  | e1 = expr MINUS e2 = expr { e1 - e2 }
  | e1 = expr TIMES e2 = expr { e1 * e2 }
  | e1 = expr DIV e2 = expr { e1 / e2 }
""",
        )

        # Check version
        result = subprocess.run(
            ["menhir", "--version"], capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"  menhir version: {result.stdout.strip()}")
            print("  [OK] menhir version")
        else:
            print("  [FAIL] menhir --version failed")
            errors += 1

        # Generate parser
        result = subprocess.run(
            ["menhir", "calc.mly"], capture_output=True, text=True
        )
        if result.returncode == 0:
            print("  [OK] parser generation")

            # Check output files
            if os.path.exists("calc.ml") and os.path.exists("calc.mli"):
                print("  [OK] output files (.ml, .mli)")

                # Verify .ml contains parser code
                ml_content = read_file("calc.ml")
                if "let rec" in ml_content and "type token" in ml_content:
                    print("  [OK] generated parser code")
                else:
                    print("  [FAIL] Generated .ml missing expected parser code")
                    errors += 1

                # Verify .mli contains type definitions
                mli_content = read_file("calc.mli")
                if "type token" in mli_content:
                    print("  [OK] generated interface (.mli)")
                else:
                    print("  [FAIL] Generated .mli missing type definitions")
                    errors += 1
            else:
                print("  [FAIL] Expected output files not generated")
                errors += 1
        else:
            print("  [FAIL] menhir failed to generate parser")
            print(f"  stderr: {result.stderr}")
            errors += 1

        # Test 2: Conflict reporting
        print("\n=== Test 2: Generate parser with conflict reporting ===")
        write_file(
            "expr.mly",
            """%token <int> NUM
%token PLUS
%token EOL
%start <int> main
%type <int> expr
%%
main: e = expr EOL { e }
expr:
  | n = NUM { n }
  | e1 = expr PLUS e2 = expr { e1 + e2 }
""",
        )

        result = subprocess.run(
            ["menhir", "--explain", "expr.mly"], capture_output=True, text=True
        )
        if result.returncode == 0:
            print("  [OK] parser generation with --explain")
            if os.path.exists("expr.conflicts"):
                print("  [OK] conflict report generated")
            else:
                print("  [OK] no conflicts detected")
        else:
            print("  [FAIL] menhir --explain failed")
            errors += 1

        # Test 3: Base parser
        print("\n=== Test 3: Generate base parser ===")
        write_file(
            "simple.mly",
            """%token <int> INT
%token PLUS
%token EOL
%start <int> main
%%
main: n = INT EOL { n }
""",
        )

        result = subprocess.run(
            ["menhir", "--base", "simple", "simple.mly"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            if os.path.exists("simple.ml") and os.path.exists("simple.mli"):
                print("  [OK] base parser generation")
            else:
                print("  [FAIL] Base parser files not generated")
                errors += 1
        else:
            print("  [FAIL] menhir --base failed")
            errors += 1

        # Test 4: Type inference
        print("\n=== Test 4: Generate parser with type inference ===")
        write_file(
            "infer.mly",
            """%token <int> NUM
%token EOL
%start main
%type <int> main
%%
main: n = NUM EOL { n }
""",
        )

        result = subprocess.run(
            ["menhir", "--infer", "infer.mly"], capture_output=True, text=True
        )
        if result.returncode == 0:
            if os.path.exists("infer.ml") and os.path.exists("infer.mli"):
                print("  [OK] parser generation with --infer")
            else:
                print("  [FAIL] --infer output files not generated")
                errors += 1
        else:
            print("  [FAIL] menhir --infer failed")
            errors += 1

        # Test 5: Help
        print("\n=== Test 5: Menhir help ===")
        result = subprocess.run(
            ["menhir", "--help"], capture_output=True, text=True
        )
        if "Usage:" in result.stdout or "usage:" in result.stdout.lower():
            print("  [OK] menhir --help")
        else:
            print("  [FAIL] menhir --help failed")
            errors += 1

    finally:
        os.chdir(original_dir)
        shutil.rmtree(test_dir, ignore_errors=True)

    if errors > 0:
        print(f"\n=== FAILED: {errors} error(s) ===")
        return 1

    print("\n=== All menhir functional tests passed ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())

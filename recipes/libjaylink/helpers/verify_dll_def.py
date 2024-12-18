import subprocess
import re
import sys


def get_dll_exports(dll_path):
    try:
        output = subprocess.check_output(['nm', '-D', dll_path], text=True)
        print("Raw nm output:", output)  # Debug output
        exports = set(re.findall(r'\s+T\s+(_?)(\w+)', output))
        exports = {name for _, name in exports}
        print("Found exports using nm:", exports)
        return exports
    except subprocess.CalledProcessError as e:
        print("Error running nm:", e)
        return set()


def get_def_exports(def_path):
    with open(def_path) as f:
        exports = set()
        for line in f:
            line = line.strip()
            if line and not line.startswith(';') and 'EXPORTS' not in line:
                exports.add(line.split()[0])
        print("Found exports in .def file:", exports)
        return exports


def compare_exports(dll_path, def_path):
    print(f"Checking DLL: {dll_path}")
    print(f"Against DEF: {def_path}")

    dll_exports = get_dll_exports(dll_path)
    def_exports = get_def_exports(def_path)

    if not dll_exports:
        print("ERROR: No exports found in DLL!")
        return False

    missing_in_dll = def_exports - dll_exports
    missing_in_def = dll_exports - def_exports

    if missing_in_dll:
        print("ERROR: Functions in .def but not in DLL:", missing_in_dll)
    if missing_in_def:
        print("ERROR: Functions in DLL but not in .def:", missing_in_def)

    return not (missing_in_dll or missing_in_def)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: verify_dll_def.py <dll_path> <def_path>")
        sys.exit(1)

    success = compare_exports(sys.argv[1], sys.argv[2])
    if not success:
        print("Validation FAILED")
        sys.exit(1)
    print("Validation PASSED")

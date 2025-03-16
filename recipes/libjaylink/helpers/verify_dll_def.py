import subprocess
import re
import sys


def get_dll_exports(dll_path):
    try:
        output = subprocess.check_output(['objdump', '-p', dll_path], text=True, stderr=subprocess.STDOUT)
        exports = set()
        in_export_section = False
        for line in output.splitlines():
            if '[Ordinal/Name Pointer] Table' in line:
                in_export_section = True
                continue
            if in_export_section:
                line = line.strip()
                if not line:
                    continue
                # Format: [  number] function_name
                if ']' in line:
                    exports.add(line.split(']')[1].strip())

        print("Found exports:", exports)
        return exports
    except subprocess.CalledProcessError as e:
        print("Error running objdump:", e)
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
    # missing_in_def = dll_exports - def_exports  # Don't check for extra DLL exports

    if missing_in_dll:
        print("ERROR: Functions in .def but not in DLL:", missing_in_dll)
        return False

    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: verify_dll_def.py <dll_path> <def_path>")
        sys.exit(1)

    success = compare_exports(sys.argv[1], sys.argv[2])
    if not success:
        print("Validation FAILED")
        sys.exit(1)
    print("Validation PASSED")

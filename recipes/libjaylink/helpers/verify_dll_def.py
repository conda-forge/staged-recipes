import subprocess
import re


def get_dll_exports(dll_path):
    # Use nm -D for MinGW or dumpbin /exports for MSVC
    try:
        output = subprocess.check_output(['dumpbin', '/exports', dll_path], text=True)
        # Extract function names from nm output
        exports = set(re.findall(r'\s+T\s+(_?)(\w+)', output))
        return {name for _, name in exports}
    except subprocess.CalledError:
        return set()


def get_def_exports(def_path):
    with open(def_path) as f:
        exports = set()
        for line in f:
            line = line.strip()
            if line and not line.startswith(';') and 'EXPORTS' not in line:
                exports.add(line.split()[0])
        return exports


def compare_exports(dll_path, def_path):
    dll_exports = get_dll_exports(dll_path)
    def_exports = get_def_exports(def_path)

    missing_in_dll = def_exports - dll_exports
    missing_in_def = dll_exports - def_exports

    if missing_in_dll:
        print("Functions in .def but not in DLL:", missing_in_dll)
    if missing_in_def:
        print("Functions in DLL but not in .def:", missing_in_def)

    return not (missing_in_dll or missing_in_def)

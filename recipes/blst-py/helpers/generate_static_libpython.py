import subprocess
import os
import sysconfig


def find_python_dll_in_paths(python_dll):
    found = False
    for directory in os.environ['PATH'].split(os.pathsep):
        if os.path.isdir(directory):
            for root, dirs, files in os.walk(directory):
                if python_dll in files:
                    return root
    if not found:
        print(f"Warning: {python_dll} not found.")


def generate_libpython():
    lib_dir = os.path.join(sysconfig.get_config_var('prefix'), "libs")
    python_lib = f"python{sysconfig.get_config_var('VERSION')}.lib"

    if not os.path.exists(os.path.join(lib_dir, python_lib)):
        raise FileNotFoundError(f"Python library {python_lib} not found in {lib_dir}")

    python_dll = python_lib.replace(".lib", ".dll")
    root = find_python_dll_in_paths(python_dll)
    python_def = python_dll.replace(".dll", ".def")
    libpython = f"lib{python_dll.replace('.dll', '.a')}"
    try:
        subprocess.run(
            ['gendef.exe', os.path.join(root, python_dll)],
            check=True,
            cwd=lib_dir,
        )

        subprocess.run(
            ['dlltool.exe', '--dllname', os.path.join(root, python_dll), '--add-stdcall-alias', '--def', python_def, '--output-lib', libpython],
            check=True,
            cwd=lib_dir,
        )

        print(f"Library {libpython} generated: {os.path.exists(os.path.join(lib_dir, libpython))}.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    generate_libpython()

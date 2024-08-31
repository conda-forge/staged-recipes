import subprocess
import os
import sysconfig


def find_python_dlls(lib_dir):
    # List all files in the specified directory
    files = os.listdir(lib_dir)
    return [f for f in files if f.endswith('.dll') if 'ython' in f]


def generate_libpython():
    lib_dir = os.path.join(sysconfig.get_config_var('prefix'), "libs")
    for python_dll in find_python_dlls(lib_dir):
        python_def = python_dll.replace(".dll", ".def")
        libpython = f"lib{python_dll.replace('.dll', '.a')}"
        try:
            # Run gendef.exe to generate the .def file
            subprocess.run(
                ['gendef.exe', "-", python_dll],
                check=True,
                cwd=lib_dir,
            )

            # Run dlltool.exe to generate the .a file
            subprocess.run(
                ['dlltool.exe', '--dllname', python_dll, '--def', python_def, '--output-lib', libpython],
                check=True,
                cwd=lib_dir,
            )

            print(f"Library {libpython} generated and moved successfully.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    generate_libpython()

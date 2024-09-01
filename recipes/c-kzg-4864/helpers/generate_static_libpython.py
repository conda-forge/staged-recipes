import subprocess
import os
import sysconfig


def find_python_dlls(lib_dir):
    files = os.listdir(lib_dir)
    for f in files:
        if f.endswith('.lib') and 'ython' in f:
            dll_name = f.replace('.lib', '.dll')
            found = False
            for directory in os.environ['PATH'].split(os.pathsep):
                if os.path.isdir(directory):
                    for root, dirs, files in os.walk(directory):
                        if dll_name in files:
                            found = True
                            yield root, dll_name
                            break  # Stop searching once the DLL is found
            if not found:
                print(f"Warning: {dll_name} not found for {f}.")


def generate_libpython():
    lib_dir = os.path.join(sysconfig.get_config_var('prefix'), "libs")
    for root, python_dll in find_python_dlls(lib_dir):
        python_def = python_dll.replace(".dll", ".def")
        libpython = f"lib{python_dll.replace('.dll', '.a')}"
        try:
            # Run gendef.exe to generate the .def file
            subprocess.run(
                ['gendef.exe', os.path.join(root, python_dll)],
                check=True,
                cwd=lib_dir,
            )

            # Run dlltool.exe to generate the .a file
            subprocess.run(
                ['dlltool.exe', '--dllname', os.path.join(root, python_dll), '--def', python_def, '--output-lib', libpython],
                check=True,
                cwd=lib_dir,
            )

            print(f"Library {libpython} generated.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    generate_libpython()

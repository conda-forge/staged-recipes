import subprocess
import os
import sysconfig


def generate_libpython():
    lib_dir = os.path.join(sysconfig.get_config_var('prefix'), "libs")
    python_dll = f"python{sysconfig.get_config_var('VERSION')}.dll"
    python_def = python_dll.replace(".dll", ".def")
    libpython = f"libpython{sysconfig.get_config_var('VERSION')}.a"
    try:
        # Run gendef.exe to generate the .def file
        subprocess.run(
            ['gendef.exe', "-", f"python{sysconfig.get_config_var('VERSION')}.dll"],
            check=True,
            cwd=lib_dir,
        )

        # Run dlltool.exe to generate the .a file
        subprocess.run(
            ['dlltool.exe', '--dllname', python_dll, '--def', python_def, '--output-lib', libpython],
            check=True,
            cwd=lib_dir,
        )

        print("Library generated and moved successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    generate_libpython()

import subprocess
import os
import sysconfig


def generate_libpython():
    python_dll = os.path.join(f"{sysconfig.get_config_var('prefix')}", "libs", f"python{sysconfig.get_config_var('VERSION')}.dll")
    python_def = python_dll.replace(".dll", ".def")
    libpython = f"libpython{sysconfig.get_config_var('VERSION')}.a"
    try:
        # Run gendef.exe to generate the .def file
        subprocess.run(['gendef.exe', python_dll], check=True)

        # Run dlltool.exe to generate the .a file
        subprocess.run(
            ['dlltool.exe', '--dllname', python_dll, '--def', python_def, '--output-lib', libpython],
            check=True)

        print("Library generated and moved successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    generate_libpython()

import glob
import os
import shutil
import subprocess


def concatenate_multiline_definitions(lines):
    concatenated_lines = []
    temp_line = ""

    for line in lines:
        if line.strip().endswith("\\"):
            temp_line += line.strip()[:-1]  # Exclude the backslash
        else:
            concatenated_lines.append(temp_line + line)
            temp_line = ""

    return concatenated_lines

def create_empty_headers(include_dir, file_lines):
    sys_hs = [line
              .strip()
              .replace("#include <", '')
              .replace('>', '') for line in file_lines if line.startswith("#include <")]

    # Add empty system headers to the cffi directory
    for sys_h in sys_hs:
        full_path = os.path.join(os.path.join(include_dir, "tmp_includes"), sys_h)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)  # Create any necessary directories

        with open(full_path, 'w') as f:
            f.write("\n")


def post_process(text):
    lines = text.split("\n")
    filtered_lines = [line for line in lines if all([w not in line for w in [
        "_STDC",
        "_H",
        "_API",
        "_BUILD",
        "_DEPRECATED",
        "_PREREQ",
        "_WARN_UNUSED_RESULT",
        "_ARG_NONNULL",
        "_EXTRAPARAMS",
    ]])]
    filtered_lines = [f"{line} ..." if line.startswith("#define") else line for line in filtered_lines]
    filtered_lines = [line for line in filtered_lines if line not in defines_set]
    defines_set.update(set(f"{line}" for line in filtered_lines if line.startswith("#define")))
    return "\n".join(filtered_lines)

# Create the _cffi_build directory
src_dir = os.environ.get("SRC_DIR")
cffi_dir = os.path.abspath(os.path.join(src_dir, "_cffi_build") if src_dir else "_cffi_build")

os.makedirs(cffi_dir, exist_ok=True)
os.makedirs(os.path.join(cffi_dir, 'tmp_includes'), exist_ok=True)

# Fetch header paths using pkg-config
pkg_config_output = subprocess.run(["pkg-config", "--cflags-only-I", "libsecp256k1"], capture_output=True, text=True).stdout
header_paths = [x[2:] for x in pkg_config_output.split() if x.startswith("-I")]

defines_set = set()
# Loop through each header path
for header_path in header_paths:
    if os.path.isdir(header_path):
        headers_files = [f"{header_path}/secp256k1.h"] + glob.glob(f"{header_path}/secp256k1_*.h")
        for header_file in headers_files:
            if os.path.isfile(header_file):
                with open(header_file, 'r') as f:
                    lines = f.readlines()

                output_filename = os.path.join(cffi_dir, 'tmp_includes', os.path.basename(header_file))
                with open(output_filename, 'w') as f_out:
                    subprocess.Popen(
                        [
                        "cpp",
                        "-E",
                        "-P",
                        "-dM",
                        "-D SECP256K1_BUILD",
                        "-undef",
                        "-I.",
                        "-"],
                        stdin=subprocess.PIPE,
                        stdout=f_out,
                        stderr=subprocess.DEVNULL,
                        cwd=os.path.join(cffi_dir, 'tmp_includes'),
                    ).communicate(input='\n'.join(lines).encode("utf-8"))
                create_empty_headers(cffi_dir, lines)

        for header_file in headers_files:
            if os.path.isfile(header_file):
                with open(header_file, 'r') as f:
                    lines = f.readlines()
                lines = concatenate_multiline_definitions(lines)

                stdout = subprocess.Popen(
                    [
                    "cpp",
                    "-E",
                    "-P",
                    "-dN",
                    "-undef",
                    "-D SECP256K1_BUILD",
                    "-I.",
                    "-"],
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL,
                    cwd=os.path.join(cffi_dir, 'tmp_includes'),
                ).communicate(input='\n'.join(lines).encode("utf-8"))

                output_filename = os.path.join(cffi_dir, os.path.basename(header_file))
                with open(output_filename, 'w') as f_out:
                    f_out.write(post_process(stdout[0].decode("utf-8")))

    # for header_file in headers_files:
        #     if os.path.isfile(header_file):
        #         os.remove(os.path.join(cffi_dir, 'tmp_includes', os.path.basename(header_file)))
    else:
        print(f"Warning: {header_path} not found.")

shutil.rmtree(os.path.join(cffi_dir, 'tmp_includes'))
print("Done.")

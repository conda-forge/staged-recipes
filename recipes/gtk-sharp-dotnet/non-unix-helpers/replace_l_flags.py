import re
import os
import sys
import argparse


def replace_l_flag_in_file(file_path, exclude_regex, host_conda_libs, build_conda_libs, debug=False):
    """
    Replaces -lxxx flags in a file with specific paths to libraries, preserving tabs and newlines.

    Args:
        file_path (str): Path to the file.
        exclude_regex (str): Regex pattern to exclude certain linker flags.
        host_conda_libs (str): Path to host libraries.
        build_conda_libs (str): Path to build libraries.
        debug (bool): Debugging flag for verbose output.

    Returns:
        None: Modifies the file in-place while preserving formatting.
    """
    if not os.path.isfile(file_path):
        print(f"Error: File '{file_path}' does not exist.", file=sys.stderr)
        return

    processed_lines = []

    # Open the file and read it line by line
    with open(file_path, "r") as file:
        lines = file.readlines()

        for line in lines:
            processed_line = line  # Keep a copy of the original line with formatting

            # Process lines containing linker flags (-l*)
            if re.match(r"^[APGIL][a-zA-Z0-9_]*IBS", processed_line):
                if debug:
                    print(f"Processing matching line: {processed_line.strip()}")

                # Add space before "-l" flags to allow proper splitting
                modified_line = re.sub(r"(?<!\s)(-l)", r" \1", processed_line)

                # Split the line into tokens while preserving whitespace
                tokens = re.split(r"(\s+)", modified_line)  # Retain whitespace in the split

                updated_tokens = []

                for token in tokens:
                    if token.startswith("-l"):
                        lib_name = token[2:]  # Extract the library name after "-l"
                        if re.match(exclude_regex, lib_name):
                            if debug:
                                print(f"    Library '{lib_name}' is excluded. Keeping unchanged.")
                            updated_tokens.append(token)
                        else:
                            host_lib = f"{host_conda_libs}/{lib_name}.lib"
                            build_lib = f"{build_conda_libs}/{lib_name}.lib"

                            if os.path.isfile(build_lib):
                                if debug:
                                    print(f"    Found in build_conda_libs: {build_lib}")
                                updated_tokens.append(build_lib)
                            elif os.path.isfile(host_lib):
                                if debug:
                                    print(f"    Found in host_conda_libs: {host_lib}")
                                updated_tokens.append(host_lib)
                            else:
                                print(f"Error: Library '{lib_name}' not found.", file=sys.stderr)
                                sys.exit(1)
                    else:
                        # Add other tokens (including whitespace) unchanged
                        updated_tokens.append(token)

                # Join the updated tokens back, preserving all original whitespace
                processed_line = "".join(updated_tokens)

            # Append the processed (or original) line to the result
            processed_lines.append(processed_line)

    # Write the updated lines back to the file
    with open(file_path, "w") as file:
        file.writelines(processed_lines)

    if debug:
        print(f"Successfully updated file: {file_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Replace -lxxx flags in files with specific paths, preserving tabs and newlines.")
    parser.add_argument("--exclude-regex", type=str, required=True, help="Regex to exclude certain -l flags.")
    parser.add_argument("--host-dir", type=str, required=True, help="Path to the host conda libraries directory.")
    parser.add_argument("--build-dir", type=str, required=True, help="Path to the build conda libraries directory.")
    parser.add_argument("--debug", action="store_true", help="Enable debug messages.")
    parser.add_argument("files", nargs="+", help="List of files to process.")

    args = parser.parse_args()

    exclude_regex = args.exclude_regex
    host_dir = args.host_dir
    build_dir = args.build_dir
    debug = args.debug
    files = args.files

    for file in files:
        if debug:
            print(f"Processing file: {file}")
        replace_l_flag_in_file(file, exclude_regex, host_dir, build_dir, debug)


if __name__ == "__main__":
    main()
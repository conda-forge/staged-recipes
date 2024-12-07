import os
import subprocess
import sys
import argparse


# Replace pathlib.Path with os.path operations since pathlib isn't available in Python 2.7
def join_paths(*args):
    """Helper function to join paths in a cross-version compatible way"""
    return os.path.join(*args)


def makedirs(path):
    """Create directory and parents if they don't exist"""
    if not os.path.exists(path):
        os.makedirs(path)


def install_resources(origin, items_list, shared_base):
    """
    Install resources from the specified directory using tar to
    respect symlinks and permissions.

    :param origin: The 'prefix' origin.
    :param items_list: List of names to check.
    :param shared_base: The post-PREFIX base path.
    """
    # Create the origin + shared_base path
    if not os.getenv('PREFIX'):
        raise ValueError("PREFIX environment variable not set.")

    orig_path = join_paths(os.getenv('PREFIX'), origin, shared_base)
    dest_path = join_paths(os.getenv('PREFIX'), shared_base)
    makedirs(dest_path)

    for item in items_list.split():
        # Use string formatting compatible with Python 2.7
        tar_command = "tar -C %s -cf - %s" % (orig_path, item)
        extract_command = "tar -C %s -xf -" % dest_path

        # Python 2.7 doesn't support 'with' for Popen directly, so we need to handle cleanup manually
        proc = subprocess.Popen(tar_command, shell=True, stdout=subprocess.PIPE)
        extract_proc = subprocess.Popen(extract_command, shell=True, stdin=proc.stdout)

        # Close proc.stdout to allow proc to receive a SIGPIPE if extract_proc exits
        proc.stdout.close()

        # Wait for the extraction to complete
        extract_proc.wait()
        proc.wait()


def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Check for missing QEMU files.")
    parser.add_argument("origin", help="The 'prefix' origin.")
    parser.add_argument("shared_base", help="The post-PREFIX base path.")
    parser.add_argument("items_list", help="List of names to check.")

    args = parser.parse_args()

    install_resources(args.origin, args.items_list, args.shared_base)

    sys.exit(0)


if __name__ == "__main__":
    main()

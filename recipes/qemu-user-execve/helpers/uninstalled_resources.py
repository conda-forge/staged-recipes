import os
import sys
import argparse


def walk_files(directory):
    """Helper function to recursively walk through directory"""
    for root, _, files in os.walk(directory):
        for file in files:
            full_path = os.path.join(root, file)
            # Get path relative to the directory we started from
            yield os.path.relpath(full_path, directory)


def uninstalled_resources(origin):
    """
    Verify that all the files in the specified directory are installed.
    This function checks recursively for missing files.

    :param origin: The directory to check for installed resources.
    :return: A list of missing files.
    """
    # Create the origin + shared_base path
    if not os.getenv('PREFIX'):
        raise ValueError("PREFIX environment variable not set.")

    orig_path = os.path.join(os.getenv('PREFIX'), origin)
    dest_path = os.getenv('PREFIX')

    # Create destination directory if it doesn't exist
    if not os.path.exists(dest_path):
        os.makedirs(dest_path)

    missing_files = []

    # Recursively check for missing files using os.walk
    for relative_path in walk_files(orig_path):
        dest_file = os.path.join(dest_path, relative_path)
        if not os.path.exists(dest_file):
            missing_files.append(relative_path)

    return missing_files


def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Check for missing QEMU files.")
    parser.add_argument("origin", help="The 'prefix' origin.")

    args = parser.parse_args()

    # Python 2.7 compatible version of the walrus operator
    uninstalled = uninstalled_resources(args.origin)
    if uninstalled:
        print("Uninstalled resources: %s" % uninstalled)
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()

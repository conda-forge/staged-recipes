import os
import sys
import argparse


def check_missing_files(item_var, shared_base):
    """Check for missing files in the specified directory."""
    missing_files = []
    prefix = os.environ.get('PREFIX', '')

    for b in item_var.split():
        file_path = os.path.join(prefix, shared_base, b)
        if not os.path.exists(file_path):
            missing_files.append(os.path.join(shared_base, b))

    return missing_files


def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Check for missing QEMU files.")
    parser.add_argument("shared_base", help="The post-PREFIX base path.")
    parser.add_argument("items_list", help="List of names to check.")

    args = parser.parse_args()

    # Python 2.7 compatible version of the walrus operator
    missing_files = check_missing_files(args.items_list, args.shared_base)
    if missing_files:
        print("Missing items: %s" % missing_files)
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()

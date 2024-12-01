#!/usr/bin/env python3

import os
import sys
from pathlib import Path
import argparse

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
    
    orig_path = Path(os.getenv('SRC_DIR')) / Path(origin) / Path(shared_base)
    dest_path = Path(os.getenv('PREFIX')) / Path(shared_base)
    os.makedirs(dest_path, exist_ok=True)
    
    for item in items_list.split():
        # Use tar to respect symlinks and permissions
        os.system(f"tar -C {orig_path} -cf - {item} | tar -C {dest_path} -xf -")
    

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

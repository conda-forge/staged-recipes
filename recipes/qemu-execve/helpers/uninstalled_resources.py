#!/usr/bin/env python3

import os
import sys
from pathlib import Path
import argparse

def uninstalled_resources(origin):
    """
    Verify that all the files in the specified directory are installed.
    """
    
    # Create the origin + shared_base path
    if not os.getenv('PREFIX'):
        raise ValueError("PREFIX environment variable not set.")

    orig_path = Path(os.getenv('SRC_DIR')) / Path(origin)
    dest_path = Path(os.getenv('PREFIX'))
    os.makedirs(dest_path, exist_ok=True)

    return [
        item.name
        for item in orig_path.iterdir()
        if not (dest_path / item.name).exists()
    ]
    

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Check for missing QEMU files.")
    parser.add_argument("origin", help="The 'prefix' origin.")

    args = parser.parse_args()

    if uninstalled := uninstalled_resources(args.origin):
        print(f"Uninstalled resources: {uninstalled}")
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()

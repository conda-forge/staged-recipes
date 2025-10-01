#!/usr/bin/env python3

import os
import sys
from pathlib import Path
import argparse

def check_missing_files(item_var, shared_base):
    """Check for missing files in the specified directory."""
    return [
        f"{shared_base}/{b}"
        for b in item_var.split()
        if not Path(f"{os.environ.get('PREFIX', '')}/{shared_base}/{b}").exists()
    ]

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Check for missing QEMU files.")
    parser.add_argument("shared_base", help="The post-PREFIX base path.")
    parser.add_argument("items_list", help="List of names to check.")

    args = parser.parse_args()

    if missing_files := check_missing_files(args.items_list, args.shared_base):
        print(f"Missing items: {missing_files}")
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()

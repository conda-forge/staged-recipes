import os


def extract_from_import(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    start_index = next(
        (
            i
            for i, line in enumerate(lines)
            if line.strip().replace('blst', 'blst.blst').startswith('import blst')
        ),
        None,
    )
    if start_index is not None:
        extracted_lines = lines[start_index:]

        print('import hashlib')
        print('import os')
        print('import re')
        print('import sys')

        for line in extracted_lines:
            print(line, end='')

if __name__ == "__main__":
    extract_from_import('run.me')

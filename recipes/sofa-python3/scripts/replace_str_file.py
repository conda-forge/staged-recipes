import sys
from pathlib import Path
import re

# Replace regex by a string in a given file
# Used to patch CMake config files of SofaPython3 on Windows
def main():
    if len(sys.argv) != 4:
        print("Usage: python replace_str_file.py <file> <exp_find> <str_replace>")
        sys.exit(1)

    file_path = Path(sys.argv[1])
    exp_find = sys.argv[2]
    str_replace = sys.argv[3]

    if not file_path.exists():
        print(f"Error: file not found: {file_path}")
        sys.exit(1)

    content = file_path.read_text(encoding="utf-8")

    new_content = re.sub(exp_find, str_replace, content)

    if new_content != content:
        file_path.write_text(new_content, encoding="utf-8")
        print(f"Updated: {file_path}")
    else:
        print(f"Error: Failed to change in: {file_path}")
        print(f"Regex: {exp_find} -> {str_replace}")
        sys.exit(1)

if __name__ == "__main__":
    main()
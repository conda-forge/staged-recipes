#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later

"""
Post-processing script for conda recipe meta.yaml files.

This script reads and processes meta.yaml files from conda-forge recipes.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, Tuple
import shutil

try:
    import yaml
except ImportError:
    print(
        "Error: PyYAML is required. Install it with: pip install pyyaml",
        file=sys.stderr,
    )
    sys.exit(1)


def custom_process(meta_dict: Dict[str, Any]) -> Dict[str, Any]:
    """
    Custom processing of the meta dictionary.

    Parameters
    ----------
    meta_dict : Dict[str, Any]
        The meta.yaml content as a dictionary.

    Returns
    -------
    Dict[str, Any]
        The processed meta.yaml content.
    """
    meta_dict["requirements"]["host"][0] = "python 3.10"
    meta_dict["test"]["requires"].append("python 3.10")
    meta_dict["build"]["skip"] = "win"
    return meta_dict


def preprocess_jinja(content: str) -> Tuple[str, str]:
    """
    Preprocess YAML content to handle Jinja2 templates.

    This function removes or replaces Jinja2 template syntax to make
    the YAML parseable by standard YAML parsers.

    Parameters
    ----------
    content : str
        The raw YAML content with potential Jinja2 templates.

    Returns
    -------
    str
        Preprocessed YAML content with Jinja2 templates handled.
    """
    # get variable dict from {% set k = v %}
    variables = {}
    for match in re.finditer(r"{%\s*set\s+(\w+)\s*=\s*([^%]+)%}", content):
        key = match.group(1).strip()
        value = match.group(2).strip(" '\"")
        variables[key] = value
    # print(variables)

    # Remove Jinja2 variable definitions: {% set ... %}
    content = re.sub(r"{%\s*set\s+[^}]+%}", "", content)

    # Replace Jinja2 variable references: {{ variable }} with their values
    for var, val in variables.items():
        content = re.sub(r"{{\s*" + re.escape(var) + r"\s*}}", val, content)

    # Remove Jinja2 control structures: {% ... %}
    content = re.sub(r"{%\s*[^}]+%}", "", content)

    # Remove Jinja2 comments: {# ... #}
    content = re.sub(r"{#\s*[^#]*\s*#}", "", content)

    # Get the line comments starting with 'script: {{ PYTHON }}'
    line = re.search(
        r"^\s*script:\s*{{\s*PYTHON\s*}}\s*.*$", content, flags=re.MULTILINE
    )
    assert line is not None
    # Remove the line comments starting with 'script: {{ PYTHON }}'
    content = re.sub(
        r"^\s*script:\s*{{\s*PYTHON\s*}}\s*.*$", "", content, flags=re.MULTILINE
    )
    return content, line.group(0)


def read_meta_yaml(file_path: Path) -> Tuple[Dict[str, Any], str]:
    """
    Read and parse a meta.yaml file.

    Parameters
    ----------
    file_path : Path
        Path to the meta.yaml file.

    Returns
    -------
    Dict[str, Any]
        Parsed YAML content as a dictionary.

    Raises
    ------
    FileNotFoundError
        If the specified file does not exist.
    yaml.YAMLError
        If the YAML parsing fails.
    """
    content = file_path.read_text(encoding="utf-8")

    # Preprocess to handle Jinja2 templates
    preprocessed_content, scirpt_line = preprocess_jinja(content)

    # Parse the YAML
    return yaml.safe_load(preprocessed_content), scirpt_line


def restore_yaml(meta_dict: Dict[str, Any], script_line: str) -> str:
    """
    Restore the meta.yaml content from the dictionary and script line (in the build section).

    Parameters
    ----------
    meta_dict : Dict[str, Any]
        The meta.yaml content as a dictionary.
    script_line : str
        The script line to be added back.

    Returns
    -------
    str
        The restored YAML content as a string.
    """
    indent=4
    yaml_content = yaml.dump(meta_dict, sort_keys=False, indent=indent)
    # Insert the script line back into the build section
    yaml_lines = yaml_content.splitlines()
    restored_lines = []
    in_build_section = False
    for line in yaml_lines:
        restored_lines.append(line)
        if line.strip() == "build:":
            in_build_section = True
        elif in_build_section and re.match(r"^\s*\w+:.*$", line):
            # Insert the script line before the next key in build section
            restored_lines.append(" " * indent + f"{script_line.strip()}")
            in_build_section = False
    if in_build_section:
        # If build section was at the end, add the script line
        restored_lines.append(" " * indent + f"{script_line.strip()}")
    return "\n".join(restored_lines)


def main() -> None:
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(
        description="Read and process conda recipe meta.yaml files."
    )
    parser.add_argument(
        "meta_path",
        type=str,
        help="Path to the meta.yaml file to read.",
    )

    args = parser.parse_args()

    file_path = Path(args.meta_path)
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {args.meta_path}")
    if not file_path.is_file():
        file_path = file_path / "meta.yaml"
        if not file_path.exists() or not file_path.is_file():
            raise FileNotFoundError(f"File not found: {args.meta_path} or {path}")

    try:
        meta_dict, scirpt_line = read_meta_yaml(file_path)
        # print(meta_dict)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"YAML parsing error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

    s = restore_yaml(custom_process(meta_dict), scirpt_line)
    # move the original file to a backup
    shutil.copyfile(file_path, file_path.with_suffix(".yaml.bak"))
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(s)
        f.write("\n")


if __name__ == "__main__":
    main()
    # build/script: {{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation

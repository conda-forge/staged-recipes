#!/usr/bin/env python
import argparse
import json
import os
import re
import sys


def extract_setup_info(setup_path):
    """Extract package info from setup_pip.py"""
    with open(setup_path, 'r') as f:
        content = f.read()

    # Extract basic metadata using regex
    name = re.search(r"name='([^']*)'", content).group(1)
    description = re.search(r"description='([^']*)'", content).group(1)
    long_description = re.search(r"long_description='([^']*)'", content, re.DOTALL).group(1)
    url = re.search(r"url='([^']*)'", content).group(1)
    author = re.search(r"author='([^']*)'", content).group(1)
    author_email = re.search(r"author_email='([^']*)'", content).group(1)
    license = re.search(r"license='([^']*)'", content).group(1)

    # Extract classifiers
    classifiers_match = re.search(r"classifiers=\[(.*?)\]", content, re.DOTALL)
    classifiers_text = classifiers_match.group(1)
    classifiers = re.findall(r"'([^']*)'", classifiers_text)

    # Extract keywords
    keywords = re.search(r"keywords='([^']*)'", content).group(1).split(',')

    return {
        "name": name,
        "description": description,
        "long_description": long_description,
        "url": url,
        "author": author,
        "author_email": author_email,
        "license": license,
        "classifiers": classifiers,
        "keywords": keywords
    }

def extract_requirements(req_file):
    """Parse requirements.txt file preserving conditional markers"""
    if not os.path.exists(req_file):
        return [], []

    with open(req_file, 'r') as f:
        all_requires = f.read().splitlines()

    requires = []
    kerberos_extras = []

    for req in all_requires:
        # Skip empty lines and comments
        if not req or req.startswith('#'):
            continue

        # Convert double quotes in conditional markers to single quotes
        # to avoid TOML syntax errors
        if '; ' in req and '"' in req:
            # Replace double quotes with single quotes in conditional expressions
            parts = req.split('; ', 1)
            base_req = parts[0]
            condition = parts[1].replace('"', "'")
            req = f"{base_req}; {condition}"

        # Keep the original requirement string with conditionals
        if 'gssapi' in req:
            kerberos_extras.append(req)
        else:
            requires.append(req)

    return requires, kerberos_extras

def generate_pyproject_toml(setup_info, requires, kerberos_extras, version=None):
    """Generate pyproject.toml content"""
    toml = f"""[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{setup_info['name']}"
"""
    # Use static version if provided, otherwise use dynamic
    if version:
        toml += f'version = "{version}"\n'
    else:
        toml += 'dynamic = ["version"]\n'
    toml +=f"""description = "{setup_info['description']}"
readme = "README.md"
authors = [
    {{name = "{setup_info['author']}", email = "{setup_info['author_email']}"}}
]
license = {{text = "{setup_info['license']}"}}
classifiers = [
"""

    for classifier in setup_info['classifiers']:
        toml += f'    "{classifier}",\n'

    toml += "]\n"
    toml += f'keywords = {json.dumps(setup_info["keywords"])}\n'
    toml += 'requires-python = ">=3.9"\n'
    toml += "dependencies = [\n"

    # toml += f'    "hatchling>=",\n'

    for req in requires:
        if "3.8" not in req and "setuptools" not in req and "; python_version >= '3.10'" not in req:
            req = req.replace("; python_version >= '3.9'", "")
            req = req.replace("; python_version <= '3.9'", "")
            toml += f'    "{req}",\n'

    toml += "]\n\n"

    if kerberos_extras:
        toml += "[project.optional-dependencies]\n"
        toml += "kerberos = [\n"

        for extra in kerberos_extras:
            toml += f'    "{extra}",\n'

        toml += "]\n\n"

    toml += """[project.scripts]
pgadmin4 = "pgadmin4.pgAdmin4:main"
pgadmin4-cli = "pgadmin4.setup:main"

[tool.hatch.version]
path = "pgadmin4/config.py"
pattern = '''APP_VERSION\\s*=\\s*["'](?P<version>.+)["']'''

[tool.hatch.metadata]
license-files = ["LICENSE"]

[tool.hatch.build]
include = [
    "pgadmin4/**/*",
]
exclude = [
    "**/regression/**",
    "**/__pycache__/**",
]
"""

    return toml

def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate pyproject.toml from pgAdmin4 setup files"
    )
    parser.add_argument(
        "--setup",
        dest="setup_path",
        default="../pgadmin4/pkg/pip/setup_pip.py",
        help="Path to setup_pip.py file"
    )
    parser.add_argument(
        "--req",
        dest="req_file",
        default="../pgadmin4/requirements.txt",
        help="Path to requirements.txt file"
    )
    parser.add_argument(
        "--output",
        dest="output_file",
        default="pyproject.toml",
        help="Path for the output pyproject.toml file"
    )
    parser.add_argument(
        "--version",
        dest="version",
        help="Static version number to use instead of dynamic extraction"
    )

    return parser.parse_args()


def main():
    args = parse_args()
    setup_pip_path = args.setup_path
    req_file = args.req_file
    output_file = args.output_file

    if not os.path.exists(setup_pip_path):
        print(f"Error: Cannot find setup_pip.py at {setup_pip_path}")
        return 1

    setup_info = extract_setup_info(setup_pip_path)
    requires, kerberos_extras = extract_requirements(req_file)

    # Add debug output to verify requirements are being found
    print(f"Found {len(requires)} dependencies and {len(kerberos_extras)} kerberos extras")

    # If no requirements found, exit with error
    if not requires and os.path.exists(req_file):
        print(f"Error: No requirements found in {req_file}")
        return 1

    toml_content = generate_pyproject_toml(
        setup_info,
        requires,
        kerberos_extras,
        args.version,
    )

    with open(output_file, "w") as f:
        f.write(toml_content)

    print(f"Generated pyproject.toml saved to {output_file}")
    return 0

if __name__ == "__main__":
    sys.exit(main())

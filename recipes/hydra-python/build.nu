#!/usr/bin/env nu

cd hydra-python

# Main python package directory
mkdir src/main/python/hydra
cp ($env.RECIPE_DIR | path join "__init__.py") src/main/python/hydra/__init__.py

# Gen-main directory (create if it doesn't exist)
mkdir src/gen-main/python/hydra
cp ($env.RECIPE_DIR | path join "__init__.py") src/gen-main/python/hydra/__init__.py

# Set environment variables to fix Windows hatchling import issue
$env.PIP_NO_BUILD_ISOLATION = "1"
$env.PIP_DISABLE_PIP_VERSION_CHECK = "1"

# On Windows, pre-import hatchling to work around import issues
if ($nu.os-info.name == "windows") {
    let site_packages = ($env.PREFIX | path join "Lib" "site-packages")
    $env.PYTHONPATH = if ($env.PYTHONPATH? | is-empty) {
        $site_packages
    } else {
        $"($env.PYTHONPATH);($site_packages)"
    }

    # Pre-import hatchling to ensure it's available
    ^python pre-import-hatchling.py
}

# Install the package using pip with disabled build isolation
^python -m pip install . --no-deps --no-build-isolation --ignore-installed --no-cache-dir --prefix $env.PREFIX -vvv

# Copy README to prefix if it exists
if ("README.md" | path exists) {
    cp README.md ($env.PREFIX | path join "README.md")
} else {
    print "Warning: README.md not found"
}

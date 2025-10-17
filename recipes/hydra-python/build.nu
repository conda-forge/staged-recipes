#!/usr/bin/env nu

cd hydra-python

# Main python package directory
mkdir src/main/python/hydra
cp ($env.RECIPE_DIR | path join "__init__.py") src/main/python/hydra/__init__.py

# Gen-main directory (create if it doesn't exist)
mkdir src/gen-main/python/hydra
cp ($env.RECIPE_DIR | path join "__init__.py") src/gen-main/python/hydra/__init__.py

# Install the package using pip
^python -m pip install . --no-deps --ignore-installed --no-cache-dir --prefix $env.PREFIX -vvv

# Copy README to prefix if it exists
if ("README.md" | path exists) {
    cp README.md ($env.PREFIX | path join "README.md")
} else {
    print "Warning: README.md not found"
}

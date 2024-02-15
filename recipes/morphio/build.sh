# Make CXXFLAGS accessible to subprocesses,
# including the package build process.
export CXXFLAGS="-isystem $PREFIX"

# Build using inherited prefixes
python -m pip install . -vv

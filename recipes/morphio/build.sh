# Export C pre-processor flags that are set by conda
export CPPFLAGS
# Make CXXFLAGS accessible to subprocesses,
# including the package build process.
export CXXFLAGS="-I $PREFIX -isystem $BUILD_PREFIX"

# Build using inherited prefixes
python -m pip install . -vv

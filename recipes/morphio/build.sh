# Export conda-forge prefix include directories because these are not exposed to pip otherwise
export CXXFLAGS="-I$CONDA_PREFIX"
export CFLAGS="-I$CONDA_PREFIX"
# Build package via pip install
python -m pip install . -vv
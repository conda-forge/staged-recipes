ls ${PREFIX}
ls ${PREFIX}/include


$PYTHON -m pip install . --no-deps --ignore-installed -vv --global-option "build" --global-option "--hdf5=${PREFIX}"

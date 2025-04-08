set -evx

export CMAKE_PREFIX_PATH=$(python -c "import torch;print(torch.utils.cmake_prefix_path)")
# Python interface
export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION
python -m pip install . -vv
# C++ interface
mkdir -p build
cd build
cmake .. ${CMAKE_ARGS}
cmake --build . -j`nproc`
cmake --install .
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
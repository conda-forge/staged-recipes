#!/bin/bash


# Run cmake configuration
cmake -B "build" -G "Ninja" \
  -D CMAKE_INSTALL_PREFIX:FILEPATH="${PREFIX}" \
  -D CMAKE_PREFIX_PATH:FILEPATH="${PREFIX}" \
  -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="${PREFIX}" \
  -D USE_CONDA_PYBIND11:BOOL=ON \
  -D PYTHON_INCLUDE_DIR="${PREFIX}/include" \
  -D PYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
  .

# Build the project
cmake --build "build" --config "${TGT_BUILD_TYPE}"

# Install the built files
cmake --install "build" --config "${TGT_BUILD_TYPE}"

# Move output files to appropriate directories
mv "${PREFIX}/lib/TopologicCore/"*.so* "${PREFIX}/lib" || true
mv "${PREFIX}/lib/TopologicPythonBindings/"*.so "${SP_DIR}" || true

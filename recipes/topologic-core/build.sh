#!/bin/bash

# IF osx use file lib suffix .dylib
# IF linux use file lib suffix .so
# IF windows use file lib suffix .dll



# Run cmake configuration
cmake ${CMAKE_ARGS} -B "build" -G "Ninja" \
  -D CMAKE_PREFIX_PATH:FILEPATH="${PREFIX}" \
  -D USE_CONDA_PYBIND11:BOOL=ON \
  -D PYTHON_INCLUDE_DIR="${PREFIX}/include" \
  -D PYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
  .

# Build the project
cmake --build "build"

# Install the built files
cmake --install "build"



if [ "$(uname)" == "Darwin" ]; then
  mv "${PREFIX}/lib/TopologicCore/"*.dylib* "${PREFIX}/lib" || true
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Move output files to appropriate directories
  mv "${PREFIX}/lib/TopologicCore/"*.so* "${PREFIX}/lib" || true
fi

mv "${PREFIX}/lib/TopologicPythonBindings/"*.so "${SP_DIR}" || true
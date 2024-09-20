#! /bin/sh

if test -n "${OSX_ARCH}"; then
    data_input="${SRC_DIR}/data-input"
else
    data_input="${SRC_DIR}/data-input/CBFlib_0.9.7_Data_Files_Input"
fi

cmake ${CMAKE_ARGS}                                 \
    -DCBF_DATA_INPUT:PATH="${data_input}"           \
    -DCBF_DATA_OUTPUT:PATH="${SRC_DIR}/data-output" \
    -DCBF_ENABLE_FORTRAN:BOOL=OFF                   \
    -DCBF_ENABLE_JAVA:BOOL=OFF                      \
    -DCBF_ENABLE_PYTHON:BOOL=OFF                    \
    -DCBF_WITH_HDF5:BOOL=OFF                        \
    -DCBF_WITH_LIBTIFF:BOOL=OFF                     \
    "${SRC_DIR}/cbflib"

cmake --build .
ctest
cmake --install . --component Development
cmake --install . --component Runtime

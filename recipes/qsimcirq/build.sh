set -ex

# Below is to make sure that the pybind11 include folders are correct.
# For an unknown reason, I cannot get the correct CXX_INCLUDES to be passed from
# cmake. Setting anything using `include_directories(...)` doesn't result in anything in
# CXX_INCLUDES. e.g., `pybind_interface/basic/CMakeFiles/qsim_basic.dir/flags.make` would only
# have `CXX_INCLUDES = -isystem $PREFIX/include/python3.11` and would miss `$PREFIX/include`.
# This problem would result in `fatal error: pybind11/complex.h: No such file or directory`
# This is a hack to get around that by passing `-I/path/to/include` to CXX_FLAGS
PYBIND11_INCLUDES=$(python3 -m pybind11 --includes)
{
    echo "add_compile_options(${PYBIND11_INCLUDES})"
    cat pybind_interface/GetPybind11.cmake
} > pybind_interface/GetPybind11.cmake.tmp
mv pybind_interface/GetPybind11.cmake.tmp pybind_interface/GetPybind11.cmake

if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS specific commands
    OPENMP_INCLUDE_DIR=$(echo ${BUILD_PREFIX}/lib/clang/*/include)
    {
        echo "set(CMAKE_CXX_STANDARD 11)"
        echo "set(OpenMP_INCLUDE_DIR \"${OPENMP_INCLUDE_DIR}\")"
        echo "include_directories(\${OpenMP_INCLUDE_DIR})"
        echo "find_package(OpenMP REQUIRED)"
        cat CMakeLists.txt
    } > CMakeLists.txt.tmp
    mv CMakeLists.txt.tmp CMakeLists.txt
    sed -i "" "s|CXX=g++|CXX=${CXX}|" Makefile
    sed -i "" "s|/usr/local/opt/llvm/bin/clang++|${CXX_FOR_BUILD}|" setup.py
    sed -i "" "s|/usr/local/opt/llvm/bin/clang|${C_FOR_BUILD}|" setup.py
else
    # Linux specific commands
    echo -e "set(CMAKE_CXX_STANDARD 11)\n$(cat CMakeLists.txt)" > CMakeLists.txt
    sed -i "s|CXX=g++|CXX=${CXX}|" Makefile
fi

make
python -m pip install . -vvv --no-deps --no-build-isolation

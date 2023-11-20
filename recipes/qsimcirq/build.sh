set -x

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
        cat CMakeLists.txt
        echo "find_package(OpenMP REQUIRED)"
    } > CMakeLists.txt.tmp
    mv CMakeLists.txt.tmp CMakeLists.txt
    # Needs a language specified for `find_package(OpenMP REQUIRED)`
    sed -i "" "s|project(qsim)|project(qsim LANGUAGES CXX)|" CMakeLists.txt
    sed -i "" "s|CXXFLAGS = -O3 -fopenmp|CXXFLAGS = -O3 -fopenmp -I${OPENMP_INCLUDE_DIR}|" Makefile
    sed -i "" "s|CXX=g++|CXX=${CXX}|" Makefile
    sed -i "" "s|/usr/local/opt/llvm/bin/clang++|${CXX_FOR_BUILD}|" setup.py
    sed -i "" "s|/usr/local/opt/llvm/bin/clang|${C_FOR_BUILD}|" setup.py
else
    # Linux specific commands
    echo -e "set(CMAKE_CXX_STANDARD 11)\n$(cat CMakeLists.txt)" > CMakeLists.txt
    sed -i "s|CXX=g++|CXX=${CXX}|" Makefile
fi

# Enable CUDA support
if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]; then
    # Fix for cmake (>=3.27) policy: CMP0148
    sed -i "s|find_package(PythonLibs 3.7 REQUIRED)|find_package(Python3 3.7 REQUIRED COMPONENTS Interpreter Development)|" pybind_interface/cuda/CMakeLists.txt
    sed -i "s|find_package(PythonLibs 3.7 REQUIRED)|find_package(Python3 3.7 REQUIRED COMPONENTS Interpreter Development)|" pybind_interface/custatevec/CMakeLists.txt
    sed -i "s|find_package(PythonLibs 3.7 REQUIRED)|find_package(Python3 3.7 REQUIRED COMPONENTS Interpreter Development)|" pybind_interface/decide/CMakeLists.txt

    # qsim build assumes that pybind11 is downloaded using cmake
    sed -i 's|${pybind11_SOURCE_DIR}/include|${pybind11_INCLUDE_DIRS}|' pybind_interface/cuda/CMakeLists.txt

    # Fix for cmake policy: CMP0104
    sed -i '/set_target_properties(qsim_cuda PROPERTIES/a\
        CUDA_ARCHITECTURES "all"' pybind_interface/cuda/CMakeLists.txt
    sed -i '/set_target_properties(qsim_decide PROPERTIES/a\
        CUDA_ARCHITECTURES "all"' pybind_interface/decide/CMakeLists.txt
fi

# make
python -m pip install . -vvv --no-deps --no-build-isolation

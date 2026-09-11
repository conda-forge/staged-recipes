# Per-Python part of libnatten: the pybind11 module in csrc/natten.cpp, linked
# against the Python-independent kernel library from the natten-kernels
# staging output.
cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(natten_extension LANGUAGES CXX)

find_package(CUDAToolkit 12.0 REQUIRED)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(natten MODULE ${NATTEN_CSRC}/natten.cpp)
set_target_properties(natten PROPERTIES
  PREFIX ""
  OUTPUT_NAME "libnatten"
  SUFFIX "${NATTEN_EXT_SUFFIX}"
)
target_compile_definitions(natten PRIVATE
  _GLIBCXX_USE_CXX11_ABI=1
  WITH_CUDA
  NATTEN_WITH_CUTLASS
  CUTLASS_ENABLE_TENSOR_CORE_MMA=1
  NATTEN_WITH_HOPPER_FNA=1
  NATTEN_WITH_BLACKWELL_FNA=1
  TORCH_API_INCLUDE_EXTENSION_H
  TORCH_EXTENSION_NAME=libnatten
)
target_include_directories(natten PRIVATE ${NATTEN_CSRC}/include)
target_include_directories(natten SYSTEM PRIVATE ${TORCH_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIR})
target_link_directories(natten PRIVATE ${TORCH_LIBRARY_DIRS})
target_link_libraries(natten PRIVATE
  "$<LINK_LIBRARY:WHOLE_ARCHIVE,${NATTEN_KERNELS_LIB}>"
  c10 torch torch_cpu torch_python c10_cuda torch_cuda CUDA::cudart
)

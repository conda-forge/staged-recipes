# Python-independent part of libnatten: every CUDA kernel plus the ATen-level
# wrappers in csrc/src, built as a static library. Compile flags and
# definitions mirror upstream's csrc/CMakeLists.txt, minus the Python headers,
# so the result does not depend on the Python version.
cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(natten_kernels LANGUAGES CXX CUDA)

find_package(CUDAToolkit 12.0 REQUIRED)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_FLAGS "-Xcompiler -Wall -ldl")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --expt-relaxed-constexpr")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler=-Wconversion")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler=-fno-strict-aliasing")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --use_fast_math")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --extended-lambda")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -ftemplate-backtrace-limit=0")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -O3")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -DNDEBUG")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --std=c++17")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xfatbin -compress-all")

# conda-forge's libtorch is built with the new C++11 ABI
add_compile_definitions(
  _GLIBCXX_USE_CXX11_ABI=1
  WITH_CUDA
  NATTEN_WITH_CUTLASS
  CUTLASS_ENABLE_TENSOR_CORE_MMA=1
  NATTEN_WITH_HOPPER_FNA=1
  NATTEN_WITH_BLACKWELL_FNA=1
)

file(GLOB KERNEL_SOURCES
  ${NATTEN_CSRC}/src/*.cpp
  ${NATTEN_CSRC}/src/*.cu
  ${NATTEN_CSRC}/autogen/src/cuda/*/*.cu
)

add_library(natten_kernels STATIC ${KERNEL_SOURCES})
set_target_properties(natten_kernels PROPERTIES
  CUDA_ARCHITECTURES "${NATTEN_CUDA_ARCHS}"
  POSITION_INDEPENDENT_CODE ON
)
target_include_directories(natten_kernels PRIVATE
  ${NATTEN_CSRC}/include
  ${NATTEN_CSRC}/autogen/include
  ${NATTEN_CSRC}/../third_party/cutlass/include
)
target_include_directories(natten_kernels SYSTEM PRIVATE ${TORCH_INCLUDE_DIRS})

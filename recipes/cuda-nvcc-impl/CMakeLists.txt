cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

project(verify_cuda_compiler LANGUAGES CUDA)

if(NOT DEFINED CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES)
  message(FATAL_ERROR "CUDA compiler detection failed, no recording of CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES")
endif()

find_package(CUDAToolkit REQUIRED)
set(should_exist
  CUDAToolkit_BIN_DIR
  CUDAToolkit_INCLUDE_DIRS
  CUDAToolkit_LIBRARY_DIR
  CUDAToolkit_LIBRARY_ROOT
  )
foreach (cuda_loc_var IN LISTS should_exist)
  if(NOT EXISTS "${${cuda_loc_var}}")
    message(FATAL_ERROR "${cuda_loc} should exist on disk")
  endif()
endforeach()


set(cuda_libs cudart cuda_driver)
foreach (cuda_lib IN LISTS cuda_libs)
  if(NOT CUDA_${cuda_lib}_LIBRARY)
    message(FATAL_ERROR "expected CUDAToolkit variable CUDA_${cuda_lib}_LIBRARY not found")
  elseif(CUDA_${cuda_lib}_LIBRARY MATCHES [[\.\./]])
    message(FATAL_ERROR "expected CUDAToolkit variable CUDA_${cuda_lib}_LIBRARY[\"${CUDA_${cuda_lib}_LIBRARY}\"] to not contain /..")
  endif()
  if(NOT TARGET CUDA::${cuda_lib})
    message(FATAL_ERROR "expected CUDAToolkit target CUDA::${cuda_lib} not found")
  endif()
endforeach()

add_executable(verify test.cu)

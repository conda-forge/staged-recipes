cmake_minimum_required(VERSION 3.8)
project(sample)
find_package(Einsums REQUIRED)
add_executable(timings "main.cpp")
if(APPLE)
    target_compile_definitions(
      timings
      PUBLIC
        _LIBCPP_DISABLE_AVAILABILITY
        H5CPP_USE_OMP_ALIGNED_ALLOC
      )
endif()
target_link_libraries(timings Einsums::einsums)

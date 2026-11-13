cmake_minimum_required(VERSION 3.16)
project(kfr_package_test LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(KFR CONFIG REQUIRED)

add_executable(test_kfr test_kfr.cpp)
target_link_libraries(test_kfr PRIVATE kfr kfr_dft kfr_dsp kfr_io kfr_audio)

add_executable(test_capi test_capi.c)
target_link_libraries(test_capi PRIVATE kfr_capi)

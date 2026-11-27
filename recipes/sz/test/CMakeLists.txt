cmake_minimum_required(VERSION 3.19)
project(sz3_conda_test C CXX)

find_package(SZ3 3.4 REQUIRED COMPONENTS hdf5sz3)

add_executable(test_sz3 test_sz3.cpp)
target_link_libraries(test_sz3 PRIVATE SZ3::SZ3)

# The filter's header is plain C outside its __cplusplus block.
add_executable(test_h5z test_h5z.c)
target_link_libraries(test_h5z PRIVATE SZ3::hdf5sz3)

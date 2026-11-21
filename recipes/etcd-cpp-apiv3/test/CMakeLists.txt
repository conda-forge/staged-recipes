cmake_minimum_required(VERSION 3.16)
project(etcd_cpp_apiv3_test CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(etcd-cpp-api REQUIRED)

add_executable(etcd_test test.cpp)
target_link_libraries(etcd_test PRIVATE etcd-cpp-api-core)

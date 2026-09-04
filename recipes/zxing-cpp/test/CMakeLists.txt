cmake_minimum_required(VERSION 3.16)
project(test_zxing_cpp CXX)

find_package(ZXing CONFIG REQUIRED)

add_executable(test_zxing_cpp main.cpp)
target_link_libraries(test_zxing_cpp PRIVATE ZXing::ZXing)

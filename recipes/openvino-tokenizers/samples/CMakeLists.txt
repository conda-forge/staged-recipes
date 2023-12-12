cmake_minimum_required(VERSION 3.10)

project(hello_tokenizers)

add_executable(hello_tokenizers main.cpp)

find_package(OpenVINO REQUIRED COMPONENTS Runtime)

target_link_libraries(hello_tokenizers PRIVATE openvino::runtime)

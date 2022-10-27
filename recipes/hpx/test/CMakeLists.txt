cmake_minimum_required(VERSION 3.18)
project(HELLO_HPX LANGUAGES CXX)

find_package(HPX REQUIRED)

add_executable(hello_hpx hello_hpx.cpp)

target_link_libraries(hello_hpx
    HPX::hpx
    HPX::wrap_main
    HPX::iostreams_component
)

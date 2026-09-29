cmake_minimum_required(VERSION 3.15)
project(libmoto_consumer LANGUAGES CXX)

find_package(moto 2.3 REQUIRED)

add_executable(libmoto_consumer main.cpp)
target_link_libraries(libmoto_consumer PRIVATE moto::moto)
target_compile_features(libmoto_consumer PRIVATE cxx_std_20)

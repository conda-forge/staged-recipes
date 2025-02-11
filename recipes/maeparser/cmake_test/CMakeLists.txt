cmake_minimum_required(VERSION 3.15...3.27)
project(pymaeparser LANGUAGES CXX)

set (CMAKE_CXX_STANDARD 11)

find_package(Boost COMPONENTS iostreams REQUIRED)
find_package(maeparser CONFIG REQUIRED)

add_executable(test_maeparser test.cpp)

target_link_libraries(test_maeparser PRIVATE maeparser Boost::iostreams)
target_include_directories(test_maeparser PRIVATE ${Boost_INCLUDE_DIRS})

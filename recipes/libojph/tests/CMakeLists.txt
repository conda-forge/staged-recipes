cmake_minimum_required(VERSION 3.15)

project(ojph_consumer LANGUAGES CXX)

find_package(ojph CONFIG REQUIRED)
message(STATUS "Found ojph ${ojph_VERSION} in ${ojph_DIR}")

add_executable(roundtrip roundtrip.cpp)
target_link_libraries(roundtrip PRIVATE ojph::ojph)
target_compile_features(roundtrip PRIVATE cxx_std_14)

enable_testing()
add_test(NAME roundtrip COMMAND roundtrip)

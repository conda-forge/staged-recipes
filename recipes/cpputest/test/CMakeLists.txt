cmake_minimum_required(VERSION 3.15)

# The entire purpose of this project is to test a correct installation of
# CppuTest, by linking a simple executable against it.
project(CppUTestConda)

enable_testing()
find_package(CppUTest REQUIRED)

add_executable(Sanity sanity.cpp)
target_link_libraries(Sanity PRIVATE CppUTest CppUTestExt)
add_test(NAME SanityTest COMMAND Sanity)


cmake_minimum_required(VERSION 3.20)

project(
	test-nanobench
	LANGUAGES CXX
)

add_executable(
	test-nanobench
	test.cpp
)

find_package(nanobench REQUIRED)

target_link_libraries(test-nanobench nanobench::nanobench)

enable_testing()
add_test(NAME test-nanobench COMMAND test-nanobench)

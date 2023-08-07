cmake_minimum_required(VERSION 3.20)

project(
	test-azure-sdk-for-cpp
	LANGUAGES CXX
)

add_executable(
	test-azure-sdk-for-cpp
	test.cpp
)

find_package(azure-core-cpp CONFIG REQUIRED)
target_link_libraries(test-azure-sdk-for-cpp PRIVATE Azure::azure-core)

enable_testing()
add_test(NAME test-azure-sdk-for-cpp COMMAND test-azure-sdk-for-cpp)

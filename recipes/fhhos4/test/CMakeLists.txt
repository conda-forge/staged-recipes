# A client code of the library, for the test of the conda package: find_package(fhhos4) and a solve
cmake_minimum_required(VERSION 3.20)
project(fhhos4_client LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)

find_package(fhhos4 REQUIRED)
if(NOT fhhos4_VERSION VERSION_EQUAL EXPECTED_VERSION)
	message(FATAL_ERROR "fhhos4 ${fhhos4_VERSION} found, ${EXPECTED_VERSION} expected (the version of the recipe)")
endif()

add_executable(fhhos4_client client.cpp)
target_link_libraries(fhhos4_client PRIVATE fhhos4::fhhos4)
target_compile_definitions(fhhos4_client PRIVATE EXPECTED_VERSION="${EXPECTED_VERSION}")

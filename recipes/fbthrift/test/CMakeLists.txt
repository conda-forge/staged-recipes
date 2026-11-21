cmake_minimum_required(VERSION 3.20)
project(fbthrift_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(FBThrift CONFIG REQUIRED)

# A relative IDL path makes the generated sources include each other relative
# to gen-cpp2/.
execute_process(
  COMMAND "${FBTHRIFT_COMPILER}" --gen mstch_cpp2 -o "${CMAKE_BINARY_DIR}" point.thrift
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  COMMAND_ERROR_IS_FATAL ANY
)
file(GLOB generated_sources "${CMAKE_BINARY_DIR}/gen-cpp2/*.cpp")

add_executable(fbthrift_test main.cpp ${generated_sources})
target_include_directories(fbthrift_test PRIVATE "${CMAKE_BINARY_DIR}")
target_link_libraries(fbthrift_test PRIVATE FBThrift::thriftcpp2)

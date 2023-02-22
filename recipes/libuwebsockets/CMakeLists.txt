
cmake_minimum_required(VERSION 3.20)

project(uWebSockets C CXX)

# Dependencies
find_package(YCM REQUIRED)
find_package(uSockets REQUIRED)
find_package(ZLIB REQUIRED)

add_library(uWebSockets INTERFACE)

target_include_directories(uWebSockets INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)

target_link_libraries(uWebSockets INTERFACE uSockets::uSockets ZLIB::ZLIB)
target_compile_features(uWebSockets INTERFACE cxx_std_17)

# Install
file(GLOB UWS_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
install(FILES ${UWS_HDRS} DESTINATION include/uWebSockets)

# Tests
include(CTest)

macro(uws_add_unit_test testname)
  add_executable(${testname} ${CMAKE_CURRENT_SOURCE_DIR}/tests/${testname}.cpp)
  target_link_libraries(${testname} PRIVATE uWebSockets)
  add_test(NAME ${testname} COMMAND ${testname})
endmacro()

if(BUILD_TESTING)
 uws_add_unit_test(BloomFilter)
 uws_add_unit_test(ChunkedEncoding)
 uws_add_unit_test(ExtensionsNegotiator)
 uws_add_unit_test(HttpParser)
 uws_add_unit_test(HttpRouter)
 uws_add_unit_test(TopicTree)
endif()

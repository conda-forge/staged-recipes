
cmake_minimum_required(VERSION 3.20)

project(uSockets C CXX)

# Dependencies
find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(UV REQUIRED IMPORTED_TARGET libuv)

# See https://github.com/uNetworking/uSockets/blob/v0.8.5/Makefile#L66
# and https://github.com/uNetworking/uSockets/blob/v0.8.5/Makefile#L74
file(GLOB US_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c ${CMAKE_CURRENT_SOURCE_DIR}/src/eventing/*.c 
                  ${CMAKE_CURRENT_SOURCE_DIR}/src/crypto/*.c ${CMAKE_CURRENT_SOURCE_DIR}/src/crypto/*.cpp)

add_library(uSockets ${US_SRCS})

target_include_directories(uSockets PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)

target_link_libraries(uSockets PRIVATE OpenSSL::SSL OpenSSL::Crypto PkgConfig::UV)

# See https://github.com/uNetworking/uSockets/blob/v0.8.5/Makefile#L32
# and https://github.com/uNetworking/uSockets/blob/v0.8.5/Makefile#L15
target_compile_definitions(uSockets PRIVATE -DLIBUS_USE_LIBUV -DLIBUS_USE_OPENSSL)
target_compile_features(uSockets PRIVATE cxx_std_17)
set_property(TARGET uSockets PROPERTY WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Install
install(FILES src/libusockets.h DESTINATION include)
install(TARGETS uSockets)

# Tests
include(CTest)
if(BUILD_TESTING)
  # See https://github.com/uNetworking/uSockets/blob/v0.8.5/.github/workflows/c-cpp.yml
  add_executable(hammer_test ${CMAKE_CURRENT_SOURCE_DIR}/examples/hammer_test.c)
  target_link_libraries(hammer_test uSockets)
  add_test(NAME hammer_test
           COMMAND hammer_test)

  add_executable(hammer_test_unix ${CMAKE_CURRENT_SOURCE_DIR}/examples/hammer_test_unix.c)
  target_link_libraries(hammer_test_unix uSockets)
  add_test(NAME hammer_test_unix
           COMMAND hammer_test_unix)

  # http_load_test uses the = {} syntax currently not supported by VS2019
  if(NOT MSVC)
    add_executable(http_load_test ${CMAKE_CURRENT_SOURCE_DIR}/examples/http_load_test.c)
    target_link_libraries(http_load_test uSockets)
    add_test(NAME http_load_test
             COMMAND http_load_test)
  endif()
endif()

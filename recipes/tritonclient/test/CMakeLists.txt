cmake_minimum_required(VERSION 3.15)
project(tritonclient-test LANGUAGES CXX)

find_package(Threads REQUIRED)
find_package(CURL REQUIRED)
find_package(Protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)
find_package(TritonClient CONFIG REQUIRED)

add_executable(tritonclient-test main.cpp)
target_link_libraries(
  tritonclient-test
  PRIVATE
    TritonClient::grpcclient
    TritonClient::httpclient
)

cmake_minimum_required(VERSION 3.14)
project(test LANGUAGES NONE)

set(ASIO_GRPC_DISABLE_AUTOLINK on)
find_package(asio-grpc REQUIRED)

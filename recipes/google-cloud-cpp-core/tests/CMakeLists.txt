cmake_minimum_required(VERSION 3.10...3.24)
project(google-cloud-cpp-quickstart CXX)

find_package(OpenSSL REQUIRED)
find_package(google_cloud_cpp_common REQUIRED)

add_executable(quickstart quickstart.cc)
target_compile_features(quickstart PRIVATE cxx_std_17)
target_link_libraries(quickstart google-cloud-cpp::common)

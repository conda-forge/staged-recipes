cmake_minimum_required(VERSION 3.15)
project(kuba_zip_smoke LANGUAGES C)

find_package(zip 0.3.15 EXACT CONFIG REQUIRED)
add_executable(kuba-zip-smoke smoke.c)
target_link_libraries(kuba-zip-smoke PRIVATE zip::zip)
enable_testing()
add_test(NAME archive-roundtrip COMMAND kuba-zip-smoke)

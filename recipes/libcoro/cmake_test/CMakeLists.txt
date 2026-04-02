project(test_libcoro LANGUAGES CXX)
cmake_minimum_required(VERSION 3.20)

# Verify that pkg-config can find libcoro
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBCORO REQUIRED libcoro)

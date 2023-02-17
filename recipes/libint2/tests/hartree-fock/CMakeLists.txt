cmake_minimum_required(VERSION 3.16)
project(hf++)

if (MSVC)
      set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} $ENV{LIBRARY_PREFIX}")
      set(CMAKE_C_COMPILER "clang-cl")
      set(CMAKE_CXX_COMPILER "clang-cl")
else()
      set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} $ENV{PREFIX}")
endif()

find_package(Threads)
find_package(Libint2 2.7.2 REQUIRED COMPONENTS eri_c4_d0_l2 CXX_ho)
get_target_property(_l2_loc Libint2::int2 LOCATION)
get_target_property(_l2_ver Libint2::int2 Libint2_VERSION)
get_target_property(_l2_mam Libint2::int2 Libint2_MAX_AM_ERI)
message(STATUS "Found Libint2 ${_l2_mam}: ${_l2_loc} (found version ${_l2_ver})")

add_executable(hf++ "hartree-fock++.cc")
target_link_libraries(hf++ Libint2::cxx Threads::Threads)


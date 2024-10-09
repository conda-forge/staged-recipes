cmake_minimum_required(VERSION 3.12)
project(all_headers VERSION 0.1 LANGUAGES C CXX)

find_package(nvpl)

set(ALL_NVPL_TARGETS
    nvpl::scalapack_ilp64
)

add_executable(c_all_headers all_headers.c)
target_link_libraries(c_all_headers PUBLIC ${ALL_NVPL_TARGETS})

add_executable(cxx_all_headers all_headers.cxx)
target_link_libraries(cxx_all_headers PUBLIC ${ALL_NVPL_TARGETS})

include(GNUInstallDirs)
install(TARGETS c_all_headers cxx_all_headers RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

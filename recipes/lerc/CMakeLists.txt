cmake_minimum_required (VERSION 3.11)
project (Lerc)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 14)

file(GLOB SOURCES
    "src/LercLib/*"
    "src/LercLib/Lerc1Decode/*"
    "include"
)
message(STATUS ${SOURCES})

add_library(Lerc SHARED ${SOURCES})

target_link_libraries (Lerc)

install(
    TARGETS Lerc
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(
    FILES "include/Lerc_types.h" "include/Lerc_c_api.h"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

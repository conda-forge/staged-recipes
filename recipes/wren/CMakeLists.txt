cmake_minimum_required(VERSION 3.11)
project (Wren
    VERSION 0.4.0
    DESCRIPTION "Wren: A small, fast, class-based concurrent scripting language"
    HOMEPAGE_URL "https://github.com/wren-lang/wren"
    LANGUAGES C
)

# normalize path
cmake_path(SET NORMALIZE_SRC_DIR NORMALIZE ${SRC_DIR})

# Options
option(WREN_META "Wren Meta Class" ON)
option(WREN_RANDOM "Wren Random Class" ON)
option(WREN_BUILD_STATIC "Wren Static Library" OFF)
option(WREN_BUILD_SHARED "Wren Shared Library" ON)
option(WREN_BUILD_TEST "Build Wren Tests" OFF)

# Source Files
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})
set(WREN_SRC ${NORMALIZE_SRC_DIR}/src)
file(GLOB WREN_SRC_VM_FILES ${WREN_SRC}/vm/*.c)
file(GLOB WREN_SRC_OPTIONAL_FILES ${WREN_SRC}/optional/*.c)
set(WREN_SRC_FILES ${WREN_SRC_VM_FILES} ${WREN_SRC_OPTIONAL_FILES})
set(WREN_INCLUDE_DIRS
    ${WREN_SRC}/include
    ${WREN_SRC}/optional
    ${WREN_SRC}/vm
)

set(WREN_HEADERS
    ${WREN_SRC}/include/wren.h
    ${WREN_SRC}/include/wren.hpp
)

# Defines
set(WREN_DEFINES)
if (WREN_META)
    list(APPEND WREN_DEFINES WREN_OPT_META)
endif()
if (WREN_RANDOM)
    list(APPEND WREN_DEFINES WREN_OPT_RANDOM)
endif()


set(WREN_TARGETS "")

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=generic")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mtune=generic")
endif()

# Wren Libraries
if (WREN_BUILD_STATIC)
    if (CMAKE_HOST_WIN32)
        SET(OUTPUT_NAME "wren-static")
    else()
        SET(OUTPUT_NAME "wren")
    endif()
    add_library(wren-static STATIC ${WREN_SRC_FILES})
    target_include_directories(wren-static PUBLIC ${WREN_INCLUDE_DIRS})
    target_compile_definitions(wren-static PUBLIC ${WREN_DEFINES})
    set_target_properties(wren-static PROPERTIES
                          PUBLIC_HEADER "${WREN_HEADERS}"
                          PREFIX ""
                          VERSION "0.4.0"
                          SOVERSION "0"
                          OUTPUT_NAME "lib${OUTPUT_NAME}")
    list(APPEND WREN_TARGETS wren-static)

endif()
if (WREN_BUILD_SHARED)
    add_library(wren SHARED ${WREN_SRC_FILES})
    target_include_directories(wren PUBLIC ${WREN_INCLUDE_DIRS})
    target_compile_definitions(wren PUBLIC ${WREN_DEFINES})
    set_target_properties(wren PROPERTIES
                          PUBLIC_HEADER "${WREN_HEADERS}"
                          PREFIX ""
                          VERSION "0.4.0"
                          SOVERSION "0"
                          OUTPUT_NAME "libwren")
    list(APPEND WREN_TARGETS wren)
endif()

MESSAGE(STATUS "HEADERS " ${WREN_HEADERS})

include(GNUInstallDirs)
install(TARGETS ${WREN_TARGETS}
            EXPORT ${PROJECT_NAME}-targets
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
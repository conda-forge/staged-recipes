cmake_minimum_required(VERSION 3.12)
project(CaDiCaL VERSION 2.1.3 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configuration options
option(CADICAL_DEBUG "Enable debug mode" OFF)
option(CADICAL_LOGGING "Enable logging" OFF)
option(CADICAL_QUIET "Enable quiet mode" OFF)
option(CADICAL_CONTRACTS "Enable contracts" ON)
option(CADICAL_TRACING "Enable tracing" ON)
option(CADICAL_CONTRIB "Enable contributed code" ON)
option(CADICAL_IPASIR "Enable IPASIR interface" ON)
option(BUILD_SHARED_LIBS "Build shared library" ON)

# Feature detection
include(CheckCXXSourceCompiles)

check_cxx_source_compiles("
#include <cstdlib>
struct S {
  int size;
  int flexible_array_member[];
};
int main() {
  struct S* s = (struct S*)malloc(12);
  s->size = 2;
  s->flexible_array_member[0] = 1;
  return 0;
}
" HAVE_FLEXIBLE_ARRAY_MEMBERS)

check_cxx_source_compiles("
#include <cstdio>
int main() {
  FILE* file = tmpfile();
  if (!file) return 1;
  if (putc_unlocked(42, file) != 42) return 1;
  if (getc_unlocked(file) != 42) return 1;
  fclose(file);
  return 0;
}
" HAVE_UNLOCKED_IO)

check_cxx_source_compiles("
extern \"C\" {
#include <unistd.h>
}
int main() {
  closefrom(0);
  return 0;
}
" HAVE_CLOSEFROM)

if(CADICAL_DEBUG)
    set(CMAKE_BUILD_TYPE Debug)
else()
    set(CMAKE_BUILD_TYPE Release)
    add_compile_definitions(NDEBUG)
endif()

# Feature-based definitions
if(CADICAL_LOGGING)
    add_compile_definitions(LOGGING)
endif()

if(CADICAL_QUIET)
    add_compile_definitions(QUIET)
endif()

if(NOT CADICAL_CONTRACTS)
    add_compile_definitions(NCONTRACTS)
endif()

if(NOT CADICAL_TRACING)
    add_compile_definitions(NTRACING)
endif()

if(NOT CADICAL_CONTRIB)
    add_compile_definitions(NCONTRIB)
endif()

if(NOT CADICAL_IPASIR)
    add_compile_definitions(NIPASIR)
endif()

if(NOT HAVE_FLEXIBLE_ARRAY_MEMBERS)
    add_compile_definitions(NFLEXIBLE)
endif()

if(NOT HAVE_UNLOCKED_IO)
    add_compile_definitions(NUNLOCKED)
endif()

if(NOT HAVE_CLOSEFROM)
    add_compile_definitions(NCLOSEFROM)
endif()

# Generate build.hpp using the original script
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/build.hpp
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/make-build-header.sh > ${CMAKE_CURRENT_BINARY_DIR}/build.hpp
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/scripts/make-build-header.sh
    COMMENT "Generating build.hpp"
)

add_custom_target(build_header DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build.hpp)

# Source files
file(GLOB CADICAL_SOURCES "src/*.cpp")
list(REMOVE_ITEM CADICAL_SOURCES 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/cadical.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/mobical.cpp")

# Remove IPASIR if disabled
if(NOT CADICAL_IPASIR)
    list(REMOVE_ITEM CADICAL_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/ipasir.cpp")
endif()

# Add contrib sources if enabled
if(CADICAL_CONTRIB)
    file(GLOB CONTRIB_SOURCES "contrib/*.cpp")
    list(APPEND CADICAL_SOURCES ${CONTRIB_SOURCES})
endif()

# Library target
if(BUILD_SHARED_LIBS)
    add_library(cadical SHARED ${CADICAL_SOURCES})
    set_target_properties(cadical PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
    )
else()
    add_library(cadical STATIC ${CADICAL_SOURCES})
endif()

target_include_directories(cadical PUBLIC 
    src
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Ensure build.hpp is generated before compiling
add_dependencies(cadical build_header)

# Executables
add_executable(cadical-bin src/cadical.cpp)
target_link_libraries(cadical-bin cadical)
target_include_directories(cadical-bin PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(cadical-bin PROPERTIES OUTPUT_NAME cadical)
add_dependencies(cadical-bin build_header)

add_executable(mobical src/mobical.cpp)
target_link_libraries(mobical cadical)
target_include_directories(mobical PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
add_dependencies(mobical build_header)

# Installation
install(TARGETS cadical cadical-bin mobical
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES src/cadical.hpp src/ccadical.h src/ipasir.h DESTINATION include)

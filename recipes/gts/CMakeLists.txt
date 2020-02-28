# originally copied from https://github.com/finetjul/gts
cmake_minimum_required(VERSION 3.1)
project(gts)

add_executable(predicates_init src/predicates_init.c)

add_custom_command(
  TARGET predicates_init
  POST_BUILD
  COMMAND "$<TARGET_FILE:predicates_init>" > predicates_init.h)

set(srcs
  src/bbtree.c
  src/boolean.c
  src/cdt.c
  src/container.c
  src/curvature.c
  src/edge.c
  src/eheap.c
  src/face.c
  src/fifo.c
  src/graph.c
  src/heap.c
  src/hsurface.c
  src/iso.c
  src/isotetra.c
  src/kdtree.c
  src/matrix.c
  src/misc.c
  src/named.c
  src/object.c
  src/oocs.c
  src/partition.c
  src/pgraph.c
  src/point.c
  src/predicates.c
  src/psurface.c
  src/refine.c
  src/segment.c
  src/split.c
  src/stripe.c
  src/surface.c
  src/triangle.c
  src/tribox3.c
  src/vertex.c
  src/vopt.c
  )

configure_file(src/config.h.win32 config.h)

SET(CMAKE_INCLUDE_CURRENT_DIR ON)
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  )

find_library(glib_LIBRARY NAMES glib libglib glib-2.0 libglib-2.0
             HINTS ${glib_BINARY_DIR})

get_filename_component(glib_LIBRARY_DIR ${glib_LIBRARY} DIRECTORY)
get_filename_component(glib_LIBRARY_NAME ${glib_LIBRARY} NAME)
string(REGEX REPLACE "\\.[^.]*$" "" glib_LIBRARY_NAME ${glib_LIBRARY_NAME})

set(glib_H)
find_path(glib_H
  NAMES glib.h
  PATH_SUFFIXES ${glib_LIBRARY_NAME})

set(glib_CONFIG_H)
find_path(glib_CONFIG_H
  NAMES glibconfig.h
  PATH_SUFFIXES lib/${glib_LIBRARY_NAME}/include)

include_directories(${glib_H} ${glib_CONFIG_H})

add_definitions(-DGTS_COMPILATION)

add_library(gts ${srcs})
target_link_libraries(gts ${glib_LIBRARY})
set_target_properties(gts PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS 1)
add_dependencies(gts predicates_init)

INSTALL(TARGETS gts
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )
INSTALL(FILES
  src/gts.h
  DESTINATION include
  )
INSTALL(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/config.h"
  RENAME gtsconfig.h
  DESTINATION include
  )

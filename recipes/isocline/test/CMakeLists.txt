cmake_minimum_required(VERSION 3.15)
project(isocline_smoke C)

find_path(ISOCLINE_INCLUDE_DIR NAMES isocline.h REQUIRED)
find_library(ISOCLINE_LIBRARY NAMES isocline REQUIRED)
add_executable(isocline-smoke smoke.c)
target_include_directories(isocline-smoke PRIVATE "${ISOCLINE_INCLUDE_DIR}")
target_link_libraries(isocline-smoke PRIVATE "${ISOCLINE_LIBRARY}")

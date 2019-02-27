# From: https://github.com/martinmoene/gsl-lite#user-content-as-cmake-package

cmake_minimum_required( VERSION 3.5 FATAL_ERROR )

find_package( gsl-lite REQUIRED )

project( program-using-gsl-lite LANGUAGES CXX )

add_executable(        program main.cpp )
target_link_libraries( program PRIVATE gsl-lite::gsl-lite )

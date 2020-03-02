#
# mbsolve: An open-source solver tool for the Maxwell-Bloch equations.
#
# Copyright (c) 2016, Computational Photonics Group, Technical University of
# Munich.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

cmake_minimum_required(VERSION 3.6)
project(mbsolve-tool)

find_package(cxxopts REQUIRED)
find_package(mbsolve REQUIRED OPTIONAL_COMPONENTS solver-cpu writer-hdf5)

add_executable(cmake_export_test src/mbsolve-tool.cpp)
set_property(TARGET cmake_export_test PROPERTY CXX_STANDARD 11)
target_link_libraries(cmake_export_test
  PRIVATE cxxopts::cxxopts mbsolve::mbsolve-lib)

if(mbsolve_solver-cpu_FOUND)
  target_link_libraries(cmake_export_test PRIVATE mbsolve::solver-cpu)
  target_compile_definitions(cmake_export_test PRIVATE "-DUSE_CPU=1")
endif()

if(mbsolve_writer-hdf5_FOUND)
  target_link_libraries(cmake_export_test PRIVATE mbsolve::writer-hdf5)
  target_compile_definitions(cmake_export_test PRIVATE "-DUSE_HDF5=1")
endif()

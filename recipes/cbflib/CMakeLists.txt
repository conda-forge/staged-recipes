
######################################################################
#  CMakeLists.txt - cmake build file for make to create CBFlib       #
#                                                                    #
# Version 0.9.6 06 November 2018                                     #
#                                                                    #
#                          Paul Ellis and                            #
#         Herbert J. Bernstein (yaya@bernstein-plus-sons.com)        #
#                                                                    #
# (C) Copyright 2006 - 2018 Herbert J. Bernstein                     #
#                                                                    #
######################################################################

######################################################################
#                                                                    #
# YOU MAY REDISTRIBUTE THE CBFLIB PACKAGE UNDER THE TERMS OF THE GPL #
#                                                                    #
# ALTERNATIVELY YOU MAY REDISTRIBUTE THE CBFLIB API UNDER THE TERMS  #
# OF THE LGPL                                                        #
#                                                                    #
######################################################################

########################### GPL NOTICES ##############################
#                                                                    #
# This program is free software; you can redistribute it and/or      #
# modify it under the terms of the GNU General Public License as     #
# published by the Free Software Foundation; either version 2 of     #
# (the License, or (at your option) any later version.               #
#                                                                    #
# This program is distributed in the hope that it will be useful,    #
# but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      #
# GNU General Public License for more details.                       #
#                                                                    #
# You should have received a copy of the GNU General Public License  #
# along with this program; if not, write to the Free Software        #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA           #
# 02111-1307  USA                                                    #
#                                                                    #
######################################################################

######################### LGPL NOTICES ###############################
#                                                                    #
# This library is free software; you can redistribute it and/or      #
# modify it under the terms of the GNU Lesser General Public         #
# License as published by the Free Software Foundation; either       #
# version 2.1 of the License, or (at your option) any later version. #
#                                                                    #
# This library is distributed in the hope that it will be useful,    #
# but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  #
# Lesser General Public License for more details.                    #
#                                                                    #
# You should have received a copy of the GNU Lesser General Public   #
# License along with this library; if not, write to the Free         #
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,    #
# MA  02110-1301  USA                                                #
#                                                                    #
######################################################################

######################################################################
#                                                                    #
#                    Stanford University Notices                     #
#  for the CBFlib software package that incorporates SLAC software   #
#                 on which copyright is disclaimed                   #
#                                                                    #
# This software                                                      #
# -------------                                                      #
# The term "this software", as used in these Notices, refers to      #
# those portions of the software package CBFlib that were created by #
# employees of the Stanford Linear Accelerator Center, Stanford      #
# University.                                                        #
#                                                                    #
# Stanford disclaimer of copyright                                   #
# --------------------------------                                   #
# Stanford University, owner of the copyright, hereby disclaims its  #
# copyright and all other rights in this software.  Hence, anyone    #
# may freely use it for any purpose without restriction.             #
#                                                                    #
# Acknowledgement of sponsorship                                     #
# ------------------------------                                     #
# This software was produced by the Stanford Linear Accelerator      #
# Center, Stanford University, under Contract DE-AC03-76SFO0515 with #
# the Department of Energy.                                          #
#                                                                    #
# Government disclaimer of liability                                 #
# ----------------------------------                                 #
# Neither the United States nor the United States Department of      #
# Energy, nor any of their employees, makes any warranty, express or #
# implied, or assumes any legal liability or responsibility for the  #
# accuracy, completeness, or usefulness of any data, apparatus,      #
# product, or process disclosed, or represents that its use would    #
# not infringe privately owned rights.                               #
#                                                                    #
# Stanford disclaimer of liability                                   #
# --------------------------------                                   #
# Stanford University makes no representations or warranties,        #
# express or implied, nor assumes any liability for the use of this  #
# software.                                                          #
#                                                                    #
# Maintenance of notices                                             #
# ----------------------                                             #
# In the interest of clarity regarding the origin and status of this #
# software, this and all the preceding Stanford University notices   #
# are to remain affixed to any copy or derivative of this software   #
# made or distributed by the recipient and are to be affixed to any  #
# copy of software made or distributed by the recipient that         #
# contains a copy or derivative of this software.                    #
#                                                                    #
# Based on SLAC Software Notices, Set 4                              #
# OTT.002a, 2004 FEB 03                                              #
######################################################################



######################################################################
#                               NOTICE                               #
# Creative endeavors depend on the lively exchange of ideas. There   #
# are laws and customs which establish rights and responsibilities   #
# for authors and the users of what authors create.  This notice     #
# is not intended to prevent you from using the software and         #
# documents in this package, but to ensure that there are no         #
# misunderstandings about terms and conditions of such use.          #
#                                                                    #
# Please read the following notice carefully.  If you do not         #
# understand any portion of this notice, please seek appropriate     #
# professional legal advice before making use of the software and    #
# documents included in this software package.  In addition to       #
# whatever other steps you may be obliged to take to respect the     #
# intellectual property rights of the various parties involved, if   #
# you do make use of the software and documents in this package,     #
# please give credit where credit is due by citing this package,     #
# its authors and the URL or other source from which you obtained    #
# it, or equivalent primary references in the literature with the    #
# same authors.                                                      #
#                                                                    #
# Some of the software and documents included within this software   #
# package are the intellectual property of various parties, and      #
# placement in this package does not in any way imply that any       #
# such rights have in any way been waived or diminished.             #
#                                                                    #
# With respect to any software or documents for which a copyright    #
# exists, ALL RIGHTS ARE RESERVED TO THE OWNERS OF SUCH COPYRIGHT.   #
#                                                                    #
# Even though the authors of the various documents and software      #
# found here have made a good faith effort to ensure that the        #
# documents are correct and that the software performs according     #
# to its documentation, and we would greatly appreciate hearing of   #
# any problems you may encounter, the programs and documents any     #
# files created by the programs are provided **AS IS** without any   *
# warranty as to correctness, merchantability or fitness for any     #
# particular or general use.                                         #
#                                                                    #
# THE RESPONSIBILITY FOR ANY ADVERSE CONSEQUENCES FROM THE USE OF    #
# PROGRAMS OR DOCUMENTS OR ANY FILE OR FILES CREATED BY USE OF THE   #
# PROGRAMS OR DOCUMENTS LIES SOLELY WITH THE USERS OF THE PROGRAMS   #
# OR DOCUMENTS OR FILE OR FILES AND NOT WITH AUTHORS OF THE          #
# PROGRAMS OR DOCUMENTS.                                             #
######################################################################

######################################################################
#                                                                    #
#                           The IUCr Policy                          #
#      for the Protection and the Promotion of the STAR File and     #
#     CIF Standards for Exchanging and Archiving Electronic Data     #
#                                                                    #
# Overview                                                           #
#                                                                    #
# The Crystallographic Information File (CIF)[1] is a standard for   #
# information interchange promulgated by the International Union of  #
# Crystallography (IUCr). CIF (Hall, Allen & Brown, 1991) is the     #
# recommended method for submitting publications to Acta             #
# Crystallographica Section C and reports of crystal structure       #
# determinations to other sections of Acta Crystallographica         #
# and many other journals. The syntax of a CIF is a subset of the    #
# more general STAR File[2] format. The CIF and STAR File approaches #
# are used increasingly in the structural sciences for data exchange #
# and archiving, and are having a significant influence on these     #
# activities in other fields.                                        #
#                                                                    #
# Statement of intent                                                #
#                                                                    #
# The IUCr's interest in the STAR File is as a general data          #
# interchange standard for science, and its interest in the CIF,     #
# a conformant derivative of the STAR File, is as a concise data     #
# exchange and archival standard for crystallography and structural  #
# science.                                                           #
#                                                                    #
# Protection of the standards                                        #
#                                                                    #
# To protect the STAR File and the CIF as standards for              #
# interchanging and archiving electronic data, the IUCr, on behalf   #
# of the scientific community,                                       #
#                                                                    #
# # holds the copyrights on the standards themselves,                *
#                                                                    #
# # owns the associated trademarks and service marks, and            *
#                                                                    #
# # holds a patent on the STAR File.                                 *
#                                                                    #
# These intellectual property rights relate solely to the            #
# interchange formats, not to the data contained therein, nor to     #
# the software used in the generation, access or manipulation of     #
# the data.                                                          #
#                                                                    #
# Promotion of the standards                                         #
#                                                                    #
# The sole requirement that the IUCr, in its protective role,        #
# imposes on software purporting to process STAR File or CIF data    #
# is that the following conditions be met prior to sale or           #
# distribution.                                                      #
#                                                                    #
# # Software claiming to read files written to either the STAR       *
# File or the CIF standard must be able to extract the pertinent     #
# data from a file conformant to the STAR File syntax, or the CIF    #
# syntax, respectively.                                              #
#                                                                    #
# # Software claiming to write files in either the STAR File, or     *
# the CIF, standard must produce files that are conformant to the    #
# STAR File syntax, or the CIF syntax, respectively.                 #
#                                                                    #
# # Software claiming to read definitions from a specific data       *
# dictionary approved by the IUCr must be able to extract any        #
# pertinent definition which is conformant to the dictionary         #
# definition language (DDL)[3] associated with that dictionary.      #
#                                                                    #
# The IUCr, through its Committee on CIF Standards, will assist      #
# any developer to verify that software meets these conformance      #
# conditions.                                                        #
#                                                                    #
# Glossary of terms                                                  #
#                                                                    #
# [1] CIF:  is a data file conformant to the file syntax defined     #
# at http://www.iucr.org/iucr-top/cif/spec/index.html                #
#                                                                    #
# [2] STAR File:  is a data file conformant to the file syntax       #
# defined at http://www.iucr.org/iucr-top/cif/spec/star/index.html   #
#                                                                    #
# [3] DDL:  is a language used in a data dictionary to define data   #
# items in terms of "attributes". Dictionaries currently approved    #
# by the IUCr, and the DDL versions used to construct these          #
# dictionaries, are listed at                                        #
# http://www.iucr.org/iucr-top/cif/spec/ddl/index.html               #
#                                                                    #
# Last modified: 30 September 2000                                   #
#                                                                    #
# IUCr Policy Copyright (C) 2000 International Union of              #
# Crystallography                                                    #
######################################################################

######################################################################
#  CMakeLists.txt for CBFlib                                         #
#                                                                    #
#  Assumed directory structure                                       #
#    CBFlib_SOURCE_DIR        CBFlib kit containing this file        #
#      doc                    Directory with documentation           #
#      examples               Directory with example programs        #
#      include                Directory with header files            #
#      m4                     Directory with m4 files                #
#      src                    Directory with source files            #
#                                                                    #
#    CBFlib_BINARY_DIR        CBFlib build directory                 #
#                               usually ${CBFlib_SOURCE_DIR}/build   #
#      external_packages      Directory for libtiff, etc.      #
#        regex-20090805                                              #
#        zlib-1.2.8                                                  #
#      data_files             Directory for test files               #
#      bin                    Directory for executable programs      #
#      include                Directory with build-created headers   #
#      src                    Directory with build-created source    #
#                                                                    #
######################################################################

# Currently limited by - (~ means ignored as not used)
#              ~3.19  hdf5 targets included by default
#               3.5   cmake_parse_arguments
#               3.9   Per-language HDF5 include in FindHDF5
#              ~3.12  add_compile_definitions
#              ~3.12  TARGET_NAME_IF_EXISTS
cmake_minimum_required(VERSION 3.12)

######################################################################
#
#   Convenience macros and functions
#
#
######################################################################

# ::
#   set_from_cached_environment( <var-out> FROM <env-var>
#                                          DEFAULT <default-value>
#                                          [ADVANCED])
#
# Load (and cache) a variable from the environment, if not otherwise set
# at configuration time by e.g. -D<var-out>=something.  If the
# environment variable is empty, then the default value will be used.
# This will only be read from the environment on first configuration.
#
# This behaves in a similar way to other "standard" environment
# variables, like CFLAGS or FFLAGS (which are handled internally). Once
# first configured, these can be edited by reconfiguration/ccmake/gui.
#
# If ADVANCED is passed, the cache variable will be marked as such.
#
macro(set_from_cached_environment target)
    cmake_parse_arguments(_SETENV "ADVANCED" "FROM;DEFAULT;DOC" "" ${ARGN})
    if(NOT DEFINED "${target}")
        if(NOT "$ENV{${_SETENV_FROM}}" STREQUAL "")
            set("${target}" $ENV{${_SETENV_FROM}} CACHE STRING "${_SETENV_DOC}")
        else()
            set("${target}" ${_SETENV_DEFAULT} CACHE STRING "${_SETENV_DOC}")
        endif()
        if(_SETENV_ADVANCED)
            mark_as_advanced("${target}")
        endif()
    endif()
endmacro()

# ::
#   CBF_LOAD_TARBALL(<url> <destination-dir>)
#
# Download a .tar.gz file from <url> and extract it into <destination-dir>.
# The download will not happen if the <destination-dir> already exists.
#
function(CBF_LOAD_TARBALL URL TARGET_DIRECTORY)
    if(NOT EXISTS ${TARGET_DIRECTORY})
        message(STATUS "Downloading ${URL}\n            to ${TARGET_DIRECTORY}.tar.gz")
        file(DOWNLOAD "${URL}" "${TARGET_DIRECTORY}.tar.gz" SHOW_PROGRESS STATUS _status)
        # Check this succeeded
        list(GET STATUS 0 _errorcode)
        list(GET STATUS 1 _errormessage)
        # Get the destination directory to extract from
        get_filename_component(WORK_DIR ${TARGET_DIRECTORY} DIRECTORY)
        if(NOT _errorcode)
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar xzvf ${TARGET_DIRECTORY}.tar.gz
                WORKING_DIRECTORY ${WORK_DIR}
            )
            execute_process(
            COMMAND ${CMAKE_COMMAND} -E remove ${TARGET_DIRECTORY}.tar.gz
            )
        else()
            message(WARNING "Could not download ${URL}: ${_errormessage}.")
            message(WARNING "Continuing build, but tests may not run. Configure -DBUILD_TESTING=no to prevent attempt.")
        endif()
    endif()
endfunction()

# ::
#   read_cbf_version(<version-var> <cbf-version-var> <cbf-api-var>)
#
# Read the cbf.h project file to extract:
#   version-var:        Version string without subrelease, suitable for
#                       passing to project()
#   cbf-version-var:    Version string including optional subrelease, if
#                       it is present.
#   cbf-api-var:        API version string
#
function(read_cbf_version version_var cbf_version_var cbf_api_version_var)
    # Read the version out of the source files before configuring the project
    file(READ include/cbf.h CBFlib_cbf_h_contents)
    string(REGEX REPLACE ".*#define[ \t]+CBF_VERS_MAJOR[ \t]+([0-9]*).*$"
        "\\1" CBF_VERS_MAJOR ${CBFlib_cbf_h_contents})
    string(REGEX REPLACE ".*#define[ \t]+CBF_VERS_MINOR[ \t]+([0-9]*).*$"
        "\\1" CBF_VERS_MINOR ${CBFlib_cbf_h_contents})
    string(REGEX REPLACE ".*#define[ \t]+CBF_VERS_RELEASE[ \t]+([0-9.]*).*$"
        "\\1" CBF_VERS_RELEASE ${CBFlib_cbf_h_contents})
    string(REGEX REPLACE ".*#define[ \t]+CBF_VERS_SUBRELEASE[ \t]+\"([0-9A-Za-z.]*)\".*$"
        "\\1" CBF_VERS_SUBRELEASE ${CBFlib_cbf_h_contents})

    string(REGEX REPLACE ".*#define[ \t]+CBF_APIVERS_CUR[ \t]+([0-9]*).*$"
        "\\1" CBF_APIVERS_CUR ${CBFlib_cbf_h_contents})
    string(REGEX REPLACE ".*#define[ \t]+CBF_APIVERS_REV[ \t]+([0-9]*).*$"
        "\\1" CBF_APIVERS_REV ${CBFlib_cbf_h_contents})
    string(REGEX REPLACE ".*#define[ \t]+CBF_APIVERS_AGE[ \t]+([0-9]*).*$"
        "\\1" CBF_APIVERS_AGE ${CBFlib_cbf_h_contents})

    # Get the "Full Name" version, including subrelease notation. This is
    # used for e.g. grabbing the test data tarballs.
    if(CBF_VERS_SUBRELEASE)
        set("${cbf_version_var}"
            "${CBF_VERS_MAJOR}.${CBF_VERS_MINOR}.${CBF_VERS_RELEASE}-${CBF_VERS_SUBRELEASE}"
            PARENT_SCOPE
        )
    else()
        set("${cbf_version_var}"
            "${CBF_VERS_MAJOR}.${CBF_VERS_MINOR}.${CBF_VERS_RELEASE}"
            PARENT_SCOPE
        )
    endif()
    set("${version_var}"
        "${CBF_VERS_MAJOR}.${CBF_VERS_MINOR}.${CBF_VERS_RELEASE}"
        PARENT_SCOPE
    )
    set("${cbf_api_version_var}"
        "${CBF_APIVERS_CUR}.${CBF_APIVERS_REV}.${CBF_APIVERS_AGE}"
        PARENT_SCOPE
    )
endfunction()

# ::
#   add_target( <name>
#               source1 [source2 ...]
#               [LINKS <link_library> [<link_library> ...]]
#             )
#
# Convenience function for adding a target executable with it's
# dependencies in a single command. If specified, LINKS will be added to
# the target with target_link_libraries(...)
#
function(add_target target)
    cmake_parse_arguments(AT "" "" "LINKS" ${ARGN})
    add_executable(${target} ${AT_UNPARSED_ARGUMENTS})
    if(AT_LINKS)
        target_link_libraries(${target} ${AT_LINKS})
    endif()
endfunction()

######################################################################
#
# Main configuration vars
#
# If you don't want the defaults, set these either on configuration
# via -DUSE_XXX=on, or via ccmake or the CMake Gui.
#
######################################################################

# Use "Location" based search for python, instead of max-version
cmake_policy(SET CMP0094 NEW)

option(USE_FORTRAN          "Build Fortran Bindings"    OFF)
option(USE_TIFF             "Build tiff2cbf"            ON)
option(USE_ULP              "Build using cbf_ulp"       OFF)

option(BUILD_SHARED_LIBS    "Build Shared libraries (instead of Static)" ON)
option(BUILD_PYCBF          "Build the PyCBF bindings" OFF)

option(DONT_USE_LONG_LONG   "If set, disable usage of long long" OFF)

# HDF5 Version required. This is interpreted exactly.
set(HDF5_VERSION_REQUIRED 1.10)

# Values loaded from environment variables

# M4 can be overridden by user flags but has a default definition
set_from_cached_environment(
    M4_FLAGS
    FROM M4FLAGS
    DEFAULT "-Dfcb_bytes_in_rec=4096"
    DOC "Flags to pass to M4"
    ADVANCED)

# set(CBF_HDF5REGISTER_MANUAL_ENV $ENV{CBF_HDF5REGISTER_MANUAL})

######################################################################
#
# Build logic
#
######################################################################


read_cbf_version(PROJECT_VERSION CBF_VERSION CBF_APIVERSION)
message(STATUS "CBFLib Version is ${CBF_VERSION} (${CBF_APIVERSION} API)")

project(CBFlib VERSION ${PROJECT_VERSION} LANGUAGES C)

# Check for other languages
if(USE_FORTRAN)
    enable_language(Fortran)
endif()

if(BUILD_TESTING)
    # A couple of the tests are written in C++
    enable_language(CXX)
endif()

include(CTest)

# Build-niceties diagnostics: Force colour on when using Ninja
option(FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." TRUE)
if(${FORCE_COLORED_OUTPUT})
    if("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
        add_compile_options($<$<COMPILE_LANGUAGE:C>:-fdiagnostics-color=always>)
    elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
        add_compile_options($<$<COMPILE_LANGUAGE:C>:-fcolor-diagnostics>)
    endif()
endif()

# make sure that the default configuration is Release
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ..."
        FORCE
    )
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
        "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Set definitions based on options. Do this globally instead of per
# target because we know we want that.

if(USE_ULP)
    add_compile_definitions(CBF_USE_ULP)
endif()

if(DONT_USE_LONG_LONG)
    add_compile_definitions(CBF_DONT_USE_LONG_LONG)
endif()

# Fortran compilation requires -fno-range-checks. Note: This uses
# CMake "generator expression" syntax to only add for fortran targets.
add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-fno-range-check>)

#
#  Favor static libraries
#
# if(WIN32)
#     set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
# else(WIN32)
#     set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
# endif(WIN32)

#
# Directories
#

#
# Directories on the kit side
#
set(CBF__SRC       "${CBFlib_SOURCE_DIR}/src")
set(CBF__INCLUDE   "${CBFlib_SOURCE_DIR}/include")
set(CBF__M4        "${CBFlib_SOURCE_DIR}/m4")
# set(CBF__DOC       "${CBFlib_SOURCE_DIR}/doc")
set(CBF__EXAMPLES  "${CBFlib_SOURCE_DIR}/examples")
# set(CBF__EXTERNAL_PACKAGES "${CBFlib_SOURCE_DIR}/external_packages")
set(CBF__DECTRIS_EXAMPLES  "${CBF__EXAMPLES}/dectris_cbf_template_test")

#
# Directories on the build side
#
set(CBF__BLDSRC    "${CBFlib_BINARY_DIR}/src")
set(CBF__BLDEXMP   "${CBFlib_BINARY_DIR}/src")
set(CBF__BIN       "${CBFlib_BINARY_DIR}/bin")
set(CBF__LIB       "${CBFlib_BINARY_DIR}/lib")
set(CBF__BIN_INCLUDE "${CBFlib_BINARY_DIR}/include")
set(CBF__SHARE     "${CBFlib_BINARY_DIR}/share")
set(CBF__EXT_PKG   "${CBFlib_BINARY_DIR}/external_packages")
# Location of data files could be specifically set for e.g. common locations
set_from_cached_environment(CBF__DATA FROM CBF_DATA_FILES DEFAULT "${CBFlib_BINARY_DIR}/data_files")

message(STATUS "Using ${CBF__DATA} for test data files")
set(HDF5_PLUGIN_PATH ${CBF__LIB})

#
# CBF_REQUIRE_DIRECTORY -- require directory dir
#
macro(CBF_REQUIRE_DIRECTORY dir)
  if(NOT EXISTS "${dir}")
    file(MAKE_DIRECTORY "${dir}")
  endif()
endmacro()

CBF_REQUIRE_DIRECTORY(${CBF__BLDSRC})
CBF_REQUIRE_DIRECTORY(${CBF__BLDEXMP})
CBF_REQUIRE_DIRECTORY(${CBF__BIN})
CBF_REQUIRE_DIRECTORY(${CBF__LIB})
CBF_REQUIRE_DIRECTORY(${CBF__BIN_INCLUDE})
CBF_REQUIRE_DIRECTORY(${CBF__SHARE})
CBF_REQUIRE_DIRECTORY(${CBF__EXT_PKG})
CBF_REQUIRE_DIRECTORY(${CBF__DATA})


# set(JCBF      "${CBFlib_SOURCE_DIR}/jcbf" CACHE STRING "")
# set(JAVADIR   "${CBFlib_SOURCE_DIR}/java" CACHE STRING "")
# set(BIN       "${CBFlib_BINARY_DIR}/bin" CACHE STRING "")
set(PYCBF     "${CBFlib_SOURCE_DIR}/pycbf" CACHE STRING "")
set(EXAMPLES  "${CBFlib_SOURCE_DIR}/examples" CACHE STRING "")
set(DECTRIS_EXAMPLES "${EXAMPLES}/dectris_cbf_template_test" CACHE STRING "")
# set(MINICBF_TEST "${CBFlib_SOURCE_DIR}/minicbf_test" CACHE STRING "")
# set(GRAPHICS  "${CBFlib_SOURCE_DIR}/html_graphics" CACHE STRING "")


if(USE_TIFF)
    find_package(TIFF REQUIRED)

    include(CheckCSourceCompiles)
    set(CMAKE_REQUIRED_LIBRARIES ${TIFF_LIBRARIES})
    check_c_source_compiles(
        "#include \"stdio.h\"\nint TIFFSNPrintDirectory(); int main(void) { printf(\"%p\", &TIFFSNPrintDirectory); }"
        TIFF_HAS_SNPRINT
    )

    if(NOT TIFF_HAS_SNPRINT)
        message(SEND_ERROR "Found libtiff, but tiff2cbf depends on a custom fork with symbol TIFFSNPrintDirectory, which is missing.")
    endif()
endif()



if(USE_FORTRAN)
    find_package(HDF5 ${HDF5_VERSION_REQUIRED} EXACT REQUIRED COMPONENTS C Fortran)
else()
    find_package(HDF5 ${HDF5_VERSION_REQUIRED} EXACT REQUIRED COMPONENTS C)
endif()

# Backport the CMake 3.19 HDF5 target definitions
if(NOT TARGET HDF5::HDF5 AND HDF5_FOUND)
    if(NOT TARGET HDF5::HDF5)
        add_library(HDF5::HDF5 INTERFACE IMPORTED)
        string(REPLACE "-D" "" _hdf5_definitions "${HDF5_DEFINITIONS}")
        set_target_properties(HDF5::HDF5 PROPERTIES
            INTERFACE_LINK_LIBRARIES "${HDF5_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${HDF5_INCLUDE_DIRS}"
            INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}")
        unset(_hdf5_definitions)
    endif()

    if(HDF5_C_LIBRARIES AND NOT TARGET "hdf5::hdf5")
        add_library("hdf5::hdf5" INTERFACE IMPORTED)
        string(REPLACE "-D" "" _hdf5_definitions "${HDF5_C_DEFINITIONS}")
        set_target_properties("hdf5::hdf5" PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${HDF5_C_INCLUDE_DIRS}"
            INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}"
            INTERFACE_LINK_LIBRARIES "HDF5::HDF5")
        unset(_hdf5_definitions)
    endif()

    if(HDF5_Fortran_LIBRARIES AND NOT TARGET "hdf5::hdf5_fortran")
        add_library("hdf5::hdf5_fortran" INTERFACE IMPORTED)
        string(REPLACE "-D" "" _hdf5_definitions "${HDF5_Fortran_DEFINITIONS}")
        set_target_properties("hdf5::hdf5_fortran" PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${HDF5_Fortran_INCLUDE_DIRS}"
            INTERFACE_COMPILE_DEFINITIONS "${_hdf5_definitions}")
        unset(_hdf5_definitions)
    endif()
endif()

# Use this to turn on LZ4/Bitshuffle....
# It looks like this is manually registering the plugins - shouldn't this
# be picked up by HDF5 automatically?
#target_compile_definitions(hdf5::hdf5 INTERFACE CBF_H5Z_USE_LZ4 CBF_H5Z_USE_BSHUF)

# Handle cif2cbf HDF5 "register"" logic...
option(CBF_HDF5REGISTER_MANUAL "Should cif2cbf tests use --register=manual (=plugin if off)" OFF)
set(CBF_HDF5REGISTER_ARG "--register")
if (CBF_HDF5REGISTER_MANUAL_ENV)
  set(CBF_HDF5REGISTER_VAL "manual")
else ()
  set(CBF_HDF5REGISTER_VAL "plugin")
endif ()

#
# URLs from which to retrieve needed external package snapshots
#
# We give two REGEX packages, the old 1993 regex release for
#    compatability with older CBFlib release Makefiles
#    and a recent PCRE for use in the future.  Only the PCRE
#    version is used for cmake builds
#
# set(CBF_REGEX    "regex-20090805")
# set(CBF_PCRE     "pcre-8.33")
# set(CBF_REGEXURL "http://downloads.sf.net/cbflib/${CBF_REGEX}.tar.gz")
# set(CBF_PCREURL  "http://downloads.sf.net/cbflib/${CBF_PCRE}.tar.gz")


#
# CBF_REGEX or CBF_PCRE
#
# Need to get:
# - an include directory
# - a library to link against
# - an (optional) dependency to build
#
# Try for PCRE first
if(NOT TARGET regex)
    find_library(CBF_REGEXLIB pcre)
    find_path(CBF_REGEXLIB_INCLUDE_DIR NAMES pcreposix.h)
    if(CBF_REGEXLIB AND CBF_REGEXLIB_INCLUDE_DIR)
        message(STATUS "Found pcre: ${CBF_REGEXLIB} with ${CBF_REGEXLIB_INCLUDE_DIR}")
        add_library("regex" INTERFACE IMPORTED)
        set_target_properties("regex" PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CBF_REGEXLIB_INCLUDE_DIR}"
            INTERFACE_LINK_LIBRARIES "${CBF_REGEXLIB}")
        target_compile_definitions(regex INTERFACE CBF_REGEXLIB_PCRE)
    else()
        # PCRE not found, try for REGEX
        message(STATUS "pcre library not found, looking for libregex")
        find_library(CBF_REGEXLIB regex)
        find_path(CBF_REGEXLIB_INCLUDE_DIR NAMES regex.h)
        if(CBF_REGEXLIB AND CBF_REGEXLIB_INCLUDE_DIR)
            message(STATUS "Found regex: ${CBF_REGEXLIB} with ${CBF_REGEXLIB_INCLUDE_DIR}")
            set_target_properties("regex" PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${CBF_REGEXLIB_INCLUDE_DIR}"
                INTERFACE_LINK_LIBRARIES "${CBF_REGEXLIB}")
            target_compile_definitions(regex INTERFACE DCBF_REGEXLIB_REGEX)
        else()
            message(SEND_ERROR "Neither pcre nor regex libraries found")
        endif()
            # Neither PCRE not REGEX found
        # endif()
        # # message(STATUS "CBF_REGEXLIB_INCLUDE_DIR for regex.h = '${CBF_REGEXLIB_INCLUDE_DIR}'")
        # # message(STATUS "CBF_REGEXLIB = '${CBF_REGEXLIB}'")
        # if(NOT CBF_REGEXLIB_INCLUDE_DIR OR NOT CBF_REGEXLIB)
        #     message(STATUS "'regex' library not found")
        #     ExternalProject_add(
        #         PCRE
        #         URL ${CBF_PCREURL}
        #         SOURCE_DIR ${CMAKE_BINARY_DIR}/external_packages/${CBF_PCRE}
        #         CMAKE_ARGS
        #             -DCMAKE_BUILD_TYPE:STRING=RELEASE DEBUG
        #             -DCMAKE_INSTALL_PREFIX:PATH=${CBFlib_BINARY_DIR}/${CBF_PCRE}
        #         INSTALL_DIR ${CBFlib_BINARY_DIR}/${CBF_PCRE}
        #     )
        #     set(CBF_RE "PCRE")
        #     set(CBF_REGEXLIB_INCLUDE_DIR ${CMAKE_BINARY_DIR}/${CBF_PCRE}/include)
        #     set(CBF_REGEXLIB_LIBRARY_PATH ${CBFlib_BINARY_DIR}/${CBF_PCRE}/lib/libpcre.a)
        #     add_definitions(-DCBF_REGEXLIB_PCRE)

    endif()
endif()

#
# Data Directories
#
set(CBF_DATADIRI  "${CBF__DATA}/CBFlib_${CBF_VERSION}_Data_Files_Input")
set(CBF_DATADIRO  "${CBF__DATA}/CBFlib_${CBF_VERSION}_Data_Files_Output")
set(CBF_DATADIRS  "${CBF__DATA}/CBFlib_${CBF_VERSION}_Data_Files_Output_Sigs_Only")
#
# URLs from which to retrieve the data directories
#
set(CBF_DATAURLBASE "https://downloads.sf.net/cbflib")
set(CBF_DATAURLI  "${CBF_DATAURLBASE}/CBFlib_${CBF_VERSION}_Data_Files_Input.tar.gz")
set(CBF_DATAURLO  "${CBF_DATAURLBASE}/CBFlib_${CBF_VERSION}_Data_Files_Output.tar.gz")
set(CBF_DATAURLS  "${CBF_DATAURLBASE}/CBFlib_${CBF_VERSION}_Data_Files_Output_Sigs_Only.tar.gz")
#
# Load and unpack the Data Files
#
if(BUILD_TESTING)
    CBF_LOAD_TARBALL(${CBF_DATAURLI} ${CBF_DATADIRI})
    CBF_LOAD_TARBALL(${CBF_DATAURLO} ${CBF_DATADIRO})
    CBF_LOAD_TARBALL(${CBF_DATAURLS} ${CBF_DATADIRS})
endif()

#
# Verify the checksums
#
file(GLOB CBF_DATADIRI_FILES "${CBF_DATADIRI}/*")
file(GLOB CBF_DATADIRO_FILES "${CBF_DATADIRO}/*")
foreach(loop_file ${CBF_DATADIRI_FILES})
    if(NOT "${loop_file}" MATCHES "[*.]md5")
        file(MD5 "${loop_file}" loop_file_md5)
        file(STRINGS "${loop_file}.md5" loop_file_md5_orig LIMIT_COUNT 1)
        if(NOT ("${loop_file_md5}" STREQUAL "${loop_file_md5_orig}"))
            message(WARNINH "loop_file: ${loop_file}:|${loop_file_md5}|${loop_file_md5_orig}|")
        endif()
    endif()
endforeach()
foreach(loop_file ${CBF_DATADIRO_FILES})
    if(NOT "${loop_file}" MATCHES "[*.]md5")
        file(MD5 "${loop_file}" loop_file_md5)
        file(STRINGS "${loop_file}.md5" loop_file_md5_orig LIMIT_COUNT 1)
        if(NOT ("${loop_file_md5}" STREQUAL "${loop_file_md5_orig}"))
            message(WARNING "loop_file: ${loop_file}:|${loop_file_md5}|${loop_file_md5_orig}|")
        endif()
    endif()
endforeach()


#
# Source files
#
set(CBF_C_SOURCES
    src/cbf.c
    src/cbf_alloc.c
    src/cbf_ascii.c
    src/cbf_binary.c
    src/cbf_byte_offset.c
    src/cbf_canonical.c
    src/cbf_codes.c
    src/cbf_compress.c
    src/cbf_context.c
    src/cbf_copy.c
    src/cbf_file.c
    src/cbf_getopt.c
    src/cbf_nibble_offset.c
    src/cbf_packed.c
    src/cbf_predictor.c
    src/cbf_read_binary.c
    src/cbf_read_mime.c
    src/cbf_simple.c
    src/cbf_string.c
    src/cbf_stx.c
    src/cbf_tree.c
    src/cbf_uncompressed.c
    src/cbf_ulp.c
    src/cbf_write.c
    src/cbf_write_binary.c
    src/cbf_ws.c
    src/md5c.c
    src/img.c
    src/cbf_airy_disk.c
    src/cbf_minicbf_header.c
    src/cbff.c
    src/cbf_lex.c
    src/cbf_hdf5.c
    src/cbf_hdf5_filter.c
)

if(USE_FORTRAN)
    set(
        CBF_F90_BUILT_SOURCES
        ${CBF__BLDSRC}/fcb_exit_binary.f90
        ${CBF__BLDSRC}/fcb_next_binary.f90
        ${CBF__BLDSRC}/fcb_open_cifin.f90
        ${CBF__BLDSRC}/fcb_packed.f90
        ${CBF__BLDSRC}/fcb_read_bits.f90
        ${CBF__BLDSRC}/fcb_read_image.f90
        ${CBF__BLDSRC}/fcb_read_xds_i2.f90
    )

    set(
        CBF_F90_SOURCES
        src/fcb_atol_wcnt.f90
        src/fcb_ci_strncmparr.f90
        src/fcb_nblen_array.f90
        src/fcb_read_byte.f90
        src/fcb_read_line.f90
        src/fcb_skip_whitespace.f90
    )
endif()


# RPATH Handling - from https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling
# # use, i.e. don't skip the full RPATH for the build tree
# set(CMAKE_SKIP_BUILD_RPATH  FALSE)

# # when building, don't use the install RPATH already
# # (but later on when installing)
# set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# Make sure we write out the target location to the installed RPATH
# set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# the RPATH to be used when installing, but only if it's not a system directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()


#
# Header files
#
set(CBF_HEADERS
    include/cbf.h
    include/cbf_alloc.h
    include/cbf_ascii.h
    include/cbf_binary.h
    include/cbf_byte_offset.h
    include/cbf_canonical.h
    include/cbf_codes.h
    include/cbf_compress.h
    include/cbf_context.h
    include/cbf_copy.h
    include/cbf_file.h
    include/cbf_getopt.h
    include/cbf_hdf5.h
    include/cbf_hdf5_filter.h
    include/cbf_lex.h
    include/cbf_nibble_offset.h
    include/cbf_packed.h
    include/cbf_predictor.h
    include/cbf_read_binary.h
    include/cbf_read_mime.h
    include/cbf_simple.h
    include/cbf_string.h
    include/cbf_stx.h
    include/cbf_tree.h
    include/cbf_uncompressed.h
    include/cbf_ulp.h
    include/cbf_write.h
    include/cbf_write_binary.h
    include/cbf_ws.h
    include/global.h
    include/cbff.h
    include/md5.h
    include/img.h
)


if(USE_FORTRAN)
    #
    # m4 FCB library macro files
    #
    set(CBF_M4_FCB_DEFINES ${CBF__M4}/fcblib_defines.m4)

    set(
        CBF_M4_FCB_FILES
        ${CBF__M4}/fcb_exit_binary.m4
        ${CBF__M4}/fcb_next_binary.m4
        ${CBF__M4}/fcb_open_cifin.m4
        ${CBF__M4}/fcb_packed.m4
        ${CBF__M4}/fcb_read_bits.m4
        ${CBF__M4}/fcb_read_image.m4
        ${CBF__M4}/fcb_read_xds_i2.m4
    )
    #
    # m4 F90 examples macro files
    #
    set(
        CBF_M4_F90_EXAMPLES
        ${CBF__M4}/test_fcb_read_image.m4
        ${CBF__M4}/test_xds_binary.m4
    )

endif()


# #
# # Documentation files
# #
# set(
#     CBF_DOCUMENTS
#     ${CBF__DOC}/CBFlib.html
#     ${CBF__DOC}/CBFlib.txt
#     ${CBF__DOC}/CBFlib_NOTICES.html
#     ${CBF__DOC}/CBFlib_NOTICES.txt
#     ${CBF__DOC}/ChangeLog
#     ${CBF__DOC}/ChangeLog.html
#     ${CBF__DOC}/MANIFEST
#     ${CBF__DOC}/gpl.txt $(DOC)/lgpl.txt
#     CACHE STRING ""
# )

#
# HTML Graphics files
#
# set(
#     JPEGS
#     ${GRAPHICS}/CBFbackground.jpg
#     ${GRAPHICS}/CBFbig.jpg
#     ${GRAPHICS}/CBFbutton.jpg
#     ${GRAPHICS}/cbflibbackground.jpg
#     ${GRAPHICS}/cbflibbig.jpg
#     ${GRAPHICS}/cbflibbutton.jpg
#     ${GRAPHICS}/cifhome.jpg
#     ${GRAPHICS}/iucrhome.jpg
#     ${GRAPHICS}/noticeButton.jpg
#     CACHE STRING ""
# )

# Set up the necessary includes

include_directories(${CBFlib_SOURCE_DIR}/include)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CBFlib_BINARY_DIR}/bin")

#
#  Build the CBF libraries
#

add_library(cbf_lib ${CBF_C_SOURCES})
target_link_libraries(cbf_lib PUBLIC hdf5::hdf5 regex)
set_target_properties(
    cbf_lib
    PROPERTIES
    OUTPUT_NAME     cbf
    LINKER_LANGUAGE C
    SOVERSION       "${CBF_APIVERSION}"
    EXPORT_NAME     cbf
)

#
# Build the IMG libraries
#

add_library(img_lib ${CBF__SRC}/img.c)
set_target_properties(
    img_lib
    PROPERTIES
    OUTPUT_NAME     "img"
    LINKER_LANGUAGE C
    EXPORT_NAME     "img"
)

if(BUILD_PYCBF)
    find_package(Python COMPONENTS Interpreter Development REQUIRED)
    Python_add_library(_pycbf MODULE ${PYCBF}/pycbf_wrap.c)
    target_link_libraries(_pycbf PUBLIC cbf_lib)
    # We want to let setup.py install this, so build with install-time RPATH
    set_target_properties(_pycbf PROPERTIES BUILD_WITH_INSTALL_RPATH TRUE
                                            LIBRARY_OUTPUT_DIRECTORY pycbf_setup/pycbf)
    configure_file(${PYCBF}/setup.py.in pycbf_setup/setup.py)
    # Don't want to explicitly rearrange the package layout, so copy the required
    # python files into a new folder substructure under the build directory
    add_custom_command( OUTPUT pycbf_setup/pycbf/__init__.py
                        DEPENDS ${PYCBF}/pycbf.py
                        COMMAND ${CMAKE_COMMAND} -E copy
                                ${PYCBF}/pycbf.py
                                ${CMAKE_BINARY_DIR}/pycbf_setup/pycbf/__init__.py )

    add_custom_target(pycbf ALL DEPENDS
        # ${CMAKE_BINARY_DIR}/pycbf_setup/pycbf/pycbf.py
        ${CMAKE_BINARY_DIR}/pycbf_setup/pycbf/__init__.py
    )
    install(CODE "
    execute_process(COMMAND ${Python_EXECUTABLE} -m pip install ${CMAKE_BINARY_DIR}/pycbf_setup
                    RESULT_VARIABLE _error)
    if(_error)
        message(FATAL_ERROR \"Failed to install python package\")
    endif()")
endif()

if(USE_FORTRAN)
    #
    # Build the f90 library sources
    #
    if(NOT M4)
        find_program(M4 m4 REQUIRED)
        message(STATUS "Found m4: ${M4}")
    endif()
    foreach(f90src IN LISTS CBF_F90_BUILT_SOURCES)
        get_filename_component(filename "${f90src}" NAME_WE)
        set(f90bldsrc "${CBF__BLDSRC}/${filename}.f90")
        set(f90srcm4 "${CBF__M4}/${filename}.m4")
        add_custom_command(
            OUTPUT "${f90bldsrc}"
            WORKING_DIRECTORY "${CBF__M4}"
            COMMAND ${M4} -P "${M4_FLAGS}" "${f90srcm4}" > "${f90bldsrc}"
            DEPENDS ${CBF_M4_FCB_DEFINES} ${f90srcm4}
            COMMENT "Generating ${f90bldsrc}"
        )
    endforeach()


    #
    # Build the fcb libraries
    #
    add_library(fcb_lib  ${CBF_F90_BUILT_SOURCES};${CBF_F90_SOURCES})
    set_target_properties(fcb_lib PROPERTIES OUTPUT_NAME "fcb")
    set_target_properties(fcb_lib PROPERTIES LINKER_LANGUAGE C)
    target_link_libraries(fcb_lib hdf5::hdf5_fortran)

endif()


#
#  C and C++ examples
#

add_target(adscimg2cbf "${CBF__EXAMPLES}/adscimg2cbf.c" "${CBF__EXAMPLES}/adscimg2cbf_sub.c" LINKS cbf_lib m)
add_target(cbf2adscimg "${CBF__EXAMPLES}/cbf2adscimg.c" "${CBF__EXAMPLES}/cbf2adscimg_sub.c" LINKS cbf_lib m)
add_target(convert_image "${CBF__EXAMPLES}/convert_image.c" LINKS cbf_lib img_lib m)
add_target(convert_minicbf "${CBF__EXAMPLES}/convert_minicbf.c" LINKS cbf_lib m)
add_target(makecbf "${CBF__EXAMPLES}/makecbf.c" LINKS cbf_lib img_lib m)
add_target(cbf_tail "${CBF__EXAMPLES}/cbf_tail.c" LINKS cbf_lib)
add_target(changtestcompression "${CBF__EXAMPLES}/changtestcompression.c" LINKS cbf_lib)
add_target(img2cif "${CBF__EXAMPLES}/img2cif.c" LINKS cbf_lib img_lib m)
add_target(cbf_template_t "${CBF__DECTRIS_EXAMPLES}/cbf_template_t.c" LINKS cbf_lib)
add_target(sequence_match "${CBF__EXAMPLES}/sequence_match.c" LINKS cbf_lib)
add_target(cbf2nexus "${CBF__EXAMPLES}/cbf2nexus.c" LINKS cbf_lib m)
add_target(nexus2cbf "${CBF__EXAMPLES}/nexus2cbf.c" LINKS cbf_lib m)
add_target(minicbf2nexus "${CBF__EXAMPLES}/minicbf2nexus.c" LINKS cbf_lib hdf5::hdf5 m)
add_target(cif2cbf "${CBF__EXAMPLES}/cif2cbf.c" LINKS cbf_lib img_lib hdf5::hdf5 m)

if(USE_TIFF)
    add_target(tiff2cbf "${CBF__EXAMPLES}/tiff2cbf.c" LINKS cbf_lib TIFF::TIFF)
endif()

if(BUILD_TESTING)
    add_target(testhdf5 "${CBF__EXAMPLES}/testhdf5.c" LINKS cbf_lib hdf5::hdf5 m)
    add_target(testcell "${CBF__EXAMPLES}/testcell.C" LINKS cbf_lib)
    add_target(sauter_test "${CBF__EXAMPLES}/sauter_test.C" LINKS cbf_lib)
    add_target(testulp "${CBF__EXAMPLES}/testulp.c" LINKS cbf_lib)
    add_target(testtree "${CBF__EXAMPLES}/testtree.c" LINKS cbf_lib)
    add_target(testalloc "${CBF__EXAMPLES}/testalloc.c" LINKS cbf_lib)
    add_target(testflat "${CBF__EXAMPLES}/testflat.c" LINKS cbf_lib)
    add_target(testflatpacked "${CBF__EXAMPLES}/testflatpacked.c" LINKS cbf_lib)
    add_target(testreals "${CBF__EXAMPLES}/testreals.c" LINKS cbf_lib)
endif()


if(USE_FORTRAN AND BUILD_TESTING)
    #
    #  F90 examples
    #
    add_custom_command(OUTPUT "${CBF__BLDEXMP}/test_fcb_read_image.f90"
        WORKING_DIRECTORY "${CBF__M4}"
        COMMAND ${M4} -P "${M4_FLAGS}" "${CBF__M4}/test_fcb_read_image.m4" > "${CBF__BLDEXMP}/test_fcb_read_image.f90"
        DEPENDS ${CBF_M4_FCB_DEFINES} "${CBF__M4}/test_fcb_read_image.m4"
        COMMENT "Generating ${test_fcb_read_image.f90}"
    )
    add_custom_command(OUTPUT "${CBF__BLDEXMP}/test_xds_binary.f90"
        WORKING_DIRECTORY "${CBF__M4}"
        COMMAND ${M4} -P "${M4_FLAGS}" "${CBF__M4}/test_xds_binary.m4" > "${CBF__BLDEXMP}/test_xds_binary.f90"
        DEPENDS ${CBF_M4_FCB_DEFINES} "${CBF__M4}/test_xds_binary.m4"
        COMMENT "Generating ${test_xds_binary.f90}"
    )

    add_target(test_fcb_read_image "${CBF__BLDEXMP}/test_fcb_read_image.f90" LINKS fcb_lib)
    add_target(test_xds_binary "${CBF__BLDEXMP}/test_xds_binary.f90" LINKS fcb_lib)
endif()



#
# install
#

install(TARGETS
    makecbf
    img2cif
    adscimg2cbf
    cbf2adscimg
    convert_image
    convert_minicbf
    cbf_template_t
    sequence_match
    cif2cbf
    minicbf2nexus
    cbf2nexus
    nexus2cbf
    img_lib
    cbf_lib
)

install(TARGETS cbf_lib img_lib
        EXPORT cbflib-exports
        INCLUDES DESTINATION include/cbflib)

install(DIRECTORY ${CBF__INCLUDE}/ DESTINATION include/cbflib FILES_MATCHING PATTERN "*.h")
install(DIRECTORY ${CBF__BIN_INCLUDE}/* DESTINATION include/cbflib FILES_MATCHING PATTERN "*.h")


if(USE_TIFF)
    install(TARGETS tiff2cbf)
endif()

if(USE_FORTRAN)
    install(TARGETS fcb_lib)
endif()

###############################################################################
#
# Testing
#
###############################################################################

# Path to the valgrind executable, for memory tests
find_program(VALGRIND valgrind)
if(VALGRIND)
    message(STATUS "valgrid found at ${VALGRIND}")
    set(VALGRIND_COMMAND ${VALGRIND} --error-exitcode=3 --leak-check=full)
else()
    message(STATUS "valgrid NOT found. Testing will be incomplete.")
endif()

enable_testing()

# set up a wrapper to call 'h5dump' and redirect its output to a file
configure_file(${CBFlib_SOURCE_DIR}/h5dump.cmake ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake @ONLY)

# core tests



add_test(makecbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/makecbf ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/makecbf.cbf)
# $(BIN)/img2cif -c flatpacked -m headers -d digest -e base64 example.mar2300 img2cif_packed.cif
add_test(img2cif_packed.cif ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/img2cif -c flatpacked -m headers -d digest -e base64 ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/img2cif_packed.cif)
# $(BIN)/img2cif -c canonical -m headers -d digest -e base64 example.mar2300 img2cif_canonical.cif
add_test(img2cif_canonical.cif ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/img2cif -c canonical -m headers -d digest -e base64 ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/img2cif_canonical.cif)
# $(BIN)/img2cif -c flatpacked -m headers -d digest -e none example.mar2300 img2cif_packed.cbf
add_test(img2cif_packed.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/img2cif -c flatpacked -m headers -d digest -e none ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/img2cif_packed.cbf)
# $(BIN)/img2cif -c canonical -m headers -d digest -e none example.mar2300 img2cif_canonical.cbf
add_test(img2cif_canonical.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/img2cif -c canonical -m headers -d digest -e none ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/img2cif_canonical.cbf)


# $(BIN)/convert_image -F example.mar2300 converted_flat.cbf
add_test(
    converted_flat.cbf
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_image
    -F -p ${CBFlib_SOURCE_DIR}/templates/template_mar345_2300x2300.cbf
    ${CBF_DATADIRI}/example.mar2300
    ${CBF__DATA}/converted_flat.cbf
)
# -cmp converted_flat_orig.cbf converted_flat.cbf
add_test(cmp-converted_flat_orig.cbf-converted_flat.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/converted_flat_orig.cbf ${CBF__DATA}/converted_flat.cbf)
set_property(TEST cmp-converted_flat_orig.cbf-converted_flat.cbf APPEND PROPERTY DEPENDS converted_flat.cbf)

# $(BIN)/convert_image example.mar2300 converted.cbf
add_test(converted.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_image -p ${CBFlib_SOURCE_DIR}/templates/template_mar345_2300x2300.cbf ${CBF_DATADIRI}/example.mar2300 ${CBF__DATA}/converted.cbf)

# -cmp converted_orig.cbf converted.cbf
add_test(cmp-converted_orig.cbf-converted.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/converted_orig.cbf ${CBF__DATA}/converted.cbf)
set_property(TEST cmp-converted_orig.cbf-converted.cbf APPEND PROPERTY DEPENDS converted.cbf)

# copy a file into another directory so that test input data is not modified
add_test(mb_LP_1_001.img ${CMAKE_COMMAND} -E copy ${CBF_DATADIRI}/mb_LP_1_001.img ${CBF__DATA}/mb_LP_1_001.img)

# $(BIN)/convert_image -F -d adscquantum315 mb_LP_1_001.img adscconverted_flat.cbf
add_test(
    adscconverted_flat.cbf
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_image
    -F -p ${CBFlib_SOURCE_DIR}/templates/template_adscquantum315_3072x3072.cbf
    -d adscquantum315
    ${CBF__DATA}/mb_LP_1_001.img
    ${CBF__DATA}/adscconverted_flat.cbf
)
set_property(TEST adscconverted_flat.cbf APPEND PROPERTY DEPENDS mb_LP_1_001.img)
# -cmp adscconverted_flat_orig.cbf adscconverted_flat.cbf
add_test(cmp-adscconverted_flat_orig.cbf-adscconverted_flat.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/adscconverted_flat_orig.cbf ${CBF__DATA}/adscconverted_flat.cbf)
set_property(TEST cmp-adscconverted_flat_orig.cbf-adscconverted_flat.cbf APPEND PROPERTY DEPENDS adscconverted_flat.cbf)

# $(BIN)/convert_image -d adscquantum315 mb_LP_1_001.img adscconverted.cbf
add_test(
    adscconverted.cbf
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_image
    -p ${CBFlib_SOURCE_DIR}/templates/template_adscquantum315_3072x3072.cbf
    -d adscquantum315
    ${CBF__DATA}/mb_LP_1_001.img
    ${CBF__DATA}/adscconverted.cbf
)
set_property(TEST adscconverted.cbf APPEND PROPERTY DEPENDS mb_LP_1_001.img)
# -cmp adscconverted_orig.cbf adscconverted.cbf
add_test(cmp-adscconverted_orig.cbf-adscconverted.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/adscconverted_orig.cbf ${CBF__DATA}/adscconverted.cbf)
set_property(TEST cmp-adscconverted_orig.cbf-adscconverted.cbf APPEND PROPERTY DEPENDS adscconverted.cbf)

# $(BIN)/adscimg2cbf --no_pad --cbf_packed,flat mb_LP_1_001.img
add_test(mb_LP_1_001.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/adscimg2cbf --no_pad --cbf_packed,flat ${CBF__DATA}/mb_LP_1_001.img)
set_property(TEST mb_LP_1_001.cbf APPEND PROPERTY DEPENDS mb_LP_1_001.img)
# -cmp mb_LP_1_001_orig.cbf mb_LP_1_001.cbf
add_test(cmp-mb_LP_1_001_orig.cbf-mb_LP_1_001.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/mb_LP_1_001_orig.cbf ${CBF__DATA}/mb_LP_1_001.cbf)
set_property(TEST cmp-mb_LP_1_001_orig.cbf-mb_LP_1_001.cbf APPEND PROPERTY DEPENDS mb_LP_1_001.cbf)

# cp mb_LP_1_001.cbf nmb_LP_1_001.cbf
add_test(nmb_LP_1_001.cbf ${CMAKE_COMMAND} -E copy ${CBF__DATA}/mb_LP_1_001.cbf ${CBF__DATA}/nmb_LP_1_001.cbf)
set_property(TEST nmb_LP_1_001.cbf APPEND PROPERTY DEPENDS mb_LP_1_001.cbf)
# $(BIN)/cbf2adscimg nmb_LP_1_001.cbf
add_test(nmb_LP_1_001.img ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cbf2adscimg ${CBF__DATA}/nmb_LP_1_001.cbf)
set_property(TEST nmb_LP_1_001.img APPEND PROPERTY DEPENDS nmb_LP_1_001.cbf)
# -cmp mb_LP_1_001.img nmb_LP_1_001.img
add_test(cmp-mb_LP_1_001.img-nmb_LP_1_001.img ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/mb_LP_1_001.img ${CBF__DATA}/nmb_LP_1_001.img)
set_property(TEST cmp-mb_LP_1_001.img-nmb_LP_1_001.img APPEND PROPERTY DEPENDS mb_LP_1_001.img)
set_property(TEST cmp-mb_LP_1_001.img-nmb_LP_1_001.img APPEND PROPERTY DEPENDS nmb_LP_1_001.img)

# $(BIN)/convert_minicbf -d pilatus6m -v 1 insulin_pilatus6m.cbf insulin_pilatus6mconverted.cbf
add_test(
    insulin_pilatus6mconverted.cbf
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_minicbf
    -p ${CBFlib_SOURCE_DIR}/templates/template_pilatus6m_2463x2527.cbf
    -d pilatus6m -v 1
    ${CBF_DATADIRI}/insulin_pilatus6m.cbf
    ${CBF__DATA}/insulin_pilatus6mconverted.cbf
)

# -cmp insulin_pilatus6mconverted_rev_orig.cbf insulin_pilatus6mconverted.cbf
add_test(
    cmp-insulin_pilatus6mconverted_rev_orig.cbf-insulin_pilatus6mconverted.cbf
    ${CMAKE_COMMAND} -E compare_files
    ${CBF_DATADIRO}/insulin_pilatus6mconverted_rev_orig.cbf
    ${CBF__DATA}/insulin_pilatus6mconverted.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_rev_orig.cbf-insulin_pilatus6mconverted.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)

# $(BIN)/convert_minicbf -d pilatus6m insulin_pilatus6m.cbf insulin_pilatus6mconverted_v2.cbf
add_test(
    insulin_pilatus6mconverted_v2.cbf
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/convert_minicbf
    -p ${CBFlib_SOURCE_DIR}/templates/template_pilatus6m_2463x2527.cbf
    -d pilatus6m
    ${CBF_DATADIRI}/insulin_pilatus6m.cbf
    ${CBF__DATA}/insulin_pilatus6mconverted_v2.cbf
)
# -cmp insulin_pilatus6mconverted_v2_orig.cbf insulin_pilatus6mconverted_v2.cbf
add_test(
    cmp-insulin_pilatus6mconverted_v2_orig.cbf-insulin_pilatus6mconverted_v2.cbf
    ${CMAKE_COMMAND} -E compare_files
    ${CBF_DATADIRO}/insulin_pilatus6mconverted_v2_orig.cbf
    ${CBF__DATA}/insulin_pilatus6mconverted_v2.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_v2_orig.cbf-insulin_pilatus6mconverted_v2.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_v2.cbf)


# cif2cbf basic round-trip to hdf5 tests
# $(BIN)/cif2cbf -e none -c flatpacked img2cif_canonical.cif cif2cbf_packed.cbf
add_test(cif2cbf_packed.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -e none -c flatpacked ${CBF__DATA}/img2cif_canonical.cif ${CBF__DATA}/cif2cbf_packed.cbf)
set_property(TEST cif2cbf_packed.cbf APPEND PROPERTY DEPENDS img2cif_canonical.cif)
# $(BIN)/cif2cbf -e none -c canonical img2cif_packed.cif cif2cbf_canonical.cbf
add_test(cif2cbf_canonical.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -e none -c canonical ${CBF__DATA}/img2cif_packed.cif ${CBF__DATA}/cif2cbf_canonical.cbf)
set_property(TEST cif2cbf_canonical.cbf APPEND PROPERTY DEPENDS img2cif_packed.cif)
# -cmp cif2cbf_packed.cbf makecbf.cbf
add_test(cmp-cif2cbf_packed.cbf-makecbf.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/cif2cbf_packed.cbf ${CBF__DATA}/makecbf.cbf)
set_property(TEST cmp-cif2cbf_packed.cbf-makecbf.cbf APPEND PROPERTY DEPENDS cif2cbf_packed.cbf)
set_property(TEST cmp-cif2cbf_packed.cbf-makecbf.cbf APPEND PROPERTY DEPENDS makecbf)
# -cmp cif2cbf_packed.cbf img2cif_packed.cbf
add_test(cmp-cif2cbf_packed.cbf-img2cif_packed.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/cif2cbf_packed.cbf ${CBF__DATA}/img2cif_packed.cbf)
set_property(TEST cmp-cif2cbf_packed.cbf-img2cif_packed.cbf APPEND PROPERTY DEPENDS cif2cbf_packed.cbf)
set_property(TEST cmp-cif2cbf_packed.cbf-img2cif_packed.cbf APPEND PROPERTY DEPENDS img2cif_packed.cbf)
# -cmp cif2cbf_canonical.cbf img2cif_canonical.cbf
add_test(cmp-cif2cbf_canonical.cbf-img2cif_canonical.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/cif2cbf_canonical.cbf ${CBF__DATA}/img2cif_canonical.cbf)
set_property(TEST cmp-cif2cbf_canonical.cbf-img2cif_canonical.cbf APPEND PROPERTY DEPENDS cif2cbf_canonical.cbf)
set_property(TEST cmp-cif2cbf_canonical.cbf-img2cif_canonical.cbf APPEND PROPERTY DEPENDS img2cif_canonical.cbf)

# $(BIN)/cif2cbf -e hex -c none makecbf.cbf cif2cbf_ehcn.cif
add_test(cif2cbf_ehcn.cif ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -e hex -c none ${CBF__DATA}/makecbf.cbf ${CBF__DATA}/cif2cbf_ehcn.cif)
set_property(TEST cif2cbf_ehcn.cif APPEND PROPERTY DEPENDS makecbf)
# $(BIN)/cif2cbf -e none -c flatpacked cif2cbf_ehcn.cif cif2cbf_encp.cbf
add_test(cif2cbf_encp.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -e none -c flatpacked ${CBF__DATA}/cif2cbf_ehcn.cif ${CBF__DATA}/cif2cbf_encp.cbf)
set_property(TEST cif2cbf_encp.cbf APPEND PROPERTY DEPENDS cif2cbf_ehcn.cif)
#-cmp makecbf.cbf cif2cbf_encp.cbf
add_test(cmp-makecbf.cbf-cif2cbf_encp.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/makecbf.cbf ${CBF__DATA}/cif2cbf_encp.cbf)
set_property(TEST cmp-makecbf.cbf-cif2cbf_encp.cbf APPEND PROPERTY DEPENDS makecbf)
set_property(TEST cmp-makecbf.cbf-cif2cbf_encp.cbf APPEND PROPERTY DEPENDS cif2cbf_encp.cbf)

# $(BIN)/cif2cbf -i 9ins.cif -o 9ins.cbf
add_test(9ins.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -i ${CBF_DATADIRI}/9ins.cif -o ${CBF__DATA}/9ins.cbf)
# -cmp 9ins.cif 9ins.cbf
add_test(cmp-9ins.cif-9ins.cbf ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRI}/9ins.cif ${CBF__DATA}/9ins.cbf)
set_property(TEST cmp-9ins.cif-9ins.cbf APPEND PROPERTY DEPENDS 9ins.cbf)

# $(BIN)/cif2cbf -5 w -O $(HDF5REGISTER) -i insulin_pilatus6mconverted.cbf -o insulin_pilatus6mconverted.cbf.h5
add_test(
insulin_pilatus6mconverted.cbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 w -O
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf
-o ${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5
)
set_property(TEST insulin_pilatus6mconverted.cbf.h5 APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted.cbf.h5 APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)

# $(BIN)/cif2cbf -5 rn $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted.cbf.h5 -o insulin_pilatus6mconverted.cbf.h5.cbf
add_test(
insulin_pilatus6mconverted.cbf.h5.cbf
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 rn -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5
-o ${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5.cbf
)
set_property(TEST insulin_pilatus6mconverted.cbf.h5.cbf APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf.h5)
# -cmp insulin_pilatus6mconverted.cbf.h5.cbf insulin_pilatus6mconverted_orig.cbf.h5.cbf
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted.cbf.h5.cbf
${CMAKE_COMMAND} -E compare_files
${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5.cbf
${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf.h5.cbf)

# $(BIN)/h5dump insulin_pilatus6mconverted_orig.cbf.h5 | $(ALLBUTONE) > insulin_pilatus6mconverted_orig.cbf.h5.dump
add_test(
insulin_pilatus6mconverted_orig.cbf.h5.dump
${CMAKE_COMMAND}
-Dinput=${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5
-Doutput=${CBF__DATA}/insulin_pilatus6mconverted_orig.cbf.h5.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
# $(BIN)/h5dump insulin_pilatus6mconverted.cbf.h5 | $(ALLBUTONE)  > insulin_pilatus6mconverted.cbf.h5.dump
add_test(
insulin_pilatus6mconverted.cbf.h5.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5
-Doutput=${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST insulin_pilatus6mconverted.cbf.h5.dump APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf.h5)
# $(DIFF) insulin_pilatus6mconverted_orig.cbf.h5.dump insulin_pilatus6mconverted.cbf.h5.dump
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.dump-insulin_pilatus6mconverted.cbf.h5.dump
${CMAKE_COMMAND} -E compare_files
${CBF__DATA}/insulin_pilatus6mconverted_orig.cbf.h5.dump
${CBF__DATA}/insulin_pilatus6mconverted.cbf.h5.dump
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.dump-insulin_pilatus6mconverted.cbf.h5.dump APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_orig.cbf.h5.dump)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.dump-insulin_pilatus6mconverted.cbf.h5.dump APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf.h5.dump)

# cif2cbf round-trip tests

# convert to hdf5 with '-en -cI' options, then back to cbf with '-en -cp' options to check the file against a reference file

# $(BIN)/cif2cbf -5 w $(HDF5REGISTER) -en -cI -i insulin_pilatus6mconverted.cbf -o insulin_pilatus6mconverted_encI.cbf.h5
add_test(
insulin_pilatus6mconverted_encI.cbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 w -en -cI
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf
-o ${CBF__DATA}/insulin_pilatus6mconverted_encI.cbf.h5
)
set_property(TEST insulin_pilatus6mconverted_encI.cbf.h5 APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encI.cbf.h5 APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)
# $(BIN)/cif2cbf -5 rn $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted_encI.cbf.h5 -o insulin_pilatus6mconverted_encI.cbf.h5.cbf
add_test(
insulin_pilatus6mconverted_encI.cbf.h5.cbf
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 rn -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted_encI.cbf.h5
-o ${CBF__DATA}/insulin_pilatus6mconverted_encI.cbf.h5.cbf
)
set_property(TEST insulin_pilatus6mconverted_encI.cbf.h5.cbf APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encI.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encI.cbf.h5)
# -cmp insulin_pilatus6mconverted_encI.cbf.h5.cbf insulin_pilatus6mconverted_orig.cbf.h5.cbf
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encI.cbf.h5.cbf
${CMAKE_COMMAND} -E compare_files
${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5.cbf
${CBF__DATA}/insulin_pilatus6mconverted_encI.cbf.h5.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encI.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encI.cbf.h5.cbf)

# convert to hdf5 with '-en -cp' options, then back to cbf with '-en -cp' options to check the file against a reference file

# $(BIN)/cif2cbf -5 w $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted.cbf -o insulin_pilatus6mconverted_encp.cbf.h5
add_test(
insulin_pilatus6mconverted_encp.cbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 w -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf
-o ${CBF__DATA}/insulin_pilatus6mconverted_encp.cbf.h5
)
set_property(TEST insulin_pilatus6mconverted_encp.cbf.h5 APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encp.cbf.h5 APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)
# $(BIN)/cif2cbf -5 rn $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted_encp.cbf.h5 -o insulin_pilatus6mconverted_encp.cbf.h5.cbf
add_test(
insulin_pilatus6mconverted_encp.cbf.h5.cbf
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 rn -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted_encp.cbf.h5
-o ${CBF__DATA}/insulin_pilatus6mconverted_encp.cbf.h5.cbf
)
set_property(TEST insulin_pilatus6mconverted_encp.cbf.h5.cbf APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encp.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encp.cbf.h5)
# -cmp insulin_pilatus6mconverted_encp.cbf.h5.cbf insulin_pilatus6mconverted_orig.cbf.h5.cbf
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encp.cbf.h5.cbf
${CMAKE_COMMAND} -E compare_files
${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5.cbf
${CBF__DATA}/insulin_pilatus6mconverted_encp.cbf.h5.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encp.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encp.cbf.h5.cbf)

# convert to hdf5 with '-en -cb' options, then back to cbf with '-en -cp' options to check the file against a reference file

# $(BIN)/cif2cbf -5 w $(HDF5REGISTER) -en -cb -i insulin_pilatus6mconverted.cbf -o insulin_pilatus6mconverted_encb.cbf.h5
add_test(
insulin_pilatus6mconverted_encb.cbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 w -en -cb
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf
-o ${CBF__DATA}/insulin_pilatus6mconverted_encb.cbf.h5
)
set_property(TEST insulin_pilatus6mconverted_encb.cbf.h5 APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encb.cbf.h5 APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)
# $(BIN)/cif2cbf -5 rn $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted_encb.cbf.h5 -o insulin_pilatus6mconverted_encb.cbf.h5.cbf
add_test(
insulin_pilatus6mconverted_encb.cbf.h5.cbf
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 rn -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted_encb.cbf.h5
-o ${CBF__DATA}/insulin_pilatus6mconverted_encb.cbf.h5.cbf
)
set_property(TEST insulin_pilatus6mconverted_encb.cbf.h5.cbf APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encb.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encb.cbf.h5)
# -cmp insulin_pilatus6mconverted_encb.cbf.h5.cbf insulin_pilatus6mconverted_orig.cbf.h5.cbf
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encb.cbf.h5.cbf
${CMAKE_COMMAND} -E compare_files
${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5.cbf
${CBF__DATA}/insulin_pilatus6mconverted_encb.cbf.h5.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encb.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encb.cbf.h5.cbf)

# convert to hdf5 with '-en -cc' options, then back to cbf with '-en -cp' options to check the file against a reference file

# $(BIN)/cif2cbf -5 w $(HDF5REGISTER) -en -cc -i insulin_pilatus6mconverted.cbf -o insulin_pilatus6mconverted_encc.cbf.h5
add_test(
insulin_pilatus6mconverted_encc.cbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 w -en -cc
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted.cbf
-o ${CBF__DATA}/insulin_pilatus6mconverted_encc.cbf.h5
)
set_property(TEST insulin_pilatus6mconverted_encc.cbf.h5 APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encc.cbf.h5 APPEND PROPERTY DEPENDS insulin_pilatus6mconverted.cbf)
# $(BIN)/cif2cbf -5 rn $(HDF5REGISTER) -en -cp -i insulin_pilatus6mconverted_encc.cbf.h5 -o insulin_pilatus6mconverted_encc.cbf.h5.cbf
add_test(
insulin_pilatus6mconverted_encc.cbf.h5.cbf
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cif2cbf -5 rn -en -cp
${CBF_HDF5REGISTER_ARG} ${CBF_HDF5REGISTER_VAL}
-i ${CBF__DATA}/insulin_pilatus6mconverted_encc.cbf.h5
-o ${CBF__DATA}/insulin_pilatus6mconverted_encc.cbf.h5.cbf
)
set_property(TEST insulin_pilatus6mconverted_encc.cbf.h5.cbf APPEND PROPERTY ENVIRONMENT "HDF5_PLUGIN_PATH=${HDF5_PLUGIN_PATH}")
set_property(TEST insulin_pilatus6mconverted_encc.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encc.cbf.h5)
# -cmp insulin_pilatus6mconverted_encc.cbf.h5.cbf insulin_pilatus6mconverted_orig.cbf.h5.cbf
add_test(
cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encc.cbf.h5.cbf
${CMAKE_COMMAND} -E compare_files
${CBF_DATADIRO}/insulin_pilatus6mconverted_orig.cbf.h5.cbf
${CBF__DATA}/insulin_pilatus6mconverted_encc.cbf.h5.cbf
)
set_property(TEST cmp-insulin_pilatus6mconverted_orig.cbf.h5.cbf-insulin_pilatus6mconverted_encc.cbf.h5.cbf APPEND PROPERTY DEPENDS insulin_pilatus6mconverted_encc.cbf.h5.cbf)

# conversion tests for tiff2cbf
if(USE_TIFF)
    # $(BIN)/tiff2cbf XRD1621.tif XRD1621.cbf
    add_test(XRD1621.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/tiff2cbf ${CBF_DATADIRI}/XRD1621.tif ${CBF__DATA}/XRD1621.cbf)
    # $(DIFF) XRD1621_orig.cbf XRD1621.cbf
    add_test(
        cmp-XRD1621_orig.cbf-XRD1621.cbf
        ${CMAKE_COMMAND} -E compare_files
        ${CBF_DATADIRO}/XRD1621_orig.cbf
        ${CBF__DATA}/XRD1621.cbf
    )
    set_property(TEST cmp-XRD1621_orig.cbf-XRD1621.cbf APPEND PROPERTY DEPENDS XRD1621.cbf)
    # $(BIN)/cif2cbf -I 4 -C 100. -L 0. -e n -c b -i XRD1621.cbf -o XRD1621_I4encbC100.cbf
    # $(DIFF) XRD1621_I4encbC100_orig.cbf XRD1621_I4encbC100.cbf
endif()

# unit tests
add_test(testhdf5 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testhdf5)

if(VALGRIND)
    add_test(testalloc ${VALGRIND_COMMAND} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testalloc)
    add_test(testtree ${VALGRIND_COMMAND} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testtree)
    add_test(testulp ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testulp)
endif()

add_test(testflatin.cbf ${CMAKE_COMMAND} -E copy ${CBF_DATADIRI}/testflatin.cbf ${CBF__DATA}/testflatin.cbf)
add_test(NAME testflat COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testflat WORKING_DIRECTORY ${CBF__DATA})
set_property(TEST testflat APPEND PROPERTY DEPENDS testflatin.cbf)
add_test(cmp-testflatin.cbf-testflatout.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/testflatin.cbf ${CBF__DATA}/testflatout.cbf)
set_property(TEST cmp-testflatin.cbf-testflatout.cbf APPEND PROPERTY DEPENDS testflat)

add_test(testflatpackedin.cbf ${CMAKE_COMMAND} -E copy ${CBF_DATADIRI}/testflatpackedin.cbf ${CBF__DATA}/testflatpackedin.cbf)
add_test(NAME testflatpacked COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testflatpacked WORKING_DIRECTORY ${CBF__DATA})
set_property(TEST testflatpacked APPEND PROPERTY DEPENDS testflatpackedin.cbf)
add_test(cmp-testflatpackedin.cbf-testflatpackedout.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/testflatpackedin.cbf ${CBF__DATA}/testflatpackedout.cbf)
set_property(TEST cmp-testflatpackedin.cbf-testflatpackedout.cbf APPEND PROPERTY DEPENDS testflatpacked)

add_test(testrealin.cbf ${CMAKE_COMMAND} -E copy ${CBF_DATADIRI}/testrealin.cbf ${CBF__DATA}/testrealin.cbf)
add_test(NAME testreals COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testreals WORKING_DIRECTORY ${CBF__DATA})
set_property(TEST testreals APPEND PROPERTY DEPENDS testrealin.cbf)
add_test(cmp-testrealin.cbf-testrealout.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/testrealin.cbf ${CBF__DATA}/testrealout.cbf)
set_property(TEST cmp-testrealin.cbf-testrealout.cbf APPEND PROPERTY DEPENDS testreals)

# $(BIN)/sauter_test
add_test(NAME sauter_test COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/sauter_test WORKING_DIRECTORY ${CBF__DATA})
set_property(TEST sauter_test APPEND PROPERTY DEPENDS adscconverted_flat.cbf)
# $(BIN)/changtestcompression
add_test(changtestcompression ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/changtestcompression)

# set up a test script for 'testcell':
configure_file(${CBF__EXAMPLES}/testcell.cmake ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testcell.cmake)
# $(BIN)/testcell < testcell.dat > testcell.prt
add_test(testcell ${CMAKE_COMMAND} -P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/testcell.cmake)
# -cmp testcell_orig.prt testcell.prt
add_test(cmp-testcell_orig.prt-testcell.prt ${CMAKE_COMMAND} -E compare_files ${CBF_DATADIRO}/testcell_orig.prt ${CBF__DATA}/testcell.prt)
set_property(TEST cmp-testcell_orig.prt-testcell.prt APPEND PROPERTY DEPENDS testcell)

# compare the cbf files from i19 data
add_test(cmp-i19-1.cbf-i19-2.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/i19-1.cbf ${CBF__DATA}/i19-2.cbf)
set_property(TEST cmp-i19-1.cbf-i19-2.cbf APPEND PROPERTY DEPENDS i19-1.cbf)
set_property(TEST cmp-i19-1.cbf-i19-2.cbf APPEND PROPERTY DEPENDS i19-2.cbf)

# compare the cbf files from i03 data
add_test(cmp-i03-1.cbf-i03-2.cbf ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/i03-1.cbf ${CBF__DATA}/i03-2.cbf)
set_property(TEST cmp-i03-1.cbf-i03-2.cbf APPEND PROPERTY DEPENDS i03-1.cbf)
set_property(TEST cmp-i03-1.cbf-i03-2.cbf APPEND PROPERTY DEPENDS i03-2.cbf)


# basic minicbf2nexus tests
# generate a hfd5 file from minicbf data
add_test(
minicbf.h5
${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/minicbf2nexus
-c zlib
-C ${CBFlib_SOURCE_DIR}/minicbf_test/config
--register manual
-o ${CBF__DATA}/minicbf.h5
${CBF_DATADIRI}/X4_lots_M1S4_1_0001.cbf
${CBF_DATADIRI}/X4_lots_M1S4_1_0002.cbf
${CBF_DATADIRI}/X4_lots_M1S4_1_0003.cbf
${CBF_DATADIRI}/X4_lots_M1S4_1_0004.cbf
${CBF_DATADIRI}/X4_lots_M1S4_1_0005.cbf
)

# dump the content of generated and reference hdf5 files & use 'cbf_tail' to strip off some file names
add_test(
minicbf_original.dump
${CMAKE_COMMAND}
-Dinput=${CBF_DATADIRO}/minicbf_original.h5
-Doutput=${CBF__DATA}/minicbf_original.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
add_test(
minicbf.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/minicbf.h5
-Doutput=${CBF__DATA}/minicbf.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST minicbf.dump APPEND PROPERTY DEPENDS minicbf.h5)

# compare dumped hdf5 file content
add_test(cmp-minicbf_original.dump-minicbf.dump ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/minicbf_original.dump ${CBF__DATA}/minicbf.dump)
set_property(TEST cmp-minicbf_original.dump-minicbf.dump APPEND PROPERTY DEPENDS minicbf_original.dump)
set_property(TEST cmp-minicbf_original.dump-minicbf.dump APPEND PROPERTY DEPENDS minicbf.dump)

# round-trip cbf2nexus & nexus2cbf tests using i19 data

# generate the data
add_test(i19-1.h5 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cbf2nexus -c zlib --list -o ${CBF__DATA}/i19-1.h5 ${CBF_DATADIRI}/1191_00005.cbf)

add_test(i19-1.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/nexus2cbf -o ${CBF__DATA}/i19-1.cbf ${CBF__DATA}/i19-1.h5)
set_property(TEST i19-1.cbf APPEND PROPERTY DEPENDS i19-1.h5)

add_test(i19-2.h5 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cbf2nexus -c zlib --list -o ${CBF__DATA}/i19-2.h5 ${CBF__DATA}/i19-1.cbf)
set_property(TEST i19-2.h5 APPEND PROPERTY DEPENDS i19-1.cbf)

add_test(i19-2.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/nexus2cbf -o ${CBF__DATA}/i19-2.cbf ${CBF__DATA}/i19-2.h5)
set_property(TEST i19-2.cbf APPEND PROPERTY DEPENDS i19-2.h5)

# dump the content of generated hdf5 files & use 'cbf_tail' to strip off some file names
add_test(
i19-1.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/i19-1.h5
-Doutput=${CBF__DATA}/i19-1.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST i19-1.dump APPEND PROPERTY DEPENDS i19-1.h5)
add_test(
i19-2.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/i19-2.h5
-Doutput=${CBF__DATA}/i19-2.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST i19-2.dump APPEND PROPERTY DEPENDS i19-2.h5)

# compare dumped hdf5 file content
add_test(cmp-i19-1.dump-i19-2.dump ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/i19-1.dump ${CBF__DATA}/i19-2.dump)
set_property(TEST cmp-i19-1.dump-i19-2.dump APPEND PROPERTY DEPENDS i19-1.dump)
set_property(TEST cmp-i19-1.dump-i19-2.dump APPEND PROPERTY DEPENDS i19-2.dump)

# round-trip cbf2nexus & nexus2cbf tests using i03 data

# generate the data
add_test(i03-1.h5 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cbf2nexus -c zlib --list -o ${CBF__DATA}/i03-1.h5 ${CBF_DATADIRI}/thaumatin_die_M1S5_1_0005_2.cbf)

add_test(i03-1.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/nexus2cbf -o ${CBF__DATA}/i03-1.cbf ${CBF__DATA}/i03-1.h5)
set_property(TEST i03-1.cbf APPEND PROPERTY DEPENDS i03-1.h5)

add_test(i03-2.h5 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cbf2nexus -c zlib --list -o ${CBF__DATA}/i03-2.h5 ${CBF__DATA}/i03-1.cbf)
set_property(TEST i03-2.h5 APPEND PROPERTY DEPENDS i03-1.cbf)

add_test(i03-2.cbf ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/nexus2cbf -o ${CBF__DATA}/i03-2.cbf ${CBF__DATA}/i03-2.h5)
set_property(TEST i03-2.cbf APPEND PROPERTY DEPENDS i03-2.h5)

# dump the content of generated hdf5 files & use 'cbf_tail' to strip off some file names
add_test(
i03-1.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/i03-1.h5
-Doutput=${CBF__DATA}/i03-1.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST i03-1.dump APPEND PROPERTY DEPENDS i03-1.h5)
add_test(
i03-2.dump
${CMAKE_COMMAND}
-Dinput=${CBF__DATA}/i03-2.h5
-Doutput=${CBF__DATA}/i03-2.dump
-P ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/h5dump.cmake
)
set_property(TEST i03-2.dump APPEND PROPERTY DEPENDS i03-2.h5)

# compare dumped hdf5 file content
add_test(cmp-i03-1.dump-i03-2.dump ${CMAKE_COMMAND} -E compare_files ${CBF__DATA}/i03-1.dump ${CBF__DATA}/i03-2.dump)
set_property(TEST cmp-i03-1.dump-i03-2.dump APPEND PROPERTY DEPENDS i03-1.dump)
set_property(TEST cmp-i03-1.dump-i03-2.dump APPEND PROPERTY DEPENDS i03-2.dump)


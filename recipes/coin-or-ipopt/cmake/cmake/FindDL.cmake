###############################################################################
# CMake macro to find libdl library.
#
# On success, the macro sets the following variables:
# DL_FOUND       = if the library found
# DL_LIBRARY     = full path to the library
# DL_INCLUDE_DIR = where to find the library headers 
#
# Author: Mateusz Loskot <mateusz@loskot.net>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
###############################################################################
if(DL_INCLUDE_DIR)
  set(DL_FIND_QUIETLY TRUE)
endif()

find_path(DL_INCLUDE_DIR dlfcn.h)
find_library(DL_LIBRARY NAMES dl)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DL DEFAULT_MSG DL_LIBRARY DL_INCLUDE_DIR)

if(NOT DL_FOUND)
    # if dlopen can be found without linking in dl then,
    # dlopen is part of libc, so don't need to link extra libs.
    check_function_exists(dlopen DL_FOUND)
    set(DL_LIBRARY "")
endif()

set(DL_LIBRARIES ${DL_LIBRARY})

mark_as_advanced(DL_LIBRARY DL_INCLUDE_DIR)


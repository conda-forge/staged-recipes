# - Check if the DIR symbol exists like in AC_HEADER_DIRENT.
# CHECK_DIRSYMBOL_EXISTS(FILES VARIABLE)
#
#  FILES    - include files to check
#  VARIABLE - variable to return result
#
# This module is a small but important variation on CheckSymbolExists.cmake.
# The symbol always searched for is DIR, and the test programme follows
# the AC_HEADER_DIRENT test programme rather than the CheckSymbolExists.cmake
# test programme which always fails since DIR tends to be typedef'd
# rather than #define'd.
# 
# The following variables may be set before calling this macro to
# modify the way the check is run:
#
#  CMAKE_REQUIRED_FLAGS = string of compile command line flags
#  CMAKE_REQUIRED_DEFINITIONS = list of macros to define (-DFOO=bar)
#  CMAKE_REQUIRED_INCLUDES = list of include directories
#  CMAKE_REQUIRED_LIBRARIES = list of libraries to link

macro(CHECK_DIRSYMBOL_EXISTS FILES VARIABLE)
  if (NOT DEFINED ${VARIABLE})
    set(CMAKE_CONFIGURABLE_FILE_CONTENT "/* */\n")
    set(MACRO_CHECK_DIRSYMBOL_EXISTS_FLAGS ${CMAKE_REQUIRED_FLAGS})
    
    if (CMAKE_REQUIRED_LIBRARIES)
      set(CHECK_DIRSYMBOL_EXISTS_LIBS "-DLINK_LIBRARIES:STRING=${CMAKE_REQUIRED_LIBRARIES}")
    else ()
      set(CHECK_DIRSYMBOL_EXISTS_LIBS)
    endif ()
    
    if(CMAKE_REQUIRED_INCLUDES)
      set(CMAKE_DIRSYMBOL_EXISTS_INCLUDES "-DINCLUDE_DIRECTORIES:STRING=${CMAKE_REQUIRED_INCLUDES}")
    else ()
      set(CMAKE_DIRSYMBOL_EXISTS_INCLUDES)
    endif ()
    
    foreach(FILE ${FILES})
      set(CMAKE_CONFIGURABLE_FILE_CONTENT "${CMAKE_CONFIGURABLE_FILE_CONTENT}#include <${FILE}>\n")
    endforeach ()
    
    set(CMAKE_CONFIGURABLE_FILE_CONTENT "${CMAKE_CONFIGURABLE_FILE_CONTENT}\nint main()\n{if ((DIR *) 0) return 0;}\n")

    configure_file("${CMAKE_ROOT}/Modules/CMakeConfigurableFile.in" "${CMAKE_BINARY_DIR}/CMakeFiles/CMakeTmp/CheckDIRSymbolExists.c" @ONLY)

    message(STATUS "Looking for DIR in ${FILES}")
    
    try_compile(${VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeTmp/CheckDIRSymbolExists.c
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      CMAKE_FLAGS 
      -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_DIRSYMBOL_EXISTS_FLAGS}
      "${CHECK_DIRSYMBOL_EXISTS_LIBS}"
      "${CMAKE_DIRSYMBOL_EXISTS_INCLUDES}"
      OUTPUT_VARIABLE OUTPUT)
    
    if (${VARIABLE})
      message(STATUS "Looking for DIR in ${FILES} - found")
      set(${VARIABLE} 1 CACHE INTERNAL "Have symbol DIR")
      file(APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeOutput.log 
        "Determining if the DIR symbol is defined as in AC_HEADER_DIRENT "
        "passed with the following output:\n"
        "${OUTPUT}\nFile ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeTmp/CheckDIRSymbolExists.c:\n"
        "${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
    else ()
      message(STATUS "Looking for DIR in ${FILES} - not found.")
      set(${VARIABLE} "" CACHE INTERNAL "Have symbol DIR")
      file(APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeError.log 
        "Determining if the DIR symbol is defined as in AC_HEADER_DIRENT "
        "failed with the following output:\n"
        "${OUTPUT}\nFile ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeTmp/CheckDIRSymbolExists.c:\n"
        "${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
    endif ()
  endif ()
endmacro ()

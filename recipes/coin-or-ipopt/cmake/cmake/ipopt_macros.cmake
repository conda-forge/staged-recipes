# Attempt to automatically determine the Fortran name-mangling scheme. 
# We do this by:
#
#  1) creating a library from a Fortran source file which defines a function "mysub"
#  2) attempting to link with this library a C source file which calls the "mysub"
#     function using various possible schemes (6 different schemes, corresponding
#     to all combinations lower/upper case and none/one/two underscores)
#
# Note that, since names of symbols with and without underscore may be mangled 
# differently (e.g. g77 mangles mysub to mysub_ and my_sub to my_sub__), we have
# to consider both cases. The two name mangling schemes are encoded in the cached
# variables SCHEME_NO_UNDERSCORES and SCHEME_WITH_UNDERSCORES.
#
# Once the name mangling schemes are determined, we use them to define two C
# preprocessor macros, F77_FUNC and F77_FUNC_, corresponding to the two cases:
# symbols with names not containing underscores and symbols with names containing 
# underscores. For example, if using g77 the definitions of these two macros will be:
#     #define F77_FUNC(name,NAME) name ## _
#     #define F77_FUNC_(name,NAME) name ## __
# The appropriate #define lines are stored in the cached variables DEFINE_F77_FUNC and
# DEFINE_F77_FUNC_, respectively, and can be used to generate a configuration header
# file (using CONFIGURE_FILE).

# Need Fortran support for this
ENABLE_LANGUAGE(Fortran)

# Make sure that the following tests use the C and Fortran flags corresponding
# to the current build type. These flags are stored in the variables TMP_C_FLAGS 
# and TMP_Fortran_FLAGS, respectively, and are used in the generated CMakeLists files.
IF(NOT CMAKE_BUILD_TYPE)
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS})
ENDIF(NOT CMAKE_BUILD_TYPE)
IF(CMAKE_BUILD_TYPE MATCHES "Default")
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS})
ENDIF(CMAKE_BUILD_TYPE MATCHES "Default")
IF(CMAKE_BUILD_TYPE MATCHES "Release")
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS_RELEASE})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_RELEASE})
ENDIF(CMAKE_BUILD_TYPE MATCHES "Release")
IF(CMAKE_BUILD_TYPE MATCHES "Debug")
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS_DEBUG})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_DEBUG})
ENDIF(CMAKE_BUILD_TYPE MATCHES "Debug")
IF(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS_RELWITHDEBINFO})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_RELWITHDEBINFO})
ENDIF(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
IF(CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
  SET(TMP_C_FLAGS       ${CMAKE_C_FLAGS_MINSIZE})
  SET(TMP_Fortran_FLAGS ${CMAKE_Fortran_FLAGS_MINSIZE})
ENDIF(CMAKE_BUILD_TYPE MATCHES "MinSizeRel")

# Create a CMakeLists.txt file which will generate the "flib" library
FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CMakeLists.txt
  "PROJECT(FortranTest Fortran)\n"
  "SET(CMAKE_VERBOSE_MAKEFILE ON)\n"
  "SET(CMAKE_Fortran_FLAGS \"${TMP_Fortran_FLAGS}\")\n"
  "ADD_LIBRARY(flib ftest.f)\n"
  )

# Create a simple Fortran source which defines two subroutines, "mysub" and "my_sub"
FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/ftest.f
  "        SUBROUTINE mysub\n"
  "        RETURN\n"
  "        END\n"
  "        SUBROUTINE my_sub\n"
  "        RETURN\n"
  "        END\n"
  )

# Use TRY_COMPILE to make the target "flib"
TRY_COMPILE(
  FTEST_OK
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
  flib
  OUTPUT_VARIABLE MY_OUTPUT)

message("${MY_OUTPUT}")

# Initialize the name mangling schemes for symbol names 
# with and without underscores
SET(SCHEME_NO_UNDERSCORES "" 
  CACHE INTERNAL "Name mangling scheme (symbol names without underscores)")
SET(SCHEME_WITH_UNDERSCORES "" 
  CACHE INTERNAL "Name mangling scheme (symbol names with underscores)")

# Continue only if we were successful in creating the "flib" library
IF(FTEST_OK)
  
  # CASE 1: symbol names WITHOUT undersores
  # ---------------------------------------
  
  # Overwrite CMakeLists.txt with one which will generate the "ctest1" executable
  FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CMakeLists.txt
    "PROJECT(FortranTest C)\n"
    "SET(CMAKE_VERBOSE_MAKEFILE ON)\n"
    "SET(CMAKE_C_FLAGS \"${TMP_C_FLAGS}\")\n"
    "ADD_EXECUTABLE(ctest1 ctest1.c)\n"
    "FIND_LIBRARY(FLIB flib ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp)\n"
    "TARGET_LINK_LIBRARIES(ctest1 \${FLIB})\n")
  
  # Define the list "options" of all possible schemes that we want to consider
  # Get its length and initialize the counter "iopt" to zero
  SET(options mysub mysub_ mysub__ MYSUB MYSUB_ MYSUB__)
  LIST(LENGTH options imax)
  SET(iopt 0)
  
  # We will attempt to sucessfully generate the "ctest" executable as long as
  # there still are entries in the "options" list
  WHILE(${iopt} LESS ${imax})   
    
    # Get the current list entry (current scheme)
    LIST(GET options ${iopt} opt)
    
    # Generate C source which calls the "mysub" function using the current scheme
    FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/ctest1.c
      "int main(){${opt}();return(0);}\n")
    
    # Use TRY_COMPILE to make the "ctest1" executable from the current C source
    # and linking to the previously created "flib" library.
    TRY_COMPILE(
      CTEST_OK
      ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
      ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
      ctest1
      OUTPUT_VARIABLE MY_OUTPUT)
    
    # To ensure we do not use stuff from the previous attempts, we must remove the
    # CMakeFiles directory.
    # ??? I didn't think I'll have to do this, but it doesn't work otherwise
    FILE(REMOVE_RECURSE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CMakeFiles)
    
    # Test if we successfully created the "ctest" executable.
    # If yes, flag that we have successfuly determined the name mangling scheme,
    # save the current scheme, and set the counter "iopt" to "imax" so that we
    # exit the while loop.
    # Otherwise, increment the counter "iopt" and go back in the while loop.
    IF(CTEST_OK)
      SET(SCHEME_NO_UNDERSCORES ${opt} 
        CACHE INTERNAL "Name mangling scheme (symbol names without underscores)")
      SET(iopt ${imax})
    ELSE(CTEST_OK)
      MATH(EXPR iopt ${iopt}+1)
    ENDIF(CTEST_OK)
    
  ENDWHILE(${iopt} LESS ${imax})   
  
  # CASE 2: symbol names WITH undersores
  # ------------------------------------
  
  FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CMakeLists.txt
    "PROJECT(FortranTest C)\n"
    "SET(CMAKE_VERBOSE_MAKEFILE ON)\n"
    "SET(CMAKE_C_FLAGS \"${TMP_C_FLAGS}\")\n"
    "ADD_EXECUTABLE(ctest2 ctest2.c)\n"
    "FIND_LIBRARY(FLIB flib ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp)\n"
    "TARGET_LINK_LIBRARIES(ctest2 \${FLIB})\n")
  
  SET(options my_sub my_sub_ my_sub__ MY_SUB MY_SUB_ MY_SUB__)
  LIST(LENGTH options imax)
  SET(iopt 0)
  
  WHILE(${iopt} LESS ${imax})   
    LIST(GET options ${iopt} opt)
    FILE(WRITE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/ctest2.c
      "int main(){${opt}();return(0);}\n")
    TRY_COMPILE(
      CTEST_OK
      ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
      ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp
      ctest2
      OUTPUT_VARIABLE MY_OUTPUT)
    FILE(REMOVE_RECURSE ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CMakeFiles)
    IF(CTEST_OK)
      SET(SCHEME_WITH_UNDERSCORES ${opt} 
        CACHE INTERNAL "Name mangling scheme (symbol names with underscores)")
      SET(iopt ${imax})
    ELSE(CTEST_OK)
      MATH(EXPR iopt ${iopt}+1)
    ENDIF(CTEST_OK)
  ENDWHILE(${iopt} LESS ${imax})   
  
ENDIF(FTEST_OK)

# If the name mangling scheme of symbol names not containing underscores
# was successfully determined, set the appropriate C preprocessor macro

SET(CPP_macro "")

IF(SCHEME_NO_UNDERSCORES)
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "mysub")
    SET(CPP_macro "#define F77_FUNC(name,NAME) name")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "mysub")
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "mysub_")
    SET(CPP_macro "#define F77_FUNC(name,NAME) name ## _")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "mysub_")      
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "mysub__")
    SET(CPP_macro "#define F77_FUNC(name,NAME) name ## __")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "mysub__")
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB")
    SET(CPP_macro "#define F77_FUNC(name,NAME) NAME")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB")
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB_")
    SET(CPP_macro "#define F77_FUNC(name,NAME) NAME ## _")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB_")
  
  IF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB__")
    SET(CPP_macro "#define F77_FUNC(name,NAME) NAME ## __")
  ENDIF(SCHEME_NO_UNDERSCORES MATCHES "MYSUB__")
  
ENDIF(SCHEME_NO_UNDERSCORES)

SET(DEFINE_F77_FUNC ${CPP_macro}
  CACHE INTERNAL "CPP macro for name mangling scheme of symbols without underscores")

IF(SCHEME_NO_UNDERSCORES)
  MESSAGE("Name mangling scheme for symbol names without underscores:\n"
    "   mysub  ->  ${SCHEME_NO_UNDERSCORES}\n"
    "   ${DEFINE_F77_FUNC}")
ELSE(SCHEME_NO_UNDERSCORES)
  MESSAGE("Unable to determine name mangling scheme for symbol names without underscores!")
ENDIF(SCHEME_NO_UNDERSCORES)

# If the name mangling scheme of symbol names containing underscores
# was successfully determined, set the appropriate C preprocessor macro

SET(CPP_macro "")

IF(SCHEME_WITH_UNDERSCORES)
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) name")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub")
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub_")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) name ## _")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub_")      
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub__")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) name ## __")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "my_sub__")
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) NAME")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB")
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB_")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) NAME ## _")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB_")
  
  IF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB__")
    SET(CPP_macro "#define F77_FUNC_(name,NAME) NAME ## __")
  ENDIF(SCHEME_WITH_UNDERSCORES MATCHES "MY_SUB__")
  
ENDIF(SCHEME_WITH_UNDERSCORES)

SET(DEFINE_F77_FUNC_ "${CPP_macro}" 
  CACHE INTERNAL "CPP macro for name mangling scheme of symbols with underscores")

IF(SCHEME_WITH_UNDERSCORES)
  MESSAGE("Name mangling scheme for symbol names with underscores:\n"
    "   my_sub ->  ${SCHEME_WITH_UNDERSCORES}\n"
    "   ${DEFINE_F77_FUNC_}")
ELSE(SCHEME_WITH_UNDERSCORES)
  MESSAGE("Unable to determine name mangling scheme for symbol names with underscores!")
ENDIF(SCHEME_WITH_UNDERSCORES)
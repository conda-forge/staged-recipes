# based on http://www.cmake.org/Wiki/CmakeMingw

# the name of the target operating system
SET(CMAKE_SYSTEM_NAME Windows)

# Choose an appropriate compiler prefix

# for classical mingw32
# see http://www.mingw.org/
#set(COMPILER_PREFIX "i586-mingw32msvc")

# for 32 or 64 bits mingw-w64
# see http://mingw-w64.sourceforge.net/
set(COMPILER_PREFIX "x86_64-w64-mingw32")

# which compilers to use for C and C++
find_program(CMAKE_RC_COMPILER NAMES      ${COMPILER_PREFIX}-windres)
find_program(CMAKE_C_COMPILER NAMES       ${COMPILER_PREFIX}-gcc)
find_program(CMAKE_CXX_COMPILER NAMES     ${COMPILER_PREFIX}-g++)
find_program(CMAKE_Fortran_COMPILER NAMES ${COMPILER_PREFIX}-gfortran)

# here is the target environment located
SET(CMAKE_FIND_ROOT_PATH  /usr/${COMPILER_PREFIX})

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
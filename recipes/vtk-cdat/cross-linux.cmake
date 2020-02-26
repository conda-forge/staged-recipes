set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_NAME})
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})

# specify the cross compiler
set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})

# where is the target environment
set(CMAKE_FIND_ROOT_PATH "$ENV{PREFIX};$ENV{BUILD_PREFIX}/$ENV{HOST}/sysroot")
set(CMAKE_SYSROOT $ENV{BUILD_PREFIX}/$ENV{HOST}/sysroot)

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

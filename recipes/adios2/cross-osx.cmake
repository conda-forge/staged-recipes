# this one is important
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_PLATFORM Darwin)
# this one not so much
set(CMAKE_SYSTEM_VERSION 1)

# architecture
set(CMAKE_SYSTEM_PROCESSOR $ENV{OSX_ARCH})

# specify the cross compiler
set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})

# where is the target environment
set(CMAKE_OSX_SYSROOT $ENV{CONDA_BUILD_SYSROOT})
set(CMAKE_SYSTEM_PREFIX_PATH $ENV{PREFIX} $ENV{CONDA_BUILD_SYSROOT})
set(CMAKE_FIND_ROOT_PATH $ENV{PREFIX} $ENV{CONDA_BUILD_SYSROOT})

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

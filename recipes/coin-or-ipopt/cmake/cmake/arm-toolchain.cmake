# the name of the target operating system
set(CMAKE_SYSTEM_NAME Generic)
#set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

# which compilers to use for C and C++
set(CMAKE_C_COMPILER   arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)

set(CMAKE_AR      "arm-none-eabi-ar"     CACHE PATH "" FORCE)
set(CMAKE_RANLIB  "arm-none-eabi-ranlib" CACHE PATH "" FORCE)
set(CMAKE_LINKER  "arm-none-eabi-ld"     CACHE PATH "" FORCE)
set(CMAKE_SIZE    "arm-none-eabi-size")
set(CMAKE_OBJCOPY "arm-none-eabi-objcopy")

# $ dnf install arm-none-eabi-gcc-cs-c++.x86_64 arm-none-eabi-gcc-cs.x86_64
# $ dnf install arm-none-eabi-newlib

set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

#set(CMAKE_C_COMPILER_WORKS 1)
#set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# error "NEON intrinsics not available with the soft-float ABI.  Please use -mfloat-abi=softfp + -mthumb or -mfloat-abi=hard"
set(CMAKE_CXX_FLAGS "-mfloat-abi=hard --specs=nosys.specs")
set(CMAKE_C_FLAGS "-mfloat-abi=hard --specs=nosys.specs")

set(CMAKE_CXX_EXTENSIONS OFF)

# here is the target environment located
set(CMAKE_FIND_ROOT_PATH /usr/arm-non-eabi/ /home/user/arm-install )
set(CMAKE_STAGING_PREFIX /home/user/stage)

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

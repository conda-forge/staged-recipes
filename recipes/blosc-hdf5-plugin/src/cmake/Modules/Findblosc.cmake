#[[
FIND_PATH(BLOSC_INCLUDE_DIR "blosc.h")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(blosc DEFAULT_MSG BLOSC_LIBRARY BLOSC_INCLUDE_DIR HINTS ${CMAKE_PREFIX_PATH})


#IF(blosc_FOUND)
#    SET(BLOSC_INCLUDE_DIRS "${BLOSC_INCLUDE_DIR}")
#endif()
]]


# check environment variable
set(_blosc_ENV_ROOT_DIR "$ENV{BLOSC_ROOT_DIR}")

if(NOT BLOSC_ROOT_DIR AND _blosc_ENV_ROOT_DIR)
    SET(BLOSC_ROOT_DIR "${_blosc_ENV_ROOT_DIR}")
endif()

# locate header and lib
if(BLOSC_ROOT_DIR)
    find_path(BLOSC_INCLUDE_DIR "blosc.h" PATHS ${BLOSC_ROOT_DIR})
    find_library(BLOSC_LIBRARY NAMES blosc)
else()
    find_path(BLOSC_INCLUDE_DIR "blosc.h")
    find_library(BLOSC_LIBRARY NAMES blosc)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(blosc DEFAULT_MSG BLOSC_LIBRARY BLOSC_INCLUDE_DIR)

if(blosc_FOUND)
    set(BLOSC_INCLUDE_DIRS ${BLOSC_INCLUDE_DIR})
    set(BLOSC_LIBRARIES ${BLOSC_LIBRARY})

endif()
message(STATUS "BLOSC_INCLUDE_DIR = ${BLOSC_INCLUDE_DIR}")
message(STATUS "BLOSC_LIBRARY = ${BLOSC_LIBRARY}")

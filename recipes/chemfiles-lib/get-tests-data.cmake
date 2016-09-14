# Cmake script to download and unpack test data files for chemfiles
#
# The tests files are ususlly updated using a git submodule, but git is not
# available, so this script download and unpack the archive.
#
# This is written as a cmake script to be cross-platform

set(COMMIT c07bdfb010a6a4a0c5940bb9db6348e963dda43d)

file(DOWNLOAD
    https://github.com/chemfiles/tests-data/archive/${COMMIT}.tar.gz
    ./tests-data-${COMMIT}.tar.gz
    EXPECTED_MD5 "2ef24f94fe5e6d7514803edea02b177d"
)

execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf tests-data-${COMMIT}.tar.gz
    WORKING_DIRECTORY ${SRC_DIR}
)

file(GLOB DATA_DIRS RELATIVE ${SRC_DIR}/tests-data-${COMMIT} tests-data-${COMMIT}/*)
foreach(path ${DATA_DIRS})
    file(RENAME tests-data-${COMMIT}/${path} ${SRC_DIR}/tests/data/${path})
endforeach()

# Build script for kdsingleapplication, auto-discovered by
# rattler-build on unix (build.bat is the Windows counterpart).
# Runs with the build and host prefixes activated; ${CMAKE_ARGS} is
# set by rattler-build to the platform/compiler flags.
set -eu

cmake -B build -G Ninja \
    ${CMAKE_ARGS:-} \
    -DKDSingleApplication_QT6=ON \
    -DKDSingleApplication_EXAMPLES=OFF \
    -DKDSingleApplication_TESTS=OFF
cmake --build build
cmake --install build

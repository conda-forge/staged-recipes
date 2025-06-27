#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -fpermissive -std=c++17"

# `ptsname_r` compatibility for macOS
if [[ "${target_platform}" == "osx-"* ]]; then
    # Add necessary includes and compatibility function at the top of the file
    sed -i.bak '1i\
#if defined(__APPLE__)\
#include <stdlib.h>\
#include <unistd.h>\
#include <string.h>\
static int ptsname_compat(int fd, char* buf, size_t buflen) {\
    char* name = ptsname(fd);\
    if (!name) return -1;\
    if (strlen(name) >= buflen) return -1;\
    strcpy(buf, name);\
    return 0;\
}\
#else\
#define ptsname_compat ptsname_r\
#endif\
' src/readline_curses.cc

    # Replace ptsname_r calls with ptsname_compat
    sed -i.bak 's/ptsname_r(/ptsname_compat(/g' src/readline_curses.cc
fi

# Build prqlc-c library in advance
cd src/third-party/prqlc-c
cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
cargo build --release
cd ${SRC_DIR}
PRQLC_DIR=${SRC_DIR}/src/third-party/prqlc-c/target
mkdir -p ${PRQLC_DIR}/release
find "${PRQLC_DIR}" -type f \( -name 'libprqlc_c.a' -o -name 'libprqlc_c.d' \) \
    -exec cp {} "${PRQLC_DIR}/release/" \;

./configure \
    --prefix=${PREFIX} \
    --with-sqlite3=${PREFIX} \
    --with-readline=${PREFIX} \
    --with-libarchive=${PREFIX} \
    --with-ncurses=${PREFIX} \
    --with-pcre2=${PREFIX} \
    --with-libcurl=${PREFIX} \
    --with-jemalloc=${PREFIX} \
    --disable-dependency-tracking \
    --disable-silent-rules

make -j${CPU_COUNT} V=1
make install

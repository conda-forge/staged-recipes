#!/bin/bash

CHOST=${macos_machine}

FINAL_CPPFLAGS="-D_FORTIFY_SOURCE=2 -mmacosx-version-min=${macos_min_version}"
FINAL_CFLAGS="-march=core2 -mtune=haswell -mssse3 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe"
FINAL_CXXFLAGS="-march=core2 -mtune=haswell -mssse3 -ftree-vectorize -fPIC -fPIE -fstack-protector-strong -O2 -pipe -stdlib=libc++ -fvisibility-inlines-hidden -std=c++14 -fmessage-length=0"
# These are the LDFLAGS for when the linker is being driven by a compiler, i.e. with -Wl,
FINAL_LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs"
# These are the LDFLAGS for when the linker is being called directly, i.e. without -Wl,
FINAL_LDFLAGS_LD="-pie -headerpad_max_install_names -dead_strip_dylibs"
FINAL_DEBUG_CFLAGS="-Og -g -Wall -Wextra"
FINAL_DEBUG_CXXFLAGS="-Og -g -Wall -Wextra"
FINAL_PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata_x86_64_apple_darwin13_4_0"

find "${RECIPE_DIR}" -name "*activate*.sh" -exec cp {} . \;

find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${CHOST}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CPPFLAGS@|${FINAL_CPPFLAGS}|g"             "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CFLAGS@|${FINAL_CFLAGS}|g"                 "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CFLAGS@|${FINAL_DEBUG_CFLAGS}|g"     "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CXXFLAGS@|${FINAL_CXXFLAGS}|g"             "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CXXFLAGS@|${FINAL_DEBUG_CXXFLAGS}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CXXFLAGS@|${FINAL_DEBUG_CXXFLAGS}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LDFLAGS@|${FINAL_LDFLAGS}|g"               "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LDFLAGS_LD@|${FINAL_LDFLAGS_LD}|g"         "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@_PYTHON_SYSCONFIGDATA_NAME@|${FINAL_PYTHON_SYSCONFIGDATA_NAME}|g"  "{}" \;
find . -name "*activate*.sh.bak" -exec rm "{}" \;

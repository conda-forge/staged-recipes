#!/bin/bash

set -e
set -x

# explicitly call out pylibfdt target because the detection in the makefile isn't working
# dtc's makefile clobbers the env vars so pass them on cmdline
make all pylibfdt V=1 \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="-I libfdt $CPPFLAGS"

# pylibfdt tests depend on outputs of other tests that happen to
# run before them.  We run full 'make check' in the build directory
# so that we can copy those binary artifacts (dtb files) in pylibfdt's
# test.source_files
make check V=1 \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="-I libfdt -I . $CPPFLAGS"

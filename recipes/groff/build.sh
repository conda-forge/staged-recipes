set -x

autoreconf -vfi
./configure --prefix=$PREFIX

# Workaround for long shebang lines
find $SRC_DIR -type f | \
    xargs -L1 perl -i.bak \
        -pe 's,^#!\@PERL\@ -w,#!/usr/bin/env perl,;' \
        -pe "s,perl -w,perl,;" \
        -pe "s,$PREFIX/bin/perl,/usr/bin/env perl,;"

# Workarond for dependency issue
make -j${CPU_COUNT} font/devpdf/build_font_files
make -j${CPU_COUNT} install

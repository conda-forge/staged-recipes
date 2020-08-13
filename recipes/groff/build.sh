set -x

autoreconf -vfi
./configure --prefix=$PREFIX

# Workaround for long shebang lines
find $SRC_DIR -type f | \
    xargs -L1 perl -i.bak \
        -pe 's,^#!\@PERL\@ -w,#!/usr/bin/env perl,;' \
        -pe "s,perl -w,perl,;" \
        -pe "s,$PREFIX/bin/perl,/usr/bin/env perl,;"

# Workaround for randomly occuring failure due to incorrect dep-graph in Makefile
# /usr/bin/install: cannot stat './font/devpdf/download': No such file or directory
make -j${CPU_COUNT} font/devpdf/build_font_files
make -j${CPU_COUNT} install
make check

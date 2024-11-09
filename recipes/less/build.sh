./configure --prefix=${PREFIX} --sysconfdir=/etc --with-regex=pcre2 --with-compiledby='Conda-forge' --with-tlib=ncurses -ltinfo
make
make install
# - install -Dm 0755 less lesskey lessecho ${PREFIX}/bin/less

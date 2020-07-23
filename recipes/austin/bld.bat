autoreconf --install
./configure --prefix=%PREFIX%
make
make install
make check

%PYTHON% -m pip install . -vv


#!/bin/bash
mkdir build && cd build
../configure --prefix=${PREFIX}
make
make install

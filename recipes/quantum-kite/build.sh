#! /bin/sh
#
# build.sh
# Copyright (C) 2021 Edward Higgins <ed.higgins@york.ac.uk>
#
# Distributed under terms of the MIT license.
#
KITE_ROOT=`pwd`

echo "---EJH--- Compiling KITEx"
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j${CPU_COUNT}
make install

echo "---EJH--- Compiling KITE-tools"
cd $KITE_ROOT
cd tools
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j${CPU_COUNT}
make install

echo "---EJH--- Installing kite.py"
cd $KITE_ROOT
mkdir kite
mv kite.py kite/kite.py
touch kite/__init__.py
cat > setup.py <<EOF
#!/usr/bin/env python
from distutils.core import setup

setup(name='kite',
      version='1.0',
      description='',
      author='Edward Higgins',
      author_email='ed.higgins@york.ac.uk',
      url='https://quantum-kite.com',
      packages=['kite'],
     )

EOF
echo "---EJH--- Wrote setup.py:"
cat setup.py

python setup.py install
echo "---EJH--- Done!"

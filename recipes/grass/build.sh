#!/bin/sh

rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX > cmake.log 2>&1
if [ $? -ne 0 ]; then
    echo "CMAKE FAILED:"
    cat cmake.log
    exit 1
fi

make -j$(nproc) > make.log 2>&1
if [ $? -ne 0 ]; then
    echo "MAKE FAILED:"
    tail -50 make.log
    exit 1
fi

echo "Installing GRASS to $PREFIX..."
make install > install.log 2>&1
if [ $? -ne 0 ]; then
    echo "MAKE INSTALL FAILED:"
    cat install.log
    exit 1
fi
if [ -d "$PREFIX/lib64" ]; then
    mv $PREFIX/lib64 $PREFIX/opt
fi
if [ -d "$PREFIX/opt/grass85" ]; then
    mv $PREFIX/opt/grass85 $PREFIX/opt/grass
fi

compile_prefix=$(echo $PREFIX |
	sed -E 's#_h_env_placehold[^/]+#work/build/output#')
sed "s#@compile_prefix@#$compile_prefix#g" < $RECIPE_DIR/post-link.sh.in \
	> $PREFIX/bin/.grass-post-link.sh
chmod +x $PREFIX/bin/.grass-post-link.sh

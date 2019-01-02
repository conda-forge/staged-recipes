#if [ -f "$BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld" ]; then
#   ln -s $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld $BUILD_PREFIX/bin/ld
#fi
export LD="$BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld"
echo "main = putStr \"smalltest\"" > Main.hs
ghc -v -O0 -threaded -L$PREFIX/lib -fasm -o smalltest Main.hs 
./smalltest

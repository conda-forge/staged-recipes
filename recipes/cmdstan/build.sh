echo "TBB_CXX_TYPE=$c_compiler"  >> make/local

make clean-all

ls $PREFIX/lib
TBB_LIB=$PREFIX/lib make -j8 build

mkdir -p $PREFIX/bin
cp -r . $PREFIX/bin/cmdstan

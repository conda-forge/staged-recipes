echo "TBB_CXX_TYPE=$c_compiler"  >> make/local

make clean-all

make -j8 build

cp -r . $PREFIX/cmdstan

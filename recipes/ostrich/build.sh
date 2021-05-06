# Temporarily fix stuff with the GH ostrich repo.
# (1) Replace "g++" by $(CXX) in the Makefile
sed -i  -E 's/g\+\+/\$\(CXX\)/' make/makefile

# Compile
cd make
make GCC

# Install
mkdir -p $PREFIX/bin/
cp ./Ostrich $PREFIX/bin/ostrich

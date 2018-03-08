echo "/usr/bin/cc is: $(readlink /usr/bin/cc)"
echo "Tryna run cc"
cc --version
echo "Clang is: $(which clang)"

echo "/usr/bin/c++ is: $(readlink /usr/bin/c++)"

echo "Tryna run c++"
c++ --version

echo "Ar is: $(readlink /usr/bin/ar)"
echo "Ar is at: $(which ar)"

echo "Unsetting some things I want to set myself"
unset OSX_ARCH
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

echo "HERE IS THE ENVIRONMENT:"
printenv

python -m pip install --no-deps --ignore-installed .



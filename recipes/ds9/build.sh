sed -i 's/tclsh/$(TCLSH_PROG)/' ds9/make.include

if [[ $(uname -s) == "Linux" ]]; then
  ./unix/configure
else
  ./macos/configure
fi

make

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin

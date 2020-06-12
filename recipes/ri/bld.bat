sed -i.bak '2d' makefile
sed -i.bak 's/sys\///g' include/timer.h

mkdir -p "$PREFIX/bin"
make -B
cp ri36 "$PREFIX/bin"
chmod +x "$PREFIX/bin/ri36"

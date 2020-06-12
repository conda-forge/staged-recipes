sed -i.bak '2d' makefile

mkdir -p "$PREFIX/bin"
make -B
cp ri36 "$PREFIX/bin"
chmod +x "$PREFIX/bin/ri36"


sed -i.bak 's/<sys\/time.h>/sys\/time.h/g' include/timer.h

mkdir -p "$PREFIX/bin"
make -B
cp ri36 "$PREFIX/bin"
chmod +x "$PREFIX/bin/ri36"

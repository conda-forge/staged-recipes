
cp $RECIPE_DIR/sys ./sys

sed -i.bak 's/<sys\/time.h>/"sys\/time.h"/g' include/timer.h

ls

mkdir -p "$PREFIX/bin"
make -B
cp ri36 "$PREFIX/bin"
chmod +x "$PREFIX/bin/ri36"



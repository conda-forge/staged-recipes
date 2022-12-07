mkdir -p "$PREFIX/opt/genv"
cp -a "$SRC_DIR/." "$PREFIX/opt/genv"

mkdir -p "$PREFIX/bin"
ln -s "$PREFIX/opt/genv/bin/genv" "$PREFIX/bin/genv"

for CHANGE in "activate" "deactivate"
do
    mkdir -p "$PREFIX/etc/conda/$CHANGE.d"
    cp "$RECIPE_DIR/$CHANGE.sh" "$PREFIX/etc/conda/$CHANGE.d/genv_$CHANGE.sh"
done

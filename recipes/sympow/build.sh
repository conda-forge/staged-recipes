./Configure
make

mkdir -p "$PREFIX"/{bin,share/sympow}
cp -r *.gp datafiles "$PREFIX"/share/sympow
cp sympow "$PREFIX"/bin/sympow_bin
cp new_data "$PREFIX"/bin/new_data
install -m755 "$RECIPE_DIR"/sympow.sh "$PREFIX"/bin/sympow

pushd "$PREFIX"/share/sympow/datafiles

for file in *.txt; do
  "$SRC_DIR"/sympow -txt2bin "$(grep -c AT $file)" <$file ${file/txt/bin}
done

popd

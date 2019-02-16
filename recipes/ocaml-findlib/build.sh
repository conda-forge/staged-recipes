./configure
make all
make opt
make install

sed -i.bak 's/let config_file.*/let config_file = (Sys.getenv "OCAMLFIND_CONF");;/g' src/findlib/findlib_config.mlp
sed -i.bak 's/let ocaml_stdlib.*/let ocaml_stdlib = (Sys.getenv "OCAMLLIB");;/g' src/findlib/findlib_config.mlp

export OCAMLFIND_CONF=$PREFIX/etc/findlib.conf

./configure
make all
make opt
make install

cp $OCAMLFIND_CONF findlib.conf
sed "s@path=\"$OCAMLLIB/site-lib\"@path=\"$OCAMLLIB/site-lib:$OCAMLLIB\"@g" findlib.conf > $OCAMLFIND_CONF

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

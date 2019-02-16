./configure -prefix=$PREFIX

chmod +w config/coq_config.ml
sed "s@\"${OCAML_PREFIX}/@(Sys.getenv \"OCAML_PREFIX\") ^ \"/@g" config/coq_config.ml > config/coq_config.ml.bak
sed "s@\"file:/${OCAML_PREFIX}/@\"file:/\" ^ (Sys.getenv \"OCAML_PREFIX\") ^ \"/@g" config/coq_config.ml.bak > config/coq_config.ml
make -j${CPU_COUNT}
make install

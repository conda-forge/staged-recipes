cd %SRC_DIR%/tightbind
make
ren bind eht_bind
mkdir %PREFIX%/bin
copy eht_bind %PREFIX%/bin

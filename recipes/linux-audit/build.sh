set -ex

args=(
  --prefix="$PREFIX"
  --enable-shared
  --disable-static

  # Language bindings should be built in a separate recipe.
  # Enabling them here will cause repeated builds of the same libraries.
  --with-python=no 
  --with-python3=no
  --with-golang=no

  # Might be useful to enable these in the future.
  --enable-gssapi-krb5=no
  --with-apparmor=yes
  # --with-libwrap
  --with-io_uring
)

./configure "${args[@]}"

make -j ${CPU_COUNT}
make install

# TODO
# - Would be good if luarocks would offer the ability to use only a user rockspec, instead of system.
#   (Using system-only rockspec with --force-config flag installs packages with restrictive privileges)
./configure --prefix=$PREFIX \
			--sysconfdir=$PREFIX/share/lua/ \
			--with-lua-include=$PREFIX/include \
			--rocks-tree=$PREFIX
make bootstrap
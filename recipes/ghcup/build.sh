mkdir -p $PREFIX/bin
cp ghcup $PREFIX/bin
chmod +x $PREFIX/bin/ghcup

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export GHCUP_INSTALL_BASE_PREFIX=$PREFIX" > $PREFIX/etc/conda/activate.d/ghcup.sh
echo "export GHCUP_SKIP_UPDATE_CHECK=1" >> $PREFIX/etc/conda/activate.d/ghcup.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset GHCUP_INSTALL_BASE_PREFIX" > $PREFIX/etc/conda/deactivate.d/ghcup.sh
echo "unset GHCUP_SKIP_UPDATE_CHECK" >> $PREFIX/etc/conda/deactivate.d/ghcup.sh
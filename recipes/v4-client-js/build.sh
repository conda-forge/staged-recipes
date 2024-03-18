ls
cd v4-client-js
npm install rollup
npm run build
npm test
tgz=$(npm pack)
npm install --prefix $PREFIX -g $tgz

# Install in share directory
mkdir -p $PREFIX/share
mv $PREFIX/lib/node_modules/@dydxprotocol $PREFIX/share/@dydxprotocol
ln -s $PREFIX/share/@dydxprotocol $PREFIX/lib/node_modules/@dydxprotocol
echo "$PKG_VERSION" > $PREFIX/share/@dydxprotocol/v4-client-js/version
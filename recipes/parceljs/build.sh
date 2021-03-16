yarn pack
yarn licenses generate-disclaimer --production > ThirdPartyLicenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install --build-from-source -g parcel-v${PKG_VERSION}.tgz
# Rebuild deasync with conda-forge compilers
pushd ${PREFIX}/lib/node_modules/parcel/node_modules/deasync
  rm -rf bin/*
  node build.js -f
popd

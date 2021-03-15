yarn pack
yarn licenses generate-disclaimer --production > ThirdPartyLicenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install --build-from-source -g ${PKG_NAME}-v${PKG_VERSION}.tgz

yarn pack
yarn licenses generate-disclaimer > ThirdPartyLicenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install -g ${PKG_NAME}-v${PKG_VERSION}.tgz

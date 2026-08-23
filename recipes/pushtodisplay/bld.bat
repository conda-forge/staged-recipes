set "npm_config_cache=%SRC_DIR%\.npm-cache"
npm pack --ignore-scripts
npm install -g --prefix "%PREFIX%" "pushtodisplay-%PKG_VERSION%.tgz"

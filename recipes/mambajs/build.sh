set -euxo pipefail


yarn install --frozen-lockfile
yarn run build

npx esbuild packages/mambajs-cli/dist/index.js --bundle --platform=node --outfile=mambajs.js

mkdir -p $PREFIX/lib/mambajs

cp mambajs.js $PREFIX/lib/mambajs/mambajs.js
cp $RECIPE_DIR/mambajs $PREFIX/bin/mambajs

chmod +x $PREFIX/bin/mambajs

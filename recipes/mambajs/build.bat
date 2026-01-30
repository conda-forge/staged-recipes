@echo on
setlocal enabledelayedexpansion

call yarn install --frozen-lockfile || exit /b 1
call yarn run build || exit /b 1

call npx esbuild packages/mambajs-cli/dist/index.js ^
  --bundle ^
  --platform=node ^
  --outfile=mambajs.js || exit /b 1

md %PREFIX%\Library\lib\mambajs
copy mambajs.js %PREFIX%\Library\lib\mambajs\mambajs.js || exit /b 1

md %PREFIX%\Library\bin
copy %RECIPE_DIR%\mambajs.cmd %PREFIX%\Library\bin\mambajs.cmd || exit /b 1

@echo on

REM Patch package.json to skip unnecessary prepare step
copy package.json package.json.bak
jq "del(.scripts.prepare)" < package.json.bak > package.json

REM Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd ^
    --global ^
    --build-from-source ^
    .\openai-codex-%PKG_VERSION%.tgz

REM Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

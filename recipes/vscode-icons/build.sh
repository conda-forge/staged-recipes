EXTENSION_PATH="./vscode-icons.vsix"

npm install
npm run build
npx vsce package --out ${EXTENSION_PATH}
code-server --install-extension ${EXTENSION_PATH}

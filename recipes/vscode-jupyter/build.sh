npm install -g vsce
npm ci
npm run clean
npm run package
code-server --install-extension ms-toolsai-jupyter-insiders.vsix

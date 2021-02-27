npm ci --prefer-offline
npm run addExtensionDependencies
npm run package
code-server --install-extension ms-python-insiders.vsix

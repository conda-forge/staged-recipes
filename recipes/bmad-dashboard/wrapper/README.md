# bmad-dashboard

Conda package that bundles the prebuilt
[BMAD Dashboard](https://github.com/bmad-code-org/bmad-method-ui)
VS Code extension and provides a CLI to install it into a local
VS Code (or Insiders, VSCodium, code-server) instance.

## Usage

```
bmad-dashboard-install              # install into the first detected VS Code variant
bmad-dashboard-install --list       # show installed extensions in that editor
bmad-dashboard-install --editor code-insiders
bmad-dashboard-install --uninstall  # remove the extension
bmad-dashboard-install --print-vsix # print the bundled .vsix path
```

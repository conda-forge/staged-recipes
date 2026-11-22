# Letta Code in conda

This package runs the upstream npm distribution with Node.js. Bun is not
required at runtime. `node-pty` and `sharp` are built from source, and the
package uses conda's ripgrep and libvips.

The optional Cursor integration is not included: `@cursor/sdk` and its
proprietary prebuilt native packages are removed from the npm dependency
metadata. The normal Letta agent workflow is available. Cursor-specific
commands require a separate upstream installation.

Windows x64 uses the ConPTY provided by Windows 10/11. The native add-ons
are built with MSVC against conda libvips; bundled OpenConsole/conpty binaries
and the legacy winpty backend are not installed. Windows ARM64 is excluded
because conda-forge does not currently provide libvips for that platform.
The same brush script drives the builds on Windows, macOS, and Linux.

Third-party JavaScript licenses are generated with pnpm-licenses from the
installed npm tree and the separately supplied bundled dependency sources.
The installed package's own license is preferred; supplemental upstream texts
are used only when its license file is missing. Nested notices are also included.

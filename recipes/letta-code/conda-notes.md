# Letta Code in conda

This package runs the upstream npm distribution with Node.js. Bun is not
required at runtime. `node-pty` and `sharp` are built from source, and the
package uses conda's ripgrep and libvips.

The optional Cursor integration is not included: `@cursor/sdk` and its
proprietary prebuilt native packages are removed from the npm dependency
metadata. The normal Letta agent workflow is available. Cursor-specific
commands require a separate upstream installation.

Windows is not enabled in this initial recipe. The Homebrew formula used as
reference also targets Unix, and Windows needs a separate native build path.

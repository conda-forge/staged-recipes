"""BMAD Dashboard VS Code extension, packaged for conda."""

from __future__ import annotations

__version__ = "1.2.2.dev0"

EXTENSION_ID = "bmad-code-org.bmad-method-ui"
"""The canonical <publisher>.<name> identifier used by VS Code.

Note: upstream's package.json at the pinned commit still self-IDs as
``elvince/bmad-dashboard-extension``; recipes/bmad-dashboard/build.sh rewrites
those fields before ``vsce package`` so the built .vsix carries the correct
bmad-code-org identity. Keep this ID in sync with that rewrite step."""

UPSTREAM_COMMIT = "33b330ef113c62f58a77413a241ca30f4f0b8a99"
"""GitHub commit on bmad-code-org/bmad-method-ui this build was cut from."""

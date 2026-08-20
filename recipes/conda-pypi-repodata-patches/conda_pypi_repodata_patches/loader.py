from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import yaml

REASONS = {"mis-tagged-pure-python", "name-conflict", "maintainer-prefers-feedstock"}

_BLOCKS_DIR = Path(__file__).parent / "blocks"


@dataclass(frozen=True)
class Block:
    """A single package removal definition."""

    name: str
    reason: str
    details: str | None = None
    issue: str | None = None


def load_blocks() -> list[Block]:
    """Load and validate every ``blocks/*.yaml`` file shipped with the package.

    Raises ``ValueError`` (with the offending filename) on any invalid block.
    Supports multi-document YAML files (one block per document).
    """
    blocks: list[Block] = []
    for path in sorted(_BLOCKS_DIR.glob("*.yaml")):
        docs = list(yaml.safe_load_all(path.read_text(encoding="utf-8")))
        for doc in docs:
            if doc is None:
                continue
            if not isinstance(doc, dict):
                raise ValueError(f"{path.name}: block must be a mapping")
            name = doc.get("name")
            if not isinstance(name, str) or not name:
                raise ValueError(f"{path.name}: 'name' must be a non-empty string")
            reason = doc.get("reason")
            if reason not in REASONS:
                raise ValueError(
                    f"{path.name}: 'reason' must be one of {sorted(REASONS)}, got {reason!r}"
                )
            details = doc.get("details")
            issue = doc.get("issue")
            if details is not None and not isinstance(details, str):
                raise ValueError(f"{path.name}: 'details' must be a string")
            if issue is not None and not isinstance(issue, str):
                raise ValueError(f"{path.name}: 'issue' must be a string")
            blocks.append(
                Block(name=name, reason=reason, details=details, issue=issue)
            )
    return blocks


def blocked_names() -> set[str]:
    """Convenience: the set of blocked package names."""
    return {b.name for b in load_blocks()}

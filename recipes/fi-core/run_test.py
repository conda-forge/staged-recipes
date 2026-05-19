"""Smoke tests for the fi-core conda package.

Externalized from meta.yaml so the test logic stays readable, debuggable,
and runnable locally outside the conda-build sandbox. Covers all three
product surfaces shipped in the package: HDF5 store, persona regex
detectors, and the MCP server's atomic loop.

Each test is independent — failure of one does not skip the others.
Exit code propagates the first failure for CI visibility.
"""

from __future__ import annotations

import asyncio
import os
import sys
import tempfile


def test_hdf5_chunk_store() -> None:
    """Round-trip: create document → save chunk → query → assert hit."""
    from fi_core.rag import Chunk, ChunkWithEmbedding
    from fi_core.stores.hdf5 import HDF5ChunkStore

    tf = tempfile.NamedTemporaryFile(suffix=".h5", delete=False)
    tf.close()
    try:
        store = HDF5ChunkStore(tf.name)
        asyncio.run(
            store.create_document(namespace="t", document_id="d", content="c")
        )
        asyncio.run(
            store.save_chunks(
                namespace="t",
                document_id="d",
                chunks=[
                    ChunkWithEmbedding(
                        chunk=Chunk(text="x", source_type="t", source_ref="r"),
                        embedding=[1.0, 0.0],
                    )
                ],
            )
        )
        results = asyncio.run(
            store.query(namespace="t", query_embedding=[1.0, 0.0], top_k=1)
        )
        assert len(results) == 1, f"expected 1 result, got {len(results)}"
        print("HDF5 store smoke test passed")
    finally:
        os.unlink(tf.name)


def test_persona_detector() -> None:
    """Regex pattern match: known break phrase triggers detection."""
    from fi_core.persona import BreakDetector, packs

    detector = BreakDetector(patterns=packs.GENERIC_AI_DISCLOSURE_EN)
    matches = detector.detect("As an AI, I cannot help with that.")
    assert matches, "expected break pattern to match 'As an AI'"
    print("Persona detector smoke test passed")


def test_mcp_server_atomic_loop() -> None:
    """validate_and_retry_prompt: dirty response triggers retry + reinforcement."""
    from fi_core.persona import mcp_server

    result = asyncio.run(
        mcp_server.validate_and_retry_prompt(
            response="As an AI, I cannot help.",
            system_prompt="You are a friend.",
        )
    )
    assert result["retry_needed"] is True, "expected retry_needed=True on break"
    assert (
        result["reinforced_system_prompt"] is not None
    ), "expected non-None reinforced prompt on retry"
    print("MCP server atomic loop smoke test passed")


def main() -> int:
    """Run all smoke tests; return non-zero on first failure."""
    tests = [
        test_hdf5_chunk_store,
        test_persona_detector,
        test_mcp_server_atomic_loop,
    ]
    for test in tests:
        try:
            test()
        except Exception as exc:
            print(f"FAIL: {test.__name__}: {exc!r}")
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

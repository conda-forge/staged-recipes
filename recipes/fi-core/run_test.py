"""Smoke tests for the fi-core conda package.

Externalized from meta.yaml so the test logic stays readable, debuggable,
and runnable locally outside the conda-build sandbox. Covers every public
surface shipped in the conda package:

  - fi_core.rag         — chunking strategies + value types + protocols
  - fi_core.stores.hdf5 — h5py-backed DocumentChunkStore
  - fi_core.persona     — break / soft-drift / clarification-dump detectors
  - fi_core.persona.mcp_server — MCP tools (list_packs, check_drift,
                                 sanitize_response, get_reinforcement,
                                 validate_and_retry_prompt)

These are post-install smoke tests, NOT a replacement for the source
repo's full unit-test suite. Each test is independent — failure of one
does not skip the others. Exit code propagates the first failure.

Constraints (intentional):
  - Standalone Python only — no pytest, no fixtures, no decorators.
  - No external test data files — everything inline or via tempfile.
  - Only deps available in the conda test env (python, h5py, numpy, mcp).
  - Total runtime under 5 seconds.
"""

from __future__ import annotations

import asyncio
import contextlib
import dataclasses
import os
import re
import sys
import tempfile


@contextlib.contextmanager
def _tmp_h5():
    """Yield a tempfile path for an HDF5 store; clean up on exit."""
    tf = tempfile.NamedTemporaryFile(suffix=".h5", delete=False)
    tf.close()
    try:
        yield tf.name
    finally:
        os.unlink(tf.name)


def _ce(text: str, source_ref: str, embedding):
    """Build a ChunkWithEmbedding inline (saves boilerplate in HDF5 tests)."""
    from fi_core.rag import Chunk, ChunkWithEmbedding
    return ChunkWithEmbedding(
        chunk=Chunk(text=text, source_type="t", source_ref=source_ref),
        embedding=embedding,
    )


# ============================================================
# Section: RAG (chunking + types + protocols)
# ============================================================


def test_chunk_document_paragraph_aware() -> None:
    """PARAGRAPH_AWARE: ≥1 chunk for multi-paragraph input; whole text for short input."""
    from fi_core.rag import ChunkConfig, ChunkingStrategy, chunk_document

    multi = (
        "Primer párrafo con suficiente contenido para superar el mínimo. " * 3
        + "\n\n"
        + "Segundo párrafo con otro bloque sustancial. " * 3
    )
    chunks = chunk_document(
        multi,
        strategy=ChunkingStrategy.PARAGRAPH_AWARE,
        config=ChunkConfig(chunk_size=40, overlap=5, min_chunk_size=5),
    )
    assert len(chunks) >= 1, f"expected ≥1 chunk, got {len(chunks)}"

    short = "Una oración corta pero suficiente para superar el mínimo."
    short_chunks = chunk_document(
        short,
        strategy=ChunkingStrategy.PARAGRAPH_AWARE,
        config=ChunkConfig(chunk_size=400, overlap=50, min_chunk_size=3),
    )
    assert short_chunks == [short], f"expected single whole-text chunk, got {short_chunks!r}"


def test_chunk_document_fixed_size() -> None:
    """FIXED_SIZE: multiple chunks for long input, each roughly within chunk_size bounds."""
    from fi_core.rag import ChunkConfig, ChunkingStrategy, chunk_document, estimate_tokens

    text = " ".join(["palabra"] * 300)
    chunks = chunk_document(
        text,
        strategy=ChunkingStrategy.FIXED_SIZE,
        config=ChunkConfig(chunk_size=100, overlap=20, min_chunk_size=10),
    )
    assert len(chunks) >= 2, f"expected ≥2 chunks, got {len(chunks)}"
    for c in chunks:
        toks = estimate_tokens(c)
        assert 5 <= toks <= 200, f"chunk token count {toks} outside reasonable bounds"


def test_chunk_document_sentence_aware() -> None:
    """SENTENCE_AWARE: each chunk ends on sentence-final punctuation."""
    from fi_core.rag import ChunkConfig, ChunkingStrategy, chunk_document

    text = (
        "Primera oración aquí. Segunda oración también aquí. "
        "Tercera para tener material. Cuarta oración cierra el bloque."
    )
    chunks = chunk_document(
        text,
        strategy=ChunkingStrategy.SENTENCE_AWARE,
        config=ChunkConfig(chunk_size=10, overlap=2, min_chunk_size=3),
    )
    assert len(chunks) >= 1, f"expected ≥1 chunk, got {len(chunks)}"
    for c in chunks:
        assert c.endswith((".", "?", "!")), f"chunk does not end on terminator: {c!r}"


def test_estimate_tokens_heuristic() -> None:
    """1.3 tokens-per-word heuristic for Spanish; empty string → 0."""
    from fi_core.rag import estimate_tokens

    assert estimate_tokens("hola que tal") == int(3 * 1.3)
    assert estimate_tokens("") == 0


def test_chunk_config_defaults() -> None:
    """ChunkConfig() ships the documented defaults 400 / 50 / 100."""
    from fi_core.rag import ChunkConfig

    cfg = ChunkConfig()
    assert (cfg.chunk_size, cfg.overlap, cfg.min_chunk_size) == (400, 50, 100), (
        f"defaults changed: ({cfg.chunk_size}, {cfg.overlap}, {cfg.min_chunk_size})"
    )


def test_chunk_dataclass_immutability() -> None:
    """Chunk is a frozen dataclass — mutation raises FrozenInstanceError."""
    from fi_core.rag import Chunk

    c = Chunk(text="x", source_type="t", source_ref="r")
    try:
        c.text = "mutated"  # type: ignore[misc]
    except dataclasses.FrozenInstanceError:
        return
    raise AssertionError("expected FrozenInstanceError on Chunk mutation")


def test_protocols_runtime_checkable() -> None:
    """ChunkStore is @runtime_checkable — isinstance works against structural stubs."""
    from fi_core.rag import ChunkStore

    class _StubStore:
        async def add(self, *, namespace, chunk, embedding):
            return None
        async def query(self, *, namespace, query_embedding, top_k=5):
            return []

    class _MissingQuery:
        async def add(self, *, namespace, chunk, embedding):
            return None

    assert isinstance(_StubStore(), ChunkStore), "stub with add+query must satisfy ChunkStore"
    assert not isinstance(_MissingQuery(), ChunkStore), "stub missing 'query' must NOT satisfy ChunkStore"


# ============================================================
# Section: HDF5 store
# ============================================================


def test_hdf5_chunk_store() -> None:
    """Round-trip: create document → save chunks → query → assert hit."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store = HDF5ChunkStore(path)
        asyncio.run(store.create_document(namespace="t", document_id="d", content="c"))
        asyncio.run(store.save_chunks(
            namespace="t", document_id="d",
            chunks=[_ce("x", "r", [1.0, 0.0])],
        ))
        results = asyncio.run(store.query(namespace="t", query_embedding=[1.0, 0.0], top_k=1))
        assert len(results) == 1, f"expected 1 result, got {len(results)}"


def test_hdf5_namespace_isolation() -> None:
    """Chunks in namespace A do not leak into queries on namespace B."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store = HDF5ChunkStore(path)
        for ns, text in (("A", "in_A"), ("B", "in_B")):
            asyncio.run(store.create_document(namespace=ns, document_id="d", content="c"))
            asyncio.run(store.save_chunks(
                namespace=ns, document_id="d",
                chunks=[_ce(text, f"r_{ns}", [1.0, 0.0])],
            ))
        results_a = asyncio.run(store.query(namespace="A", query_embedding=[1.0, 0.0], top_k=5))
        assert len(results_a) == 1, f"expected 1 hit in A, got {len(results_a)}"
        assert results_a[0].chunk.text == "in_A", f"namespace leak: {results_a[0].chunk.text!r}"


def test_hdf5_idempotent_save_chunks() -> None:
    """save_chunks twice with the same payload returns 1, then 0."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store = HDF5ChunkStore(path)
        asyncio.run(store.create_document(namespace="ns", document_id="d", content="c"))
        payload = [_ce("same", "r0", [1.0, 0.0])]
        first = asyncio.run(store.save_chunks(namespace="ns", document_id="d", chunks=payload))
        second = asyncio.run(store.save_chunks(namespace="ns", document_id="d", chunks=payload))
        assert first == 1 and second == 0, f"idempotency broken: ({first}, {second})"


def test_hdf5_cascading_delete() -> None:
    """delete_document cascades — child chunks disappear from queries."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store = HDF5ChunkStore(path)
        asyncio.run(store.create_document(namespace="ns", document_id="d", content="c"))
        asyncio.run(store.save_chunks(
            namespace="ns", document_id="d",
            chunks=[_ce("x", "r", [1.0, 0.0])],
        ))
        deleted = asyncio.run(store.delete_document(namespace="ns", document_id="d"))
        assert deleted is True, f"delete_document returned {deleted}"
        results = asyncio.run(store.query(namespace="ns", query_embedding=[1.0, 0.0], top_k=5))
        assert results == [], f"expected empty after cascade, got {len(results)} hits"


def test_hdf5_status_auto_promotion() -> None:
    """create_document → 'pending'; save_chunks → 'indexed' + indexed_at set."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store = HDF5ChunkStore(path)
        asyncio.run(store.create_document(namespace="ns", document_id="d", content="c"))
        doc_pre = asyncio.run(store.get_document(namespace="ns", document_id="d"))
        assert doc_pre.metadata.status == "pending", f"initial status {doc_pre.metadata.status!r}"
        asyncio.run(store.save_chunks(
            namespace="ns", document_id="d",
            chunks=[_ce("x", "r", [1.0, 0.0])],
        ))
        doc_post = asyncio.run(store.get_document(namespace="ns", document_id="d"))
        assert doc_post.metadata.status == "indexed", f"status post-save {doc_post.metadata.status!r}"
        assert doc_post.metadata.indexed_at is not None, "indexed_at must be set post-save"


def test_hdf5_persistence_across_instances() -> None:
    """A fresh HDF5ChunkStore over the same file rebuilds the index from disk."""
    from fi_core.stores.hdf5 import HDF5ChunkStore

    with _tmp_h5() as path:
        store1 = HDF5ChunkStore(path)
        asyncio.run(store1.create_document(namespace="ns", document_id="d", content="c"))
        asyncio.run(store1.save_chunks(
            namespace="ns", document_id="d",
            chunks=[_ce("persisted", "r", [1.0, 0.0])],
        ))
        del store1  # drop in-memory reference
        store2 = HDF5ChunkStore(path)
        results = asyncio.run(store2.query(namespace="ns", query_embedding=[1.0, 0.0], top_k=1))
        assert len(results) == 1 and results[0].chunk.text == "persisted", (
            f"expected 'persisted' from reopened store, got {results!r}"
        )


# ============================================================
# Section: Persona (detectors + sanitize + DetectionResult)
# ============================================================


def test_break_detector_english() -> None:
    """English break pattern matches 'As an AI'."""
    from fi_core.persona import BreakDetector, packs

    matches = BreakDetector(patterns=packs.GENERIC_AI_DISCLOSURE_EN).detect(
        "As an AI, I cannot help with that."
    )
    assert matches, "expected English break pattern to match 'As an AI'"


def test_break_detector_spanish() -> None:
    """Spanish break pattern matches 'soy un bot'."""
    from fi_core.persona import BreakDetector, packs

    matches = BreakDetector(patterns=packs.GENERIC_AI_DISCLOSURE_ES).detect(
        "Yo soy un bot diseñado para ayudarte."
    )
    assert matches, "expected Spanish break pattern to match 'soy un bot'"


def test_anti_pattern_monitor() -> None:
    """AntiPatternMonitor matches assistant-tone phrasing."""
    from fi_core.persona import AntiPatternMonitor, packs

    matches = AntiPatternMonitor(patterns=packs.ASSISTANT_TONE_EN).detect(
        "How can I help you today?"
    )
    assert matches, "expected assistant-tone match on 'How can I help'"


def test_clarification_dump_detector() -> None:
    """ClarificationDumpDetector matches Spanish punt-back phrases."""
    from fi_core.persona import ClarificationDumpDetector, packs

    matches = ClarificationDumpDetector(patterns=packs.CLARIFICATION_DUMP_ES).detect(
        "Dime qué busco exactamente."
    )
    assert matches, "expected clarification-dump match on 'Dime qué busco'"


def test_sanitize_function() -> None:
    """sanitize() drops break sentences and preserves the clean ones around them."""
    from fi_core.persona import packs, sanitize

    result = sanitize(
        "Hola amigo. As an AI I cannot. Adios.",
        patterns=packs.GENERIC_AI_DISCLOSURE_EN,
    )
    assert "As an AI" not in result, f"break sentence not removed: {result!r}"
    assert "Hola amigo" in result and "Adios" in result, f"clean sentences lost: {result!r}"


def test_detection_result_clean_flag() -> None:
    """DetectionResult.clean is True iff matched_patterns is empty."""
    from fi_core.persona import DetectionResult

    assert DetectionResult(matched_patterns=[]).clean is True
    assert DetectionResult(matched_patterns=["x"]).clean is False


def test_all_packs_are_compiled_patterns() -> None:
    """Every public pack exports a list[re.Pattern], never strings or None."""
    from fi_core.persona import packs

    pack_names = [
        "GENERIC_AI_DISCLOSURE_EN", "GENERIC_AI_DISCLOSURE_ES",
        "ASSISTANT_TONE_EN", "ASSISTANT_TONE_ES",
        "THERAPY_SPEAK_EN", "THERAPY_SPEAK_ES",
        "SUMMARIZING", "STAGE_DIRECTIONS", "MARKDOWN_DRIFT",
        "MORALIZING_EN", "MORALIZING_ES",
        "OVER_VALIDATION_EN", "OVER_VALIDATION_ES",
        "CLARIFICATION_DUMP_ES",
        "ALL_AI_DISCLOSURE", "ALL_ASSISTANT_TONE", "ALL_THERAPY_SPEAK",
        "ALL_MORALIZING", "ALL_OVER_VALIDATION",
        "DEFAULT_EN", "DEFAULT_ES", "DEFAULT_BILINGUAL",
    ]
    for name in pack_names:
        pack = getattr(packs, name)
        assert isinstance(pack, list), f"{name} must be a list, got {type(pack).__name__}"
        for p in pack:
            assert isinstance(p, re.Pattern), f"{name} contains non-Pattern: {p!r}"


# ============================================================
# Section: MCP server (atomic loop + the other 4 tools)
# ============================================================


def test_mcp_server_atomic_loop() -> None:
    """validate_and_retry_prompt: dirty response triggers retry + reinforced prompt."""
    from fi_core.persona import mcp_server

    result = asyncio.run(mcp_server.validate_and_retry_prompt(
        response="As an AI, I cannot help.",
        system_prompt="You are a friend.",
    ))
    assert result["retry_needed"] is True, "expected retry_needed=True on break"
    assert result["reinforced_system_prompt"] is not None, "expected reinforced prompt on retry"


def test_mcp_list_packs_returns_atomic_and_composite() -> None:
    """list_packs returns the documented shape with reasonable atomic/composite counts."""
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.list_packs())
    assert {"atomic_packs", "composite_packs", "default"}.issubset(r), (
        f"missing top-level keys: {list(r)!r}"
    )
    assert len(r["atomic_packs"]) >= 10, f"expected ≥10 atomic packs, got {len(r['atomic_packs'])}"
    assert len(r["composite_packs"]) >= 3, f"expected ≥3 composite packs, got {len(r['composite_packs'])}"
    assert r["default"] == ["default_bilingual"], f"default changed: {r['default']!r}"


def test_mcp_check_drift_composite_routes_atomic_severity() -> None:
    """Break-tier pattern inside a composite surfaces in matched_break (not soft_drift).

    This is the routing bug-fix composites encode: they expand to atomics so
    per-pattern severity is preserved end-to-end rather than flattened to one tier.
    """
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.check_drift(
        text="As an AI, I cannot help. How can I assist you?",
        packs=["default_bilingual"],
    ))
    assert len(r["matched_break"]) >= 1, f"break should fire for 'As an AI': {r!r}"
    assert len(r["matched_soft_drift"]) >= 1, f"soft-drift should fire for 'How can I assist': {r!r}"


def test_mcp_check_drift_clean_text() -> None:
    """Clean text yields clean=True and all empty match buckets."""
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.check_drift(text="Hola, todo bien por aquí."))
    assert r["clean"] is True, f"expected clean=True, got {r!r}"
    assert r["matched_break"] == r["matched_soft_drift"] == r["matched_clarification_dump"] == []


def test_mcp_check_drift_unknown_pack_is_graceful() -> None:
    """Unknown pack names are collected in packs_unknown rather than raising."""
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.check_drift(text="hi", packs=["totally_made_up_pack_name"]))
    assert "totally_made_up_pack_name" in r["packs_unknown"], f"unknown pack not surfaced: {r!r}"


def test_mcp_get_reinforcement_clarification_maps_to_context() -> None:
    """Pack names containing 'clarification_dump' map to CONTEXT_REINFORCEMENT."""
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.get_reinforcement("clarification_dump_es"))
    assert r["applies_to"] == "clarification_dump_es", f"applies_to drift: {r!r}"
    assert "context" in r["reinforcement"].lower(), (
        f"expected CONTEXT_REINFORCEMENT (mentions 'context'): {r!r}"
    )


def test_mcp_sanitize_response_removes_break_sentence() -> None:
    """sanitize_response strips break sentences while preserving clean ones."""
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.sanitize_response(
        text="Hola amigo. As an AI I cannot. Adios."
    ))
    assert "As an AI" not in r["sanitized"], f"break sentence survived: {r!r}"
    assert "Hola amigo" in r["sanitized"] and "Adios" in r["sanitized"], (
        f"clean sentences lost: {r!r}"
    )


def test_mcp_validate_and_retry_soft_drift_only_no_retry() -> None:
    """Soft-drift-only matches must NOT trigger retry.

    This is the severity-tier decision rule that lets noisy-tone responses
    ship while still being logged — the killer feature of the atomic loop.
    """
    from fi_core.persona import mcp_server

    r = asyncio.run(mcp_server.validate_and_retry_prompt(
        response="Great question! Let me help.",
        system_prompt="You are an expert.",
        packs=["assistant_tone_en"],
    ))
    assert len(r["matched"]["soft_drift"]) >= 1, f"soft-drift should fire: {r!r}"
    assert r["retry_needed"] is False, f"soft-drift-only must NOT request retry: {r!r}"
    assert r["reinforced_system_prompt"] is None, f"no retry => prompt must be None: {r!r}"


# ============================================================
# Runner
# ============================================================


def main() -> int:
    """Run all smoke tests; return non-zero on first failure."""
    tests = [
        # Section: RAG
        test_chunk_document_paragraph_aware,
        test_chunk_document_fixed_size,
        test_chunk_document_sentence_aware,
        test_estimate_tokens_heuristic,
        test_chunk_config_defaults,
        test_chunk_dataclass_immutability,
        test_protocols_runtime_checkable,
        # Section: HDF5 store
        test_hdf5_chunk_store,
        test_hdf5_namespace_isolation,
        test_hdf5_idempotent_save_chunks,
        test_hdf5_cascading_delete,
        test_hdf5_status_auto_promotion,
        test_hdf5_persistence_across_instances,
        # Section: Persona
        test_break_detector_english,
        test_break_detector_spanish,
        test_anti_pattern_monitor,
        test_clarification_dump_detector,
        test_sanitize_function,
        test_detection_result_clean_flag,
        test_all_packs_are_compiled_patterns,
        # Section: MCP server
        test_mcp_server_atomic_loop,
        test_mcp_list_packs_returns_atomic_and_composite,
        test_mcp_check_drift_composite_routes_atomic_severity,
        test_mcp_check_drift_clean_text,
        test_mcp_check_drift_unknown_pack_is_graceful,
        test_mcp_get_reinforcement_clarification_maps_to_context,
        test_mcp_sanitize_response_removes_break_sentence,
        test_mcp_validate_and_retry_soft_drift_only_no_retry,
    ]
    total = len(tests)
    for i, test in enumerate(tests, start=1):
        try:
            test()
        except Exception as exc:
            print(f"[{i}/{total}] {test.__name__} ... FAIL: {exc!r}")
            return 1
        print(f"[{i}/{total}] {test.__name__} ... PASS")
    print(f"\nAll {total} smoke tests passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

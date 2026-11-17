"""Check codex coexistence and run JavaScript through the packaged V8 host."""

import json
from pathlib import Path
import queue
import shutil
import struct
import subprocess
import threading
import time


def smoke_host(host: Path) -> None:
    process = subprocess.Popen(
        [str(host), "--listen", "stdio"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    frames = queue.Queue()
    deadline = time.monotonic() + 120

    def read_exact(size):
        data = bytearray()
        while len(data) < size:
            chunk = process.stdout.read(size - len(data))
            if not chunk:
                raise EOFError("code-mode host closed stdout")
            data.extend(chunk)
        return data

    def reader():
        try:
            while True:
                size = struct.unpack("<I", read_exact(4))[0]
                if size > 64 * 1024 * 1024:
                    raise ValueError("oversized code-mode frame")
                frames.put(json.loads(read_exact(size)))
        except Exception as error:
            frames.put(error)

    threading.Thread(target=reader, daemon=True).start()

    def send(message):
        payload = json.dumps(message).encode()
        process.stdin.write(struct.pack("<I", len(payload)) + payload)
        process.stdin.flush()

    def receive():
        message = frames.get(timeout=max(0.1, deadline - time.monotonic()))
        if isinstance(message, Exception):
            raise message
        result = message.get("result")
        if result is not None and result["status"] != "ok":
            raise AssertionError(message)
        return message

    def request(identifier, method, **fields):
        send({
            "type": "operation/request",
            "id": identifier,
            "request": {"method": method, "sessionId": "conda-smoke", **fields},
        })

    def response(identifier):
        while True:
            message = receive()
            if message["type"] == "operation/response" and message["id"] == identifier:
                return message["result"]["value"]

    try:
        send({
            "type": "connection/hello",
            "supportedVersions": [1],
            "requiredCapabilities": [],
            "optionalCapabilities": [],
        })
        ready = receive()
        assert ready["type"] == "connection/ready", ready
        request(1, "session/open")
        assert response(1)["type"] == "session/ready"
        request(2, "session/execute", request={
            "tool_call_id": "conda-smoke",
            "enabled_tools": [],
            "source": "text(1 + 1)",
            "yield_time_ms": 10000,
            "max_output_tokens": 100,
        })
        while True:
            message = receive()
            if message["type"] == "execute/initialResponse" and message["id"] == 2:
                runtime = message["result"]["value"]
                break
        # This tiny synchronous expression must finish within the initial yield.
        assert "Result" in runtime, runtime
        result = runtime["Result"]
        assert result["error_text"] is None, result
        assert any(
            item.get("type") == "input_text" and item["text"].strip() == "2"
            for item in result["content_items"]
        ), result
        request(3, "session/shutdown")
        assert response(3)["type"] == "session/closed"
        process.stdin.close()
        assert process.wait(timeout=30) == 0
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()


def main() -> None:
    interpreter = Path(shutil.which("interpreter")).resolve()
    prefix = interpreter.parent.parent
    metadata = json.loads((prefix / "openinterpreter-package.json").read_text())
    assert metadata["variant"] == "open-interpreter", metadata
    assert metadata["resourcesDir"] == "openinterpreter-resources", metadata
    assert metadata["pathDir"] == "openinterpreter-path", metadata

    # Verify file ownership, even if conda permits overlapping package files.
    records = [
        json.loads(path.read_text())
        for path in (prefix / "conda-meta").glob("*.json")
    ]
    owned = {record["name"]: set(record.get("files", [])) for record in records}
    assert "codex" in owned and "openinterpreter" in owned, owned.keys()
    assert owned["codex"] and owned["openinterpreter"], owned
    overlap = owned["codex"] & owned["openinterpreter"]
    assert not overlap, sorted(overlap)

    suffix = ".exe" if interpreter.suffix == ".exe" else ""
    smoke_host(prefix / "bin" / ("openinterpreter-code-mode-host" + suffix))
    print("codex coexistence and Code Mode JavaScript smoke test passed")


if __name__ == "__main__":
    main()

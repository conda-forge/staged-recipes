"""Offline static scan (no LLM, no network) of a known-malicious fixture from upstream's tests."""
import json
import os
import subprocess
import tempfile

fixture = os.path.join(os.getcwd(), "tests", "fixtures", "malicious_skill")
out = os.path.join(tempfile.mkdtemp(), "report.json")
# the scan exits non-zero when it finds high-risk issues, which is expected here
proc = subprocess.run(["skillspector", "scan", fixture, "--no-llm", "--format", "json", "--output", out])
print("exit code:", proc.returncode)
with open(out) as fh:
    report = json.load(fh)


def findings(node):
    """Yield every non-empty `findings` list anywhere in the report."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "findings" and isinstance(value, list) and value:
                yield value
            else:
                yield from findings(value)
    elif isinstance(node, list):
        for item in node:
            yield from findings(item)


found = sum(len(f) for f in findings(report))
print("top-level keys:", sorted(report) if isinstance(report, dict) else type(report).__name__)
assert found, "expected findings for the malicious fixture"
print("skillspector static scan OK:", found, "findings")

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


issues = report.get("issues") or []
print("risk_assessment:", json.dumps(report.get("risk_assessment"))[:300])
assert issues, "expected issues for the malicious fixture"
print("skillspector static scan OK:", len(issues), "issues")

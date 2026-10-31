"""Smoke test for the semgrep CLI: print the version, then scan one file with one rule.

Python rather than a shell script so the same test runs on unix and non-unix (cmd).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

RULE = """rules:
  - id: no-print
    pattern: print(...)
    message: no print
    languages: [python]
    severity: WARNING
"""


def run(label, args, **kw):
    """Run args, print exit code and output tails, and exit on failure."""
    p = subprocess.run(args, capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=120, check=False, **kw)
    print("[%s] %r -> %d" % (label, args, p.returncode))
    print("  stdout: %s\n  stderr: %s" % (p.stdout.strip()[-2000:], p.stderr.strip()[-2000:]))
    if p.returncode != 0:
        sys.exit("semgrep %s failed" % label)
    return p


def main():
    # non-unix console is cp1252; semgrep's stderr has characters it cannot encode
    sys.stdout.reconfigure(errors="replace")
    semgrep = shutil.which("semgrep")
    if semgrep is None:
        sys.exit("semgrep not found on PATH")
    work = Path(tempfile.mkdtemp())
    (work / "rule.yaml").write_text(RULE)
    (work / "test.py").write_text('print("hi")\n')
    env = dict(
        os.environ,
        SEMGREP_ENABLE_VERSION_CHECK="0",
        SEMGREP_SEND_METRICS="off",
        SEMGREP_SETTINGS_FILE=str(work / "s.yaml"),
        SEMGREP_VERSION_CACHE_PATH=str(work / "vc"),
    )
    run("version", [semgrep, "--version"], env=env)
    p = run("scan", [semgrep, "scan", "--metrics=off", "--disable-version-check",
                     "--config", "rule.yaml", "test.py", "--json"],
            env=env, cwd=work)
    ids = [r["check_id"] for r in json.loads(p.stdout)["results"]]
    if not any(i.endswith("no-print") for i in ids):
        sys.exit("no-print finding not reported: %r" % ids)
    print("ok: %r" % ids)


if __name__ == "__main__":
    main()

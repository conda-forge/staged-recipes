"""Smoke test for the semgrep CLI: print the version, then scan one file with one rule.

Python rather than a shell script so the same test runs on unix and non-unix (cmd).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

RULE = """rules:
  - id: no-print
    pattern: print(...)
    message: no print
    languages: [python]
    severity: WARNING
"""


def main():
    semgrep = shutil.which("semgrep")
    if semgrep is None:
        sys.exit("semgrep not found on PATH")
    work = tempfile.mkdtemp()
    with open(os.path.join(work, "rule.yaml"), "w") as f:
        f.write(RULE)
    with open(os.path.join(work, "test.py"), "w") as f:
        f.write('print("hi")\n')
    env = dict(
        os.environ,
        SEMGREP_ENABLE_VERSION_CHECK="0",
        SEMGREP_SEND_METRICS="off",
        SEMGREP_SETTINGS_FILE=os.path.join(work, "s.yaml"),
        SEMGREP_VERSION_CACHE_PATH=os.path.join(work, "vc"),
    )
    subprocess.run([semgrep, "--version"], check=True, env=env)
    out = subprocess.run(
        [semgrep, "scan", "--metrics=off", "--disable-version-check",
         "--config", "rule.yaml", "test.py", "--json"],
        check=True, env=env, cwd=work, capture_output=True,
        text=True, encoding="utf-8",
    ).stdout
    ids = [r["check_id"] for r in json.loads(out)["results"]]
    if not any(i.endswith("no-print") for i in ids):
        sys.exit("no-print finding not reported: %r" % ids)
    print("ok: %r" % ids)


if __name__ == "__main__":
    main()
